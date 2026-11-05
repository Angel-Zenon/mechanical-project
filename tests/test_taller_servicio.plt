:- use_module(library(plunit)).
:- use_module('../src/kb/catalogos_kb').
:- use_module('../src/kb/vehiculos_kb').
:- use_module('../src/kb/topologia_kb').
:- use_module('../src/kb/fallas_kb').
:- use_module('../src/core/grafo_motor').
:- use_module('../src/core/cotizador_motor').
:- use_module('../src/core/diagnostico_motor').
:- use_module('../src/service/taller_servicio').

:- begin_tests(taller_servicio).

test(flujo_end_to_end_diagnostico_confirmado_maxima, [nondet]) :-
    % Caso clínico: Maxima V6 con fallo aleatorio de encendido completo
    Sintomas = [tironeo_al_acelerar, ralenti_inestable, alto_consumo_gasolina],
    Testigos = [check_engine, codigo_p0300],
    diagnosticar_y_cotizar(maxima_v6, Sintomas, Testigos, confirmado, Res),
    get_dict(falla, Res, Falla),
    get_dict(certeza, Res, Certeza),
    get_dict(pieza, Res, Pieza),
    get_dict(orden_servicio, Res, Orden),
    get_dict(costo_total_mxn, Orden, CostoTotal),
    get_dict(pasos_desensamble, Orden, Pasos),
    assertion(Falla == fallo_encendido_bujias),
    assertion(Certeza == 100),
    assertion(Pieza == bujias),
    assertion(CostoTotal == 2250),
    assertion(member(pleno_admision, Pasos)),
    assertion(member(cuerpo_aceleracion, Pasos)).

test(filtro_inteligente_por_arquitectura_vocho) :-
    % Un Vocho reporta tironeo y ralenti inestable
    % El sistema NO debe sugerir inyector_tapado (porque es carburado)
    Sintomas = [tironeo_al_acelerar, ralenti_inestable],
    findall(Falla,
            ( diagnosticar_y_cotizar(vocho_sedan, Sintomas, [], sugerido, Res),
              get_dict(falla, Res, Falla) ),
            Fallas),
    assertion(\+ member(inyector_tapado, Fallas)),
    assertion(member(carburador_descalibrado, Fallas)),
    assertion(member(fallo_encendido_bujias, Fallas)).

test(generar_orden_trabajo_compuesta_forester) :-
    generar_orden_trabajo(forester_bx, [bujias], Orden),
    get_dict(vehiculo_id, Orden, VehiculoId),
    get_dict(factor_tarifa, Orden, FactorTarifa),
    get_dict(pasos_desensamble, Orden, Pasos),
    get_dict(tiempo_total_min, Orden, TiempoTotal),
    get_dict(costo_total_mxn, Orden, CostoTotal),
    assertion(VehiculoId == forester_bx),
    assertion(FactorTarifa == 1.6),
    assertion(member(bateria, Pasos)),
    assertion(member(deposito_limpiador, Pasos)),
    assertion(member(caja_filtro_aire, Pasos)),
    assertion(TiempoTotal > 0),
    assertion(CostoTotal > 0).

test(rechazo_orden_para_piezas_incompatibles) :-
    % Vocho no puede generar orden para bomba de agua ni combinación con inyectores
    assertion(\+ generar_orden_trabajo(vocho_sedan, [bomba_agua], _)),
    assertion(\+ generar_orden_trabajo(vocho_sedan, [bujias, inyectores], _)).

test(comparar_mismo_servicio_dos_vehiculos_tsuru_vs_maxima) :-
    % Comparar cambio de bujías entre Tsuru GS2 (L4 simple) y Maxima V6 (V6 transversal)
    comparar_vehiculos_servicio(tsuru_gs2, [bujias], maxima_v6, [bujias], Comp),
    get_dict(orden_1, Comp, O1),
    get_dict(orden_2, Comp, O2),
    get_dict(resumen, Comp, R),
    assertion(O1.costo_total_mxn == 280),
    assertion(O2.costo_total_mxn == 2250),
    assertion(R.num_pasos_1 == 2),
    assertion(R.num_pasos_2 == 6),
    assertion(R.diferencia_pasos == 4),
    assertion(R.diferencia_tiempo_min == 120),
    assertion(R.diferencia_costo_mxn == 1970),
    assertion(R.mas_rapido == tsuru_gs2),
    assertion(R.mas_economico == tsuru_gs2),
    assertion(R.piezas_comunes == [bujias]),
    assertion(R.piezas_exclusivas_1 == [cables_bujia]),
    assertion(member(pleno_admision, R.piezas_exclusivas_2)).

test(comparar_servicios_distintos_entre_dos_vehiculos) :-
    % Comparar cambio de bomba de agua en Chevy Pop vs cambio de bujías en BMW 325i
    comparar_vehiculos_servicio(chevy_pop, [bomba_agua], bmw_325i, [bujias], Comp),
    get_dict(orden_1, Comp, O1),
    get_dict(orden_2, Comp, O2),
    get_dict(resumen, Comp, R),
    assertion(O1.servicios_solicitados == [bomba_agua]),
    assertion(O2.servicios_solicitados == [bujias]),
    assertion(R.num_pasos_1 == 3),
    assertion(R.num_pasos_2 == 5),
    assertion(R.piezas_comunes == []).

test(comparar_falla_si_servicio_incompatible_en_algun_vehiculo) :-
    % No debe permitir comparar bomba de agua en Vocho (enfriado por aire)
    assertion(\+ comparar_vehiculos_servicio(tsuru_gs2, [bomba_agua], vocho_sedan, [bomba_agua], _)).

:- end_tests(taller_servicio).
