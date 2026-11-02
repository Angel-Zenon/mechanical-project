:- use_module(library(plunit)).
:- use_module('../src/kb/catalogos_kb').
:- use_module('../src/kb/vehiculos_kb').
:- use_module('../src/kb/topologia_kb').
:- use_module('../src/kb/fallas_kb').
:- use_module('../src/core/grafo_motor').

:- begin_tests(kb_integridad).

test(integridad_vehiculo_en_obstruye) :-
    % Todo vehículo mencionado en obstruye/3 debe existir en vehiculo/4
    forall(obstruye(V, _, _),
           assertion(vehiculo(V, _, _, _))).

test(integridad_piezas_en_maniobras) :-
    % Toda pieza (estorbo u objetivo) en obstruye/3 debe estar en maniobra/3
    forall(obstruye(_, Estorbo, Objetivo),
           ( assertion(maniobra(Estorbo, _, _)),
             assertion(maniobra(Objetivo, _, _)) )).

test(coherencia_arquitectura_piezas) :-
    % Toda relación obstruye/3 debe respetar las restricciones mecánicas del auto
    forall(obstruye(V, Estorbo, Objetivo),
           ( assertion(vehiculo_soporta_pieza(V, Estorbo)),
             assertion(vehiculo_soporta_pieza(V, Objetivo)) )).

test(irreflexividad_inmediata) :-
    % Ninguna pieza puede obstruirse a sí misma
    assertion(\+ (obstruye(_, X, X))).

test(antisimetria_inmediata) :-
    % No deben existir ciclos inmediatos de orden 2 (A obstruye B y B obstruye A)
    assertion(\+ (obstruye(V, X, Y), obstruye(V, Y, X))).

test(cobertura_total_10_vehiculos) :-
    % Los 10 vehículos declarados deben tener al menos una regla topológica
    forall(vehiculo(V, _, _, _),
           assertion(obstruye(V, _, _))).

test(servicios_clave_cubiertos_por_vehiculo) :-
    % Todos los autos deben tener ruta hacia bujias
    forall(vehiculo(V, _, _, _),
           assertion(obstruye(V, _, bujias))).

test(ausencia_de_ciclos_arbitrarios_en_10_vehiculos) :-
    % Ningún vehículo puede contener ciclos de cualquier longitud en su grafo
    forall(vehiculo(V, _, _, _),
           assertion(\+ grafo_tiene_ciclo(V, _))).

test(integridad_fallas_piezas_en_catalogo) :-
    % Toda pieza asociada a una falla debe existir en maniobra/3
    forall(falla_pieza(_, Pieza),
           assertion(maniobra(Pieza, _, _))).

test(integridad_fallas_sintomas_en_catalogo) :-
    % Todo síntoma asociado a una falla debe existir en sintoma_catalogo/2
    forall(falla_sintoma(_, Sintoma),
           assertion(sintoma_catalogo(Sintoma, _))).

test(integridad_fallas_testigos_en_catalogo) :-
    % Todo testigo/código asociado a una falla debe existir en testigo_catalogo/2
    forall(falla_testigo(_, Testigo),
           assertion(testigo_catalogo(Testigo, _))).

test(fallas_con_evidencia_no_vacia) :-
    % Toda falla debe tener al menos un síntoma o testigo para evitar división entre cero
    forall(falla_pieza(Falla, _),
           ( findall(S, falla_sintoma(Falla, S), Sintomas),
             findall(T, falla_testigo(Falla, T), Testigos),
             append(Sintomas, Testigos, Evidencia),
             assertion(Evidencia \= []) )).

:- end_tests(kb_integridad).
