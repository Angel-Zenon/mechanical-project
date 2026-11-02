:- use_module(library(plunit)).
:- use_module('../src/kb/catalogos_kb').
:- use_module('../src/kb/vehiculos_kb').

:- begin_tests(catalogos_vehiculos).

test(conteo_vehiculos_minimo, [true(Total >= 10)]) :-
    findall(V, vehiculo(V, _, _, _), Lista),
    list_to_set(Lista, Unicos),
    length(Unicos, Total).

test(factores_tarifa_positivos) :-
    forall(vehiculo(V, Nombre, _, Factor),
           ( assertion(atom(V)),
             assertion(atom(Nombre)),
             assertion(number(Factor)),
             assertion(Factor >= 1.0) )).

test(integridad_maniobras_positivas) :-
    forall(maniobra(Pieza, Costo, Tiempo),
           ( assertion(atom(Pieza)),
             assertion(number(Costo)),
             assertion(Costo > 0),
             assertion(integer(Tiempo)),
             assertion(Tiempo > 0) )).

test(piezas_intervenibles_existen_en_maniobras) :-
    forall(pieza_intervenible(P),
           assertion(maniobra(P, _, _))).

test(catalogos_sintomas_y_testigos_validos) :-
    findall(S, sintoma_catalogo(S, _), Sintomas),
    findall(T, testigo_catalogo(T, _), Testigos),
    length(Sintomas, NumS),
    length(Testigos, NumT),
    assertion(NumS >= 10),
    assertion(NumT >= 5),
    forall(member(S, Sintomas), assertion(atom(S))),
    forall(member(T, Testigos), assertion(atom(T))).

test(compatibilidad_piezas_universales) :-
    % Todos los autos del catálogo soportan bujías, batería y alternador
    forall(vehiculo(V, _, _, _),
           ( assertion(vehiculo_soporta_pieza(V, bujias)),
             assertion(vehiculo_soporta_pieza(V, bateria)),
             assertion(vehiculo_soporta_pieza(V, alternador)) )).

test(compatibilidad_enfriamiento_vocho_vs_otros) :-
    % El Vocho es enfriado por aire: no tiene bomba de agua, pero sí tolva de enfriamiento
    assertion(\+ vehiculo_soporta_pieza(vocho_sedan, bomba_agua)),
    assertion(vehiculo_soporta_pieza(vocho_sedan, tolva_enfriamiento)),
    % Los demás autos con enfriamiento líquido soportan bomba de agua
    assertion(vehiculo_soporta_pieza(tsuru_gs2, bomba_agua)),
    assertion(vehiculo_soporta_pieza(chevy_pop, bomba_agua)),
    assertion(vehiculo_soporta_pieza(maxima_v6, bomba_agua)).

test(compatibilidad_alimentacion_carburador_vs_inyeccion) :-
    % El Vocho es carburado: no tiene inyectores ni riel, pero sí carburador
    assertion(\+ vehiculo_soporta_pieza(vocho_sedan, inyectores)),
    assertion(\+ vehiculo_soporta_pieza(vocho_sedan, riel_inyectores)),
    assertion(vehiculo_soporta_pieza(vocho_sedan, carburador)),
    % Autos modernos EFI soportan inyectores y no carburador
    assertion(vehiculo_soporta_pieza(maxima_v6, inyectores)),
    assertion(vehiculo_soporta_pieza(civic_ex, inyectores)),
    assertion(\+ vehiculo_soporta_pieza(maxima_v6, carburador)).

test(compatibilidad_ignicion_cables_vs_bobinas_cop) :-
    % Tsuru y Chevy usan cables de bujía, no bobinas individuales COP
    assertion(vehiculo_soporta_pieza(tsuru_gs2, cables_bujia)),
    assertion(\+ vehiculo_soporta_pieza(tsuru_gs2, bobinas_ignicion)),
    assertion(vehiculo_soporta_pieza(chevy_pop, cables_bujia)),
    assertion(\+ vehiculo_soporta_pieza(chevy_pop, bobinas_ignicion)),
    % BMW, Maxima, Civic usan bobinas COP, no cables de distribuidor
    assertion(vehiculo_soporta_pieza(bmw_325i, bobinas_ignicion)),
    assertion(\+ vehiculo_soporta_pieza(bmw_325i, cables_bujia)),
    assertion(vehiculo_soporta_pieza(maxima_v6, bobinas_ignicion)),
    assertion(\+ vehiculo_soporta_pieza(maxima_v6, cables_bujia)).

test(compatibilidad_distribucion_banda_chevy) :-
    assertion(vehiculo_soporta_pieza(chevy_pop, banda_distribucion)),
    assertion(\+ vehiculo_soporta_pieza(tsuru_gs2, banda_distribucion)),
    assertion(\+ vehiculo_soporta_pieza(vocho_sedan, banda_distribucion)).

test(compatibilidad_chassis_bmw_tolva_y_barra) :-
    assertion(vehiculo_soporta_pieza(bmw_325i, tolva_microfiltro)),
    assertion(vehiculo_soporta_pieza(bmw_325i, barra_estructural)),
    assertion(\+ vehiculo_soporta_pieza(tsuru_gs2, tolva_microfiltro)),
    assertion(\+ vehiculo_soporta_pieza(maxima_v6, barra_estructural)).

:- end_tests(catalogos_vehiculos).
