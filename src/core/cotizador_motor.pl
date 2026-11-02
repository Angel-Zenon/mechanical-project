:- module(cotizador_motor, [
    desglose_maniobras/4,
    cotizar_servicio/5,
    cotizar_orden_multiple/5,
    servicios_dentro_presupuesto/4
]).

:- use_module(library(apply)).
:- use_module('../kb/catalogos_kb').
:- use_module('../kb/vehiculos_kb').
:- use_module('grafo_motor').

/** <module> Motor de Cotización Dinámica por Topología de Desensamble
 *
 * Implementa el cálculo de costos y tiempos de mano de obra según la ruta
 * topológica deducida por el motor de grafos.
 *
 * Características principales:
 * - Uso de predicados de orden superior (maplist/3, foldl/4).
 * - Idempotencia estricta en órdenes múltiples (no cobra pasos repetidos).
 * - Multiplicador de tarifa por vehículo (FactorTarifa).
 * - Inversibilidad relacional para presupuestos máximos.
 */

% ==============================================================================
% 1. DESGLOSE DE MANIOBRAS MEDIANTE PREDICADOS DE ORDEN SUPERIOR
% desglose_maniobras(+ListaPasos, -ListaDetalle, -CostoBaseTotal, -TiempoTotalMin)
% ==============================================================================

obtener_detalle_maniobra(Pieza, paso_costo(Pieza, Costo, Tiempo)) :-
    maniobra(Pieza, Costo, Tiempo).

acumular_costo_tiempo(paso_costo(_, C, T), totales(CAcc, TAcc), totales(CNuevo, TNuevo)) :-
    CNuevo is CAcc + C,
    TNuevo is TAcc + T.

desglose_maniobras(ListaPasos, ListaDetalle, CostoBaseTotal, TiempoTotalMin) :-
    maplist(obtener_detalle_maniobra, ListaPasos, ListaDetalle),
    foldl(acumular_costo_tiempo, ListaDetalle, totales(0, 0), totales(CostoBaseTotal, TiempoTotalMin)).

% ==============================================================================
% 2. COTIZACIÓN DE ÓRDENES MÚLTIPLES (Idempotente)
% cotizar_orden_multiple(+Carro, +ListaObjetivos, -Pasos, -TiempoMin, -CostoFinal)
% ==============================================================================
cotizar_orden_multiple(Carro, ListaObjetivos, PasosUnificados, TiempoMin, CostoFinal) :-
    vehiculo(Carro, _, _, FactorTarifa),
    ListaObjetivos \= [],
    % Validar que cada objetivo sea soportado por la arquitectura del vehículo
    forall(member(Obj, ListaObjetivos),
           (maniobra(Obj, _, _), vehiculo_soporta_pieza(Carro, Obj))),
    % Obtener la secuencia topológica de desarme unificada sin duplicados
    plan_desensamble_multiple(Carro, ListaObjetivos, PasosUnificados),
    % Calcular costo y tiempo base sin repetir piezas intermedias
    desglose_maniobras(PasosUnificados, _, CostoBase, TiempoMin),
    % Aplicar factor multiplicador por gama de vehículo
    CostoFinal is round(CostoBase * FactorTarifa).

% ==============================================================================
% 3. COTIZACIÓN DE UN SERVICIO INDIVIDUAL (Inversible)
% cotizar_servicio(?Carro, ?PiezaObjetivo, -Pasos, -TiempoMin, -CostoFinal)
% ==============================================================================
cotizar_servicio(Carro, PiezaObjetivo, Pasos, TiempoMin, CostoFinal) :-
    vehiculo(Carro, _, _, _),
    pieza_intervenible(PiezaObjetivo),
    vehiculo_soporta_pieza(Carro, PiezaObjetivo),
    cotizar_orden_multiple(Carro, [PiezaObjetivo], Pasos, TiempoMin, CostoFinal).

% ==============================================================================
% 4. CONSULTA INVERSIBLE POR PRESUPUESTO MÁXIMO
% servicios_dentro_presupuesto(+Carro, +PresupuestoMax, -PiezaServicio, -CostoFinal)
% ==============================================================================
servicios_dentro_presupuesto(Carro, PresupuestoMax, PiezaServicio, CostoFinal) :-
    cotizar_servicio(Carro, PiezaServicio, _, _, CostoFinal),
    CostoFinal =< PresupuestoMax.
