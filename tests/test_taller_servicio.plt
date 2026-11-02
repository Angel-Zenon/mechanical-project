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

:- end_tests(taller_servicio).
