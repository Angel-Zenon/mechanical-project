:- use_module(library(plunit)).

/** <module> Runner Central de Pruebas Automatizadas (plunit)
 *
 * Centraliza la carga y ejecución de todas las suites de prueba unitarias,
 * de integridad y de integración del sistema experto.
 */

% Suites de prueba registradas
:- consult('test_catalogos_vehiculos.plt').
:- consult('test_kb_integridad.plt').
:- consult('test_grafo_motor.plt').
:- consult('test_cotizador_motor.plt').
:- consult('test_diagnostico_motor.plt').

% Predicado de ejecución para scripts de CI / línea de comandos
ejecutar_tests :-
    run_tests.
