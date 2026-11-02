/** <module> Punto de Entrada Principal e Interactivo del Sistema Experto Automotriz
 *
 * Carga todos los módulos del sistema y proporciona el menú interactivo
 * numérico para diagnósticos, cotizaciones y demostraciones.
 *
 * Uso en terminal:
 *   swipl run.pl
 */

% Carga de módulos de la aplicación
:- use_module('src/kb/catalogos_kb').
:- use_module('src/kb/vehiculos_kb').
:- use_module('src/kb/topologia_kb').
:- use_module('src/kb/fallas_kb').
:- use_module('src/core/grafo_motor').
:- use_module('src/core/cotizador_motor').
:- use_module('src/core/diagnostico_motor').
:- use_module('src/service/taller_servicio').
:- use_module('src/ui/reporte_cli').

% Banner interactivo inicial
:- initialization((
    format('~n================================================================================~n', []),
    format('        SISTEMA EXPERTO DE DIAGNOSTICO AUTOMOTRIZ Y COTIZACION DINAMICA~n', []),
    format('                       (SWI-Prolog Declarativo Modular)~n', []),
    format('================================================================================~n', []),
    format(' Para iniciar el menu interactivo por teclado (opciones 1-4), escriba:~n~n', []),
    format('    ?- menu.~n~n', []),
    format(' Opciones disponibles en el sistema:~n', []),
    format('  [1] listar_vehiculos_cli.  - Catalogo de 10 vehiculos, motor y tarifas~n', []),
    format('  [2] listar_sintomas_cli.   - Catalogo de sintomas observables~n', []),
    format('  [3] listar_testigos_cli.   - Catalogo de testigos de tablero y OBD-II~n', []),
    format('  [4] atender_cliente_cli(Auto, Sintomas, Testigos). - Diagnostico y cotizacion~n', []),
    format('================================================================================~n~n', [])
), now).
