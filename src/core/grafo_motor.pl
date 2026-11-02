:- module(grafo_motor, [
    requiere_desmontar/3,
    plan_desensamble/3,
    plan_desensamble_multiple/3,
    grafo_tiene_ciclo/2
]).

:- use_module('../kb/catalogos_kb').
:- use_module('../kb/vehiculos_kb').
:- use_module('../kb/topologia_kb').

/** <module> Motor de Inferencia Topológica sobre Grafos de Desensamble
 *
 * Implementa los algoritmos de resolución lógica sobre el grafo DAG de obstrucción:
 * 1. Clausura transitiva con prevención de ciclos e inversibilidad relacional (requiere_desmontar/3).
 * 2. Planificación de ruta física de desensamble mediante DFS post-orden con acumulador (plan_desensamble/3).
 * 3. Unificación idempotente de rutas para servicios múltiples (plan_desensamble_multiple/3).
 * 4. Detección formal de ciclos para auditoría del DAG (grafo_tiene_ciclo/2).
 */

% ==============================================================================
% 1. CLAUSURA TRANSITIVA RELACIONAL (Inversible)
% requiere_desmontar(?Carro, ?Objetivo, ?Previa).
% ==============================================================================
% Previa es un componente que debe desmontarse para poder acceder a Objetivo.
requiere_desmontar(Carro, Objetivo, Previa) :-
    requiere_desmontar_aux(Carro, Objetivo, Previa, [Objetivo]).

requiere_desmontar_aux(Carro, Objetivo, Previa, Visitados) :-
    obstruye(Carro, Previa, Objetivo),
    \+ member(Previa, Visitados).
requiere_desmontar_aux(Carro, Objetivo, Previa, Visitados) :-
    obstruye(Carro, Intermedia, Objetivo),
    \+ member(Intermedia, Visitados),
    requiere_desmontar_aux(Carro, Intermedia, Previa, [Intermedia|Visitados]).

% ==============================================================================
% 2. PLANIFICACIÓN DE DESENSAMBLE (Orden Topológico DFS Post-Orden)
% ==============================================================================

%% plan_desensamble(+Carro, +PiezaObjetivo, -PasosOrdenados) is det.
%
% Genera la secuencia física exacta de piezas a retirar para intervenir
% PiezaObjetivo. Aplica el principio DRY reutilizando plan_desensamble_multiple/3.
plan_desensamble(Carro, PiezaObjetivo, PasosOrdenados) :-
    plan_desensamble_multiple(Carro, [PiezaObjetivo], PasosOrdenados).

%% plan_desensamble_multiple(+Carro, +ListaObjetivos, -PasosOrdenados) is det.
%
% Calcula la secuencia ordenada de desensamble sin duplicar piezas compartidas
% (idempotente). Garantiza que si A obstruye a B, A aparece antes que B.
plan_desensamble_multiple(Carro, ListaObjetivos, PasosOrdenados) :-
    visitar_lista_nodos(Carro, ListaObjetivos, [], [], PasosOrdenados),
    !.

% Itera secuencialmente sobre una lista de nodos
visitar_lista_nodos(_, [], _, Acumulador, Acumulador).
visitar_lista_nodos(Carro, [Nodo|Resto], EnCamino, AcumIn, AcumOut) :-
    visitar_nodo(Carro, Nodo, EnCamino, AcumIn, AcumIntermedio),
    visitar_lista_nodos(Carro, Resto, EnCamino, AcumIntermedio, AcumOut).

% Visita un nodo en DFS
visitar_nodo(_, Nodo, _, AcumIn, AcumIn) :-
    % Si ya fue desmontado previamente, no se vuelve a procesar ni a agregar
    member(Nodo, AcumIn),
    !.
visitar_nodo(Carro, Nodo, EnCamino, _, _) :-
    % Salvaguarda: si está en el camino activo, hay un ciclo en el grafo
    member(Nodo, EnCamino),
    !,
    throw(error(ciclo_detectado(Carro, Nodo, EnCamino),
                context(plan_desensamble_multiple/3, 'Ciclo en el grafo de desensamble'))).
visitar_nodo(Carro, Nodo, EnCamino, AcumIn, AcumOut) :-
    % Recolectar todos los estorbos inmediatos que bloquean a Nodo
    findall(Estorbo, obstruye(Carro, Estorbo, Nodo), Estorbos),
    % Desmontar primero todos los estorbos (post-orden)
    visitar_lista_nodos(Carro, Estorbos, [Nodo|EnCamino], AcumIn, AcumConEstorbos),
    % Agregar el nodo al final una vez despejado el camino
    append(AcumConEstorbos, [Nodo], AcumOut).

% ==============================================================================
% 3. DETECTOR DE CICLOS (Para validación estática del DAG)
% grafo_tiene_ciclo(+Carro, -Ciclo)
% ==============================================================================
grafo_tiene_ciclo(Carro, Ciclo) :-
    vehiculo(Carro, _, _, _),
    nodo_del_grafo(Carro, Inicio),
    buscar_ciclo_dfs(Carro, Inicio, [Inicio], CicloInvertido),
    reverse(CicloInvertido, Ciclo).

nodo_del_grafo(Carro, Nodo) :-
    setof(N, (obstruye(Carro, N, _) ; obstruye(Carro, _, N)), Nodos),
    member(Nodo, Nodos).

buscar_ciclo_dfs(Carro, Actual, Visitados, [Siguiente|Segmento]) :-
    obstruye(Carro, Actual, Siguiente),
    member(Siguiente, Visitados),
    !,
    recortar_hasta(Siguiente, Visitados, Segmento).
buscar_ciclo_dfs(Carro, Actual, Visitados, Ciclo) :-
    obstruye(Carro, Actual, Siguiente),
    \+ member(Siguiente, Visitados),
    buscar_ciclo_dfs(Carro, Siguiente, [Siguiente|Visitados], Ciclo).

recortar_hasta(Target, [Target|_], [Target]) :- !.
recortar_hasta(Target, [X|Resto], [X|Sub]) :-
    recortar_hasta(Target, Resto, Sub).
