:- module(diagnostico_motor, [
    evaluar_falla/5,
    diagnostico_estricto/3,
    sugerir_diagnostico/4
]).

:- use_module('../kb/catalogos_kb').
:- use_module('../kb/fallas_kb').

/** <module> Motor de Inferencia Diagnóstica (Sistema Experto)
 *
 * Implementa dos niveles de deducción diagnóstica a partir de evidencia
 * clínica automotriz (síntomas y códigos/testigos de tablero):
 * 1. Diagnóstico estricto (100% de evidencia esperada confirmada mediante forall/2).
 * 2. Diagnóstico heurístico / sugerencia ponderada por porcentaje de certeza,
 *    entregando las opciones ordenadas de mayor a menor afinidad.
 */

% ==============================================================================
% 1. NÚCLEO DE EVALUACIÓN DE EVIDENCIA (DRY)
% evaluar_falla(+Sintomas, +Testigos, ?IdFalla, -Coincidencias, -Certeza)
% ==============================================================================
evaluar_falla(ListaSintomasRaw, ListaTestigosRaw, IdFalla, Coincidencias, CertezaPorcentaje) :-
    % Normalizar las listas del usuario eliminando entradas duplicadas
    list_to_set(ListaSintomasRaw, SintomasNorm),
    list_to_set(ListaTestigosRaw, TestigosNorm),
    append(SintomasNorm, TestigosNorm, EvidenciaCliente),
    EvidenciaCliente \= [],
    % Unificar o generar la falla conocida
    falla_pieza(IdFalla, _),
    % Recolectar la evidencia total esperada de la falla
    findall(S, falla_sintoma(IdFalla, S), SintomasFalla),
    findall(T, falla_testigo(IdFalla, T), TestigosFalla),
    append(SintomasFalla, TestigosFalla, EvidenciaEsperadaRaw),
    list_to_set(EvidenciaEsperadaRaw, EvidenciaEsperada),
    length(EvidenciaEsperada, TotalEsperado),
    TotalEsperado > 0,
    % Calcular intersección entre lo reportado por el cliente y lo esperado
    intersection(EvidenciaEsperada, EvidenciaCliente, Coincidencias),
    length(Coincidencias, NumCoincidencias),
    NumCoincidencias > 0,
    CertezaPorcentaje is round((NumCoincidencias / TotalEsperado) * 100).

% ==============================================================================
% 2. DIAGNÓSTICO ESTRICTO / CONFIRMADO (forall/2)
% diagnostico_estricto(+ListaSintomas, +ListaTestigos, -IdFalla)
% ==============================================================================
% Se confirma cuando el vehículo presenta la totalidad de los síntomas y testigos
% requeridos para dicha falla (100% de coincidencia).
diagnostico_estricto(ListaSintomasRaw, ListaTestigosRaw, IdFalla) :-
    list_to_set(ListaSintomasRaw, SintomasNorm),
    list_to_set(ListaTestigosRaw, TestigosNorm),
    falla_pieza(IdFalla, _),
    % Debe tener al menos algún síntoma o testigo declarado
    ( falla_sintoma(IdFalla, _) -> true ; falla_testigo(IdFalla, _) ),
    % Todos los síntomas de la falla deben estar presentes en el reporte del cliente
    forall(falla_sintoma(IdFalla, S), member(S, SintomasNorm)),
    % Todos los testigos/códigos de la falla deben estar presentes en el reporte del cliente
    forall(falla_testigo(IdFalla, T), member(T, TestigosNorm)).

% ==============================================================================
% 3. DIAGNÓSTICO HEURÍSTICO / SUGERENCIAS PONDERADAS
% sugerir_diagnostico(+ListaSintomas, +ListaTestigos, -IdFalla, -CertezaPorcentaje)
% ==============================================================================
% Devuelve por backtracking las fallas con al menos una coincidencia,
% ordenadas de mayor a menor porcentaje de certeza.
sugerir_diagnostico(ListaSintomasRaw, ListaTestigosRaw, IdFalla, CertezaPorcentaje) :-
    findall(Certeza-Falla,
            evaluar_falla(ListaSintomasRaw, ListaTestigosRaw, Falla, _, Certeza),
            ParesBrutos),
    ParesBrutos \= [],
    % Eliminar posibles duplicados idénticos en la lista de pares
    list_to_set(ParesBrutos, ParesUnicos),
    % Ordenar descendentemente por certeza
    sort(1, @>=, ParesUnicos, ParesOrdenados),
    member(CertezaPorcentaje-IdFalla, ParesOrdenados).
