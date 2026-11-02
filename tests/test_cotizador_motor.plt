:- use_module(library(plunit)).
:- use_module('../src/kb/catalogos_kb').
:- use_module('../src/kb/vehiculos_kb').
:- use_module('../src/kb/topologia_kb').
:- use_module('../src/core/grafo_motor').
:- use_module('../src/core/cotizador_motor').

:- begin_tests(cotizador_motor).

test(desglose_orden_superior_maplist_foldl) :-
    desglose_maniobras([cables_bujia, bujias], Detalle, CostoBase, TiempoTotal),
    assertion(CostoBase == 280),
    assertion(TiempoTotal == 30),
    assertion(Detalle == [paso_costo(cables_bujia, 80, 10), paso_costo(bujias, 200, 20)]).

test(contraste_arquitectonico_tsuru_vs_maxima_bujias) :-
    cotizar_servicio(tsuru_gs2, bujias, PasosTsuru, TiempoTsuru, CostoTsuru),
    cotizar_servicio(maxima_v6, bujias, PasosMaxima, TiempoMaxima, CostoMaxima),
    % Tsuru: 2 pasos, 30 min, $280 MXN
    assertion(PasosTsuru == [cables_bujia, bujias]),
    assertion(TiempoTsuru == 30),
    assertion(CostoTsuru == 280),
    % Maxima: 6 pasos, 150 min (2.5 hrs), $2250 MXN (por factor 1.5)
    assertion(length(PasosMaxima, 6)),
    assertion(TiempoMaxima == 150),
    assertion(CostoMaxima == 2250),
    assertion(CostoMaxima > CostoTsuru * 7).

test(ahorro_idempotencia_maxima_bujias_inyectores) :-
    cotizar_servicio(maxima_v6, bujias, _, _, CostoBujias),
    cotizar_servicio(maxima_v6, inyectores, _, _, CostoInyectores),
    cotizar_orden_multiple(maxima_v6, [bujias, inyectores], Pasos, _, CostoConjunto),
    % La orden conjunta debe costar estrictamente menos que la suma separada
    assertion(CostoConjunto < CostoBujias + CostoInyectores),
    % Las piezas compartidas (cubierta, cuerpo, mangueras, pleno) suman $1150 base * 1.5 = $1725
    Ahorro is (CostoBujias + CostoInyectores) - CostoConjunto,
    assertion(Ahorro == 1725),
    % Las piezas intermedias solo deben facturarse una vez en la lista de pasos
    list_to_set(Pasos, PasosSinDup),
    assertion(Pasos == PasosSinDup).

test(proteccion_de_dominio_incompatibilidad) :-
    % No es posible cotizar bomba de agua ni inyectores en un Vocho
    assertion(\+ cotizar_servicio(vocho_sedan, bomba_agua, _, _, _)),
    assertion(\+ cotizar_servicio(vocho_sedan, inyectores, _, _, _)),
    assertion(\+ cotizar_orden_multiple(vocho_sedan, [bujias, bomba_agua], _, _, _)).

test(inversibilidad_por_presupuesto_maximo) :-
    % Averiguar qué servicios se pueden realizar en un Tsuru con $300 MXN o menos
    setof(Servicio, Costo^servicios_dentro_presupuesto(tsuru_gs2, 300, Servicio, Costo), ServiciosAccesibles),
    assertion(member(bujias, ServiciosAccesibles)),
    assertion(member(bateria, ServiciosAccesibles)),
    % Servicios más caros como alternador no deben aparecer
    assertion(\+ member(alternador, ServiciosAccesibles)).

test(inversibilidad_cotizar_servicio_por_vehiculo) :-
    % Averiguar cuál vehículo es el más económico para cambiar bujías
    findall(Costo-Carro, cotizar_servicio(Carro, bujias, _, _, Costo), ListaPrecios),
    keysort(ListaPrecios, [MenorCosto-VehiculoMasEconomico|_]),
    assertion(MenorCosto == 280),
    assertion(VehiculoMasEconomico == tsuru_gs2).

:- end_tests(cotizador_motor).
