:- use_module(library(plunit)).
:- use_module('../src/kb/catalogos_kb').
:- use_module('../src/kb/fallas_kb').
:- use_module('../src/core/diagnostico_motor').

:- begin_tests(diagnostico_motor).

test(diagnostico_estricto_exito_y_fallo, [nondet]) :-
    % Con evidencia completa del 100%, diagnostico_estricto confirma la falla
    diagnostico_estricto([sobrecalentamiento, charco_anticongelante], [testigo_temperatura], Falla),
    assertion(Falla == fuga_bomba_agua),
    % Si falta un testigo indispensable, el diagnóstico estricto falla
    assertion(\+ diagnostico_estricto([sobrecalentamiento, charco_anticongelante], [], fuga_bomba_agua)).

test(sugerencia_parcial_certeza_exacta) :-
    % Si solo se tienen 2 de las 3 evidencias de fuga_bomba_agua:
    evaluar_falla([sobrecalentamiento, charco_anticongelante], [], fuga_bomba_agua, Coincidencias, Certeza),
    length(Coincidencias, 2),
    % 2 / 3 = 66.66% -> round(67)
    assertion(Certeza == 67).

test(ranking_heuristico_ordenado_mayor_a_menor) :-
    % Entrada clínica: tironeo, humo negro y código P0200 (circuito de inyectores)
    % inyector_tapado coincide en 3 de 5 (60%)
    % fallo_encendido_bujias solo coincide en tironeo (1 de 5 = 20%)
    findall(C-F, sugerir_diagnostico([tironeo_al_acelerar, humo_negro], [codigo_p0200], F, C), [TopC-TopF|Resto]),
    assertion(TopF == inyector_tapado),
    assertion(TopC == 60),
    % Verificar que toda la lista restante esté ordenada descendentemente por certeza
    forall(member(CertezaMenor-_, Resto),
           assertion(TopC >= CertezaMenor)).

test(robustez_entradas_duplicadas) :-
    % El usuario ingresa síntomas repetidos: no debe inflar la certeza
    evaluar_falla([humo_negro, humo_negro, humo_negro],
                  [codigo_p0200, codigo_p0200],
                  inyector_tapado, Coincidencias, Certeza),
    length(Coincidencias, 2),
    assertion(Certeza == 40),
    assertion(Certeza =< 100).

test(entradas_vacias_fallan_limpiamente) :-
    assertion(\+ diagnostico_estricto([], [], _)),
    assertion(\+ sugerir_diagnostico([], [], _, _)),
    assertion(\+ evaluar_falla([], [], _, _, _)).

test(monotonia_descendente_en_sugerencias) :-
    % Si hay múltiples fallas sugeridas, cada una debe tener certeza menor o igual a la anterior
    findall(C, sugerir_diagnostico([tironeo_al_acelerar], [check_engine], _, C), Certezas),
    assertion(Certezas \= []),
    verificar_descendente(Certezas).

verificar_descendente([_]) :- !.
verificar_descendente([C1, C2|Resto]) :-
    assertion(C1 >= C2),
    verificar_descendente([C2|Resto]).

test(diagnostico_nuevas_fallas_expandidas, [nondet]) :-
    % 1. Falla de batería (celda muerta)
    diagnostico_estricto(
        [chasquido_al_intentar_arrancar, tablero_parpadea_al_arrancar, dificultad_arranque],
        [testigo_bateria, codigo_p0562],
        FallaBat),
    assertion(FallaBat == bateria_celda_muerta),
    % 2. Fuga de vacío en admisión
    diagnostico_estricto(
        [silbido_en_motor, ralenti_inestable, motor_se_apaga_en_freno],
        [check_engine, codigo_p0171, codigo_p2279],
        FallaVacio),
    assertion(FallaVacio == fuga_vacio_admision),
    % 3. Banda de distribución desfasada
    diagnostico_estricto(
        [golpeteo_metalico_sincronizacion, motor_no_enciende, explosion_escape],
        [check_engine, codigo_p0016],
        FallaDist),
    assertion(FallaDist == banda_distribucion_desfasada),
    % 4. Obstrucción de tolva de enfriamiento (Bóxer aire)
    diagnostico_estricto(
        [sobrecalentamiento, olor_aceite_caliente_turbina, perdida_potencia],
        [testigo_temperatura],
        FallaTolva),
    assertion(FallaTolva == obstruccion_tolva_enfriamiento).

:- end_tests(diagnostico_motor).
