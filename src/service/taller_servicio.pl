:- module(taller_servicio, [
    diagnosticar_y_cotizar/5,
    generar_orden_trabajo/3,
    comparar_vehiculos_servicio/5
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

%% comparar_vehiculos_servicio(+Carro1, +ObjetivosRaw1, +Carro2, +ObjetivosRaw2, -DictComparativa) is semidet.
%
% Genera las órdenes de servicio para dos vehículos (con el servicio o lista de
% servicios elegidos para cada uno) y calcula las diferencias topológicas
% (piezas a desmontar comunes y exclusivas), de tiempo y de precio total.
comparar_vehiculos_servicio(Carro1, ObjetivosRaw1, Carro2, ObjetivosRaw2, DictComparativa) :-
    generar_orden_trabajo(Carro1, ObjetivosRaw1, Orden1),
    generar_orden_trabajo(Carro2, ObjetivosRaw2, Orden2),
    Pasos1 = Orden1.pasos_desensamble,
    Pasos2 = Orden2.pasos_desensamble,
    length(Pasos1, NumPasos1),
    length(Pasos2, NumPasos2),
    DiffPasos is abs(NumPasos1 - NumPasos2),
    intersection(Pasos1, Pasos2, PiezasComunes),
    subtract(Pasos1, Pasos2, Exclusivas1),
    subtract(Pasos2, Pasos1, Exclusivas2),
    Tiempo1 = Orden1.tiempo_total_min,
    Tiempo2 = Orden2.tiempo_total_min,
    DiffTiempo is abs(Tiempo1 - Tiempo2),
    Costo1 = Orden1.costo_total_mxn,
    Costo2 = Orden2.costo_total_mxn,
    DiffCosto is abs(Costo1 - Costo2),
    determinar_menor(Carro1, Tiempo1, Carro2, Tiempo2, MasRapido),
    determinar_menor(Carro1, Costo1, Carro2, Costo2, MasEconomico),
    DictComparativa = comparativa{
        orden_1: Orden1,
        orden_2: Orden2,
        resumen: resumen_comparativo{
            num_pasos_1: NumPasos1,
            num_pasos_2: NumPasos2,
            diferencia_pasos: DiffPasos,
            piezas_comunes: PiezasComunes,
            piezas_exclusivas_1: Exclusivas1,
            piezas_exclusivas_2: Exclusivas2,
            diferencia_tiempo_min: DiffTiempo,
            diferencia_costo_mxn: DiffCosto,
            mas_rapido: MasRapido,
            mas_economico: MasEconomico
        }
    }.

determinar_menor(Carro1, Valor1, _, Valor2, Carro1) :-
    Valor1 < Valor2,
    !.
determinar_menor(_, Valor1, Carro2, Valor2, Carro2) :-
    Valor2 < Valor1,
    !.
determinar_menor(_, _, _, _, empate).
