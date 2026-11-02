:- use_module(library(plunit)).
:- use_module('../src/kb/catalogos_kb').
:- use_module('../src/kb/vehiculos_kb').
:- use_module('../src/kb/topologia_kb').
:- use_module('../src/core/grafo_motor').

:- begin_tests(grafo_motor).

% Helper: verifica que ElementoA aparezca antes que ElementoB en Lista
precede_en_lista(ElementoA, ElementoB, Lista) :-
    once(nth0(IdxA, Lista, ElementoA)),
    once(nth0(IdxB, Lista, ElementoB)),
    assertion(IdxA < IdxB).

test(orden_fisico_estricto_bmw_bujias) :-
    % Valida la corrección del bug de description.md:
    % El despiece debe comenzar por la tolva superior y terminar en las bujías.
    plan_desensamble(bmw_325i, bujias, Pasos),
    Esperado = [tolva_microfiltro, barra_estructural, cubierta_motor, bobinas_ignicion, bujias],
    assertion(Pasos == Esperado).

test(precedencia_topologica_universal) :-
    % En cualquier vehículo y servicio, todo estorbo A que bloquee a B
    % debe tener un índice menor en la lista de desensamble
    forall((vehiculo(V, _, _, _), pieza_intervenible(P), vehiculo_soporta_pieza(V, P)),
           ( plan_desensamble(V, P, Pasos),
             forall((member(A, Pasos), member(B, Pasos), obstruye(V, A, B)),
                    precede_en_lista(A, B, Pasos)) )).

test(diamante_idempotencia_maxima_bujias_inyectores) :-
    % En un motor V6, cambiar bujías e inyectores comparte el pleno y la cubierta
    plan_desensamble_multiple(maxima_v6, [bujias, inyectores], Pasos),
    % Ninguna pieza debe repetirse
    list_to_set(Pasos, PasosUnicos),
    assertion(Pasos == PasosUnicos),
    % Las piezas compartidas deben aparecer una sola vez
    include(=(pleno_admision), Pasos, Plenos),
    include(=(cubierta_motor), Pasos, Cubiertas),
    length(Plenos, 1),
    length(Cubiertas, 1),
    % Precedencias clave del grafo diamante
    precede_en_lista(cubierta_motor, cuerpo_aceleracion, Pasos),
    precede_en_lista(cuerpo_aceleracion, pleno_admision, Pasos),
    precede_en_lista(mangueras_vacio, pleno_admision, Pasos),
    precede_en_lista(pleno_admision, bobinas_ignicion, Pasos),
    precede_en_lista(bobinas_ignicion, bujias, Pasos),
    precede_en_lista(pleno_admision, riel_inyectores, Pasos),
    precede_en_lista(riel_inyectores, inyectores, Pasos).

test(forester_boxer_perifericos_laterales) :-
    plan_desensamble(forester_bx, bujias, Pasos),
    precede_en_lista(bateria, bobinas_ignicion, Pasos),
    precede_en_lista(caja_filtro_aire, bobinas_ignicion, Pasos),
    precede_en_lista(deposito_limpiador, bobinas_ignicion, Pasos),
    precede_en_lista(bobinas_ignicion, bujias, Pasos).

test(inversibilidad_requiere_desmontar) :-
    % Averiguar en qué vehículos es necesario desmontar el pleno de admisión para bujías
    setof(Carro, requiere_desmontar(Carro, bujias, pleno_admision), Autos),
    assertion(Autos == [maxima_v6, odyssey_v6]).

test(inversibilidad_desensamble_chevy_bomba_agua) :-
    findall(Previa, requiere_desmontar(chevy_pop, bomba_agua, Previa), Previas),
    assertion(member(banda_distribucion, Previas)),
    assertion(member(banda_accesorios, Previas)).

test(ausencia_de_ciclos_en_todos_los_vehiculos) :-
    forall(vehiculo(V, _, _, _),
           assertion(\+ grafo_tiene_ciclo(V, _))).

:- end_tests(grafo_motor).
