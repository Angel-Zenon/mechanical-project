:- module(taller_servicio, [
    diagnosticar_y_cotizar/5,
    generar_orden_trabajo/3
]).

:- use_module('../kb/catalogos_kb').
:- use_module('../kb/vehiculos_kb').
:- use_module('../kb/fallas_kb').
:- use_module('../core/grafo_motor').
:- use_module('../core/cotizador_motor').
:- use_module('../core/diagnostico_motor').

/** <module> Orquestación de Casos de Uso del Taller Automotriz
 *
 * Capa de servicio (Application/Use Case Layer) pura y libre de efectos secundarios (I/O).
 * Conecta el motor de diagnóstico clínico con el cotizador topológico,
 * garantizando el filtrado por compatibilidad de arquitectura del vehículo.
 */

%% normalizar_objetivos(+ObjetivosRaw, -ListaObjetivos) is det.
normalizar_objetivos(Objetivo, [Objetivo]) :-
    \+ is_list(Objetivo),
    !.
normalizar_objetivos(Lista, Lista).

%% generar_orden_trabajo(+Carro, +ObjetivosRaw, -DictOrden) is semidet.
%
% Construye un diccionario estructurado con todos los datos y el desglose
% de maniobras para uno o varios servicios solicitados.
generar_orden_trabajo(Carro, ObjetivosRaw, DictOrden) :-
    normalizar_objetivos(ObjetivosRaw, Objetivos),
    Objetivos \= [],
    vehiculo(Carro, Nombre, Arquitectura, FactorTarifa),
    % Validar compatibilidad mecánica de cada componente solicitado
    forall(member(Obj, Objetivos),
           (maniobra(Obj, _, _), vehiculo_soporta_pieza(Carro, Obj))),
    % Resolver la secuencia física de desensamble en el DAG
    plan_desensamble_multiple(Carro, Objetivos, Pasos),
    % Obtener el desglose detallado de mano de obra
    desglose_maniobras(Pasos, Desglose, CostoBase, TiempoMin),
    CostoFinal is round(CostoBase * FactorTarifa),
    DictOrden = orden{
        vehiculo_id: Carro,
        vehiculo_nombre: Nombre,
        arquitectura: Arquitectura,
        factor_tarifa: FactorTarifa,
        servicios_solicitados: Objetivos,
        pasos_desensamble: Pasos,
        desglose_maniobras: Desglose,
        subtotal_base_mxn: CostoBase,
        tiempo_total_min: TiempoMin,
        costo_total_mxn: CostoFinal
    }.

%% diagnosticar_y_cotizar(+Carro, +Sintomas, +Testigos, ?ModoDiagnostico, -DictResultado) is nondet.
%
% Infiere la falla según la evidencia del cliente, verifica que la pieza afectada
% aplique en el vehículo en cuestión y cotiza automáticamente la orden de reparación.
%
% ModoDiagnostico puede ser 'confirmado' (100% de evidencia) o 'sugerido' (heurístico).
diagnosticar_y_cotizar(Carro, Sintomas, Testigos, confirmado, DictResultado) :-
    diagnostico_estricto(Sintomas, Testigos, Falla),
    falla_pieza(Falla, Pieza),
    % Filtrar por compatibilidad con el motor específico
    vehiculo_soporta_pieza(Carro, Pieza),
    generar_orden_trabajo(Carro, [Pieza], DictOrden),
    DictResultado = diagnostico{
        vehiculo: Carro,
        modo: confirmado,
        falla: Falla,
        certeza: 100,
        pieza: Pieza,
        orden_servicio: DictOrden
    }.

diagnosticar_y_cotizar(Carro, Sintomas, Testigos, sugerido, DictResultado) :-
    sugerir_diagnostico(Sintomas, Testigos, Falla, Certeza),
    % Evitar repetir como sugerido si ya cumplió como 100% confirmado
    \+ diagnostico_estricto(Sintomas, Testigos, Falla),
    falla_pieza(Falla, Pieza),
    % Filtrar por compatibilidad con el motor específico
    vehiculo_soporta_pieza(Carro, Pieza),
    generar_orden_trabajo(Carro, [Pieza], DictOrden),
    DictResultado = diagnostico{
        vehiculo: Carro,
        modo: sugerido,
        falla: Falla,
        certeza: Certeza,
        pieza: Pieza,
        orden_servicio: DictOrden
    }.
