:- module(reporte_cli, [
    menu/0,
    menu_principal/0,
    listar_sintomas_cli/0,
    listar_testigos_cli/0,
    listar_vehiculos_cli/0,
    atender_cliente_cli/3,
    comparar_vehiculos_cli/4,
    demo_comparativa_bujias/0,
    demo_orden_multiple/0,
    imprimir_orden_trabajo/1,
    imprimir_diagnostico/1,
    imprimir_comparativa_vehiculos/1
]).

:- use_module('../kb/catalogos_kb').
:- use_module('../kb/vehiculos_kb').
:- use_module('../service/taller_servicio').

/** <module> Interfaz de Usuario de Consola, Menú Numérico y Generación de Reportes
 *
 * Capa de presentación (UI / CLI). Único módulo del proyecto con responsabilidades
 * de entrada/salida (I/O) y formateo de texto mediante format/2 y write.
 * Cumple estrictamente con SRP al mantener aislada la lógica de visualización.
 */

% ==============================================================================
% 1. MENÚ PRINCIPAL INTERACTIVO POR NÚMEROS (1-4)
% ==============================================================================

%% menu is det.
menu :-
    menu_principal.

%% menu_principal is det.
%
% Bucle interactivo de consola para seleccionar acciones mediante dígitos 1-5.
menu_principal :-
    repeat,
    format('~n================================================================================~n', []),
    format('        SISTEMA EXPERTO DE DIAGNOSTICO AUTOMOTRIZ Y COTIZACION DINAMICA~n', []),
    format('================================================================================~n', []),
    format(' Seleccione una opcion ingresando su numero (1-5):~n~n', []),
    format('  [1] Listar catalogo de vehiculos (10 modelos, arquitectura y tarifas)~n', []),
    format('  [2] Listar catalogo de sintomas observables disponibles~n', []),
    format('  [3] Listar catalogo de testigos de tablero y codigos OBD-II disponibles~n', []),
    format('  [4] Diagnosticar vehiculo y cotizar orden de trabajo (Atender cliente)~n', []),
    format('  [5] Comparar 2 vehiculos (elegir servicio en cada uno: piezas, tiempo y precio)~n', []),
    format('  [0] Salir del sistema~n', []),
    format('================================================================================~n', []),
    format('Ingrese su opcion [0-5]: ', []),
    read_line_to_string(user_input, RawOp),
    normalize_space(string(CleanOp), RawOp),
    procesar_opcion(CleanOp, Continuar),
    Continuar == terminar,
    !.

procesar_opcion("1", continuar) :-
    listar_vehiculos_cli.
procesar_opcion("2", continuar) :-
    listar_sintomas_cli.
procesar_opcion("3", continuar) :-
    listar_testigos_cli.
procesar_opcion("4", continuar) :-
    atender_cliente_interactivo.
procesar_opcion("5", continuar) :-
    comparar_vehiculos_interactivo.
procesar_opcion("0", terminar) :-
    format('~nSaliendo del sistema experto automotriz. Hasta pronto.~n~n', []).
procesar_opcion("salir", terminar) :-
    format('~nSaliendo del sistema experto automotriz. Hasta pronto.~n~n', []).
procesar_opcion(_, continuar) :-
    format('~n[!] Opcion no valida. Por favor ingrese un numero del 1 al 5 (o 0 para salir).~n', []).

% ==============================================================================
% 2. LISTADOS DE CATÁLOGOS (Vehículos, Síntomas y Testigos)
% ==============================================================================

%% listar_vehiculos_cli is det.
listar_vehiculos_cli :-
    format('~n================================================================================~n', []),
    format('                      CATALOGO DE 10 VEHICULOS EN EL SISTEMA~n', []),
    format('================================================================================~n', []),
    format(' ~w~t~15| ~w~t~48| ~w~t~68| ~w~n', ['ID', 'NOMBRE', 'ARQUITECTURA', 'TARIFA']),
    format('--------------------------------------------------------------------------------~n', []),
    forall(vehiculo(Id, Nombre, Arq, Factor),
           format(' ~w~t~15| ~w~t~48| ~w~t~68| x~2f~n', [Id, Nombre, Arq, Factor])),
    format('================================================================================~n', []).

%% listar_sintomas_cli is det.
listar_sintomas_cli :-
    format('~n================================================================================~n', []),
    format('                   CATALOGO DE SINTOMAS OBSERVABLES DISPONIBLES~n', []),
    format('================================================================================~n', []),
    format(' ~w~t~4| ~w~t~32| ~w~n', ['#', 'ID EN PROLOG', 'DESCRIPCION CLINICA']),
    format('--------------------------------------------------------------------------------~n', []),
    findall(S-Desc, sintoma_catalogo(S, Desc), Sintomas),
    imprimir_elementos_catalogo(Sintomas, 1),
    format('================================================================================~n', []).

%% listar_testigos_cli is det.
listar_testigos_cli :-
    format('~n================================================================================~n', []),
    format('            CATALOGO DE TESTIGOS DE TABLERO Y CODIGOS OBD-II DISPONIBLES~n', []),
    format('================================================================================~n', []),
    format(' ~w~t~4| ~w~t~32| ~w~n', ['#', 'ID EN PROLOG', 'DESCRIPCION / SIGNIFICADO']),
    format('--------------------------------------------------------------------------------~n', []),
    findall(T-Desc, testigo_catalogo(T, Desc), Testigos),
    imprimir_elementos_catalogo(Testigos, 1),
    format('================================================================================~n', []).

imprimir_elementos_catalogo([], _).
imprimir_elementos_catalogo([Id-Desc|Resto], Num) :-
    format(' ~w~t~4| ~w~t~32| ~w~n', [Num, Id, Desc]),
    Siguiente is Num + 1,
    imprimir_elementos_catalogo(Resto, Siguiente).

% ==============================================================================
% 3. FLUJO INTERACTIVO DE ATENCIÓN A CLIENTES
% ==============================================================================

vehiculo_por_indice(1,  tsuru_gs2).
vehiculo_por_indice(2,  chevy_pop).
vehiculo_por_indice(3,  civic_ex).
vehiculo_por_indice(4,  mazda3_sky).
vehiculo_por_indice(5,  maxima_v6).
vehiculo_por_indice(6,  odyssey_v6).
vehiculo_por_indice(7,  forester_bx).
vehiculo_por_indice(8,  vocho_sedan).
vehiculo_por_indice(9,  lobo_v8).
vehiculo_por_indice(10, bmw_325i).

resolver_entrada_vehiculo(Str, Carro) :-
    catch(term_string(Term, Str), _, fail),
    (   integer(Term),
        vehiculo_por_indice(Term, Carro)
    ->  true
    ;   atom(Term),
        vehiculo(Term, _, _, _)
    ->  Carro = Term
    ).

atender_cliente_interactivo :-
    format('~n--------------------------------------------------------------------------------~n', []),
    format('                    DIAGNOSTICO Y COTIZACION DE VEHICULO~n', []),
    format('--------------------------------------------------------------------------------~n', []),
    format('Modelos de vehiculo:~n', []),
    format('  [1] tsuru_gs2    [2] chevy_pop     [3] civic_ex      [4] mazda3_sky    [5] maxima_v6~n', []),
    format('  [6] odyssey_v6   [7] forester_bx   [8] vocho_sedan   [9] lobo_v8      [10] bmw_325i~n~n', []),
    format('Seleccione el vehiculo (ingrese numero 1-10 o nombre): ', []),
    read_line_to_string(user_input, RawCar),
    normalize_space(string(CleanCar), RawCar),
    (   resolver_entrada_vehiculo(CleanCar, Carro)
    ->  format('Vehiculo seleccionado: ~w~n~n', [Carro]),
        format('Ingrese sintomas separados por coma (ej. tironeo_al_acelerar, ralenti_inestable)~n', []),
        format('o presione Enter para ninguno:~n> ', []),
        read_line_to_string(user_input, RawSintomas),
        normalize_space(string(CleanSintomas), RawSintomas),
        parsear_entrada_lista(CleanSintomas, Sintomas),
        format('~nIngrese testigos / codigos OBD-II separados por coma (ej. check_engine, codigo_p0300)~n', []),
        format('o presione Enter para ninguno:~n> ', []),
        read_line_to_string(user_input, RawTestigos),
        normalize_space(string(CleanTestigos), RawTestigos),
        parsear_entrada_lista(CleanTestigos, Testigos),
        atender_cliente_cli(Carro, Sintomas, Testigos)
    ;   format('[!] Opcion de vehiculo invalida: "~w"~n', [CleanCar])
    ).

parsear_entrada_lista("", []) :- !.
parsear_entrada_lista("[]", []) :- !.
parsear_entrada_lista("ninguno", []) :- !.
parsear_entrada_lista("ninguna", []) :- !.
parsear_entrada_lista(Str, Lista) :-
    (   sub_string(Str, 0, 1, _, "[")
    ->  TermStr = Str
    ;   string_concat("[", Str, Temp),
        string_concat(Temp, "]", TermStr)
    ),
    catch(term_string(ListaTerm, TermStr), _, fail),
    (   is_list(ListaTerm)
    ->  Lista = ListaTerm
    ;   Lista = [ListaTerm]
    ),
    !.
parsear_entrada_lista(_, []) :-
    format('[!] Formato no reconocido. Se usara lista vacia [].~n', []).

%% atender_cliente_cli(+Carro, +Sintomas, +Testigos) is det.
atender_cliente_cli(Carro, Sintomas, Testigos) :-
    format('~n>>> PROCESANDO DIAGNOSTICO PARA VEHICULO: ~w <<<~n', [Carro]),
    format('Sintomas reportados: ~w~n', [Sintomas]),
    format('Testigos / Codigos:  ~w~n', [Testigos]),
    findall(Diag, diagnosticar_y_cotizar(Carro, Sintomas, Testigos, _, Diag), Diagnosticos),
    (   Diagnosticos == []
    ->  format('~n[!] No se encontraron fallas compatibles con esa sintomatologia para este modelo.~n~n', [])
    ;   forall(member(D, Diagnosticos), imprimir_diagnostico(D))
    ).

% ==============================================================================
% 4. FORMATEO DE REPORTES Y DEMOSTRACIONES TOPOLÓGICAS
% ==============================================================================

%% imprimir_orden_trabajo(+DictOrden) is det.
imprimir_orden_trabajo(Orden) :-
    format('~n================================================================================~n', []),
    format('                       ORDEN DE SERVICIO AUTOMOTRIZ~n', []),
    format('================================================================================~n', []),
    format('Vehiculo:      ~w (~w)~n', [Orden.vehiculo_nombre, Orden.vehiculo_id]),
    format('Arquitectura:  ~w~n', [Orden.arquitectura]),
    format('Factor Tarifa: x~2f~n', [Orden.factor_tarifa]),
    format('Servicio(s):   ~w~n', [Orden.servicios_solicitados]),
    format('--------------------------------------------------------------------------------~n', []),
    format(' ~w~t~4| ~w~t~35| ~w~t~52| ~w~n', ['#', 'PIEZA / MANIOBRA', 'COSTO BASE', 'TIEMPO']),
    format('--------------------------------------------------------------------------------~n', []),
    imprimir_pasos(Orden.desglose_maniobras, 1),
    format('--------------------------------------------------------------------------------~n', []),
    Horas is Orden.tiempo_total_min / 60,
    format('Subtotal Base (Mano de Obra):~t $~w MXN~48|   (~w min / ~2f hrs)~n',
           [Orden.subtotal_base_mxn, Orden.tiempo_total_min, Horas]),
    format('Factor de Complejidad:~t x~2f~48|~n', [Orden.factor_tarifa]),
    format('--------------------------------------------------------------------------------~n', []),
    format('COSTO TOTAL ESTIMADO:~t $~w MXN~48|~n', [Orden.costo_total_mxn]),
    format('================================================================================~n', []).

imprimir_pasos([], _).
imprimir_pasos([paso_costo(Pieza, Costo, Tiempo)|Resto], Num) :-
    format(' ~w~t~4| ~w~t~35| $~w MXN~t~52| ~w min~n', [Num, Pieza, Costo, Tiempo]),
    NumSiguiente is Num + 1,
    imprimir_pasos(Resto, NumSiguiente).

%% imprimir_diagnostico(+DictDiagnostico) is det.
imprimir_diagnostico(Diag) :-
    format('~n================================================================================~n', []),
    format('                   RESULTADO DE DIAGNOSTICO CLINICO~n', []),
    format('================================================================================~n', []),
    (   Diag.modo == confirmado
    ->  format('Dictamen:      [CONFIRMADO] (100% de evidencia coincidente)~n', [])
    ;   format('Dictamen:      [SUGERENCIA CLINICA] (~w% de certeza heuristica)~n', [Diag.certeza])
    ),
    format('Falla:         ~w~n', [Diag.falla]),
    format('Componente:    ~w~n', [Diag.pieza]),
    imprimir_orden_trabajo(Diag.orden_servicio).

%% demo_comparativa_bujias is det.
demo_comparativa_bujias :-
    format('~n********************************************************************************~n', []),
    format('    DEMOSTRACION: COMPARATIVA DE ACCESIBILIDAD PARA CAMBIO DE BUJIAS~n', []),
    format('********************************************************************************~n', []),
    Modelos = [tsuru_gs2, civic_ex, maxima_v6, forester_bx, bmw_325i],
    forall(member(V, Modelos),
           ( generar_orden_trabajo(V, [bujias], Orden),
             imprimir_orden_trabajo(Orden) )).

%% demo_orden_multiple is det.
demo_orden_multiple :-
    format('~n********************************************************************************~n', []),
    format('    DEMOSTRACION: ORDEN MULTIPLE EN V6 (OPTIMIZACION DE PASOS COMPARTIDOS)~n', []),
    format('********************************************************************************~n', []),
    generar_orden_trabajo(maxima_v6, [bujias, inyectores], Orden),
    imprimir_orden_trabajo(Orden).

% ==============================================================================
% 5. COMPARADOR DE 2 VEHÍCULOS (PIEZAS A DESMONTAR, TIEMPO Y PRECIO)
% ==============================================================================

mostrar_servicios_compatibles(Carro) :-
    findall(P, (pieza_intervenible(P), vehiculo_soporta_pieza(Carro, P)), Servicios),
    format('Servicios disponibles para ~w:~n  ~w~n', [Carro, Servicios]).

comparar_vehiculos_interactivo :-
    format('~n--------------------------------------------------------------------------------~n', []),
    format('        COMPARADOR DE 2 VEHICULOS (PIEZAS A DESMONTAR, TIEMPO Y PRECIO)~n', []),
    format('--------------------------------------------------------------------------------~n', []),
    format('Modelos de vehiculo:~n', []),
    format('  [1] tsuru_gs2    [2] chevy_pop     [3] civic_ex      [4] mazda3_sky    [5] maxima_v6~n', []),
    format('  [6] odyssey_v6   [7] forester_bx   [8] vocho_sedan   [9] lobo_v8      [10] bmw_325i~n~n', []),
    format('Seleccione el PRIMER vehiculo (ingrese numero 1-10 o nombre): ', []),
    read_line_to_string(user_input, RawCar1),
    normalize_space(string(CleanCar1), RawCar1),
    (   resolver_entrada_vehiculo(CleanCar1, Carro1)
    ->  format('-> Auto 1 seleccionado: ~w~n', [Carro1]),
        mostrar_servicios_compatibles(Carro1),
        format('Ingrese servicio(s) a realizar en ~w (ej. bujias o bujias, inyectores):~n> ', [Carro1]),
        read_line_to_string(user_input, RawServ1),
        normalize_space(string(CleanServ1), RawServ1),
        parsear_entrada_lista(CleanServ1, Servicios1),
        (   Servicios1 == []
        ->  format('[!] Debe indicar al menos un servicio para el primer vehiculo.~n', [])
        ;   format('~nSeleccione el SEGUNDO vehiculo (ingrese numero 1-10 o nombre): ', []),
            read_line_to_string(user_input, RawCar2),
            normalize_space(string(CleanCar2), RawCar2),
            (   resolver_entrada_vehiculo(CleanCar2, Carro2)
            ->  format('-> Auto 2 seleccionado: ~w~n', [Carro2]),
                mostrar_servicios_compatibles(Carro2),
                format('Ingrese servicio(s) a realizar en ~w~n', [Carro2]),
                format('(o presione Enter para usar el mismo servicio del Auto 1: ~w):~n> ', [Servicios1]),
                read_line_to_string(user_input, RawServ2),
                normalize_space(string(CleanServ2), RawServ2),
                (   CleanServ2 == ""
                ->  Servicios2 = Servicios1
                ;   parsear_entrada_lista(CleanServ2, Servicios2)
                ),
                comparar_vehiculos_cli(Carro1, Servicios1, Carro2, Servicios2)
            ;   format('[!] Opcion de segundo vehiculo invalida: "~w"~n', [CleanCar2])
            )
        )
    ;   format('[!] Opcion de primer vehiculo invalida: "~w"~n', [CleanCar1])
    ).

%% comparar_vehiculos_cli(+Carro1, +Servicios1, +Carro2, +Servicios2) is det.
comparar_vehiculos_cli(Carro1, Servicios1, Carro2, Servicios2) :-
    (   comparar_vehiculos_servicio(Carro1, Servicios1, Carro2, Servicios2, Comp)
    ->  imprimir_comparativa_vehiculos(Comp)
    ;   format('~n[!] No fue posible realizar la comparativa.~n', []),
        (   \+ generar_orden_trabajo(Carro1, Servicios1, _)
        ->  format('    -> El vehiculo ~w no soporta alguno de los servicios: ~w~n', [Carro1, Servicios1])
        ;   true
        ),
        (   \+ generar_orden_trabajo(Carro2, Servicios2, _)
        ->  format('    -> El vehiculo ~w no soporta alguno de los servicios: ~w~n', [Carro2, Servicios2])
        ;   true
        )
    ).

%% imprimir_comparativa_vehiculos(+DictComparativa) is det.
imprimir_comparativa_vehiculos(Comp) :-
    O1 = Comp.orden_1,
    O2 = Comp.orden_2,
    R  = Comp.resumen,
    H1 is O1.tiempo_total_min / 60,
    H2 is O2.tiempo_total_min / 60,
    HDiff is R.diferencia_tiempo_min / 60,
    format('~n================================================================================~n', []),
    format('             COMPARATIVA DE DESENSAMBLE, TIEMPO Y PRECIO (2 AUTOS)~n', []),
    format('================================================================================~n', []),
    format(' [AUTO 1] ~w (~w) | Arq: ~w | Tarifa: x~2f~n',
           [O1.vehiculo_nombre, O1.vehiculo_id, O1.arquitectura, O1.factor_tarifa]),
    format('          Servicio(s) elegido(s): ~w~n', [O1.servicios_solicitados]),
    format('--------------------------------------------------------------------------------~n', []),
    format(' ~w~t~4| ~w~t~35| ~w~t~52| ~w~n', ['#', 'PIEZAS A DESMONTAR (AUTO 1)', 'COSTO BASE', 'TIEMPO']),
    format('--------------------------------------------------------------------------------~n', []),
    imprimir_pasos(O1.desglose_maniobras, 1),
    format('================================================================================~n', []),
    format(' [AUTO 2] ~w (~w) | Arq: ~w | Tarifa: x~2f~n',
           [O2.vehiculo_nombre, O2.vehiculo_id, O2.arquitectura, O2.factor_tarifa]),
    format('          Servicio(s) elegido(s): ~w~n', [O2.servicios_solicitados]),
    format('--------------------------------------------------------------------------------~n', []),
    format(' ~w~t~4| ~w~t~35| ~w~t~52| ~w~n', ['#', 'PIEZAS A DESMONTAR (AUTO 2)', 'COSTO BASE', 'TIEMPO']),
    format('--------------------------------------------------------------------------------~n', []),
    imprimir_pasos(O2.desglose_maniobras, 1),
    format('================================================================================~n', []),
    format('                     ANALISIS TOPOLOGICO DE PIEZAS~n', []),
    format('--------------------------------------------------------------------------------~n', []),
    format(' Piezas comunes en ambos:       ~w~n', [R.piezas_comunes]),
    format(' Exclusivas Auto 1 (~w):~t~32| ~w~n', [O1.vehiculo_id, R.piezas_exclusivas_1]),
    format(' Exclusivas Auto 2 (~w):~t~32| ~w~n', [O2.vehiculo_id, R.piezas_exclusivas_2]),
    format('================================================================================~n', []),
    format('                 TABLA COMPARATIVA: PIEZAS, TIEMPO Y PRECIO~n', []),
    format('--------------------------------------------------------------------------------~n', []),
    format(' ~w~t~26| ~w~t~46| ~w~t~66| ~w~n',
           ['METRICA', O1.vehiculo_id, O2.vehiculo_id, 'DIFERENCIA']),
    format('--------------------------------------------------------------------------------~n', []),
    format(' ~w~t~26| ~w piezas~t~46| ~w piezas~t~66| ~w piezas~n',
           ['Piezas a desmontar', R.num_pasos_1, R.num_pasos_2, R.diferencia_pasos]),
    format(' ~w~t~26| ~w min (~2f h)~t~46| ~w min (~2f h)~t~66| ~w min (~2f h)~n',
           ['Tiempo total estimado', O1.tiempo_total_min, H1, O2.tiempo_total_min, H2, R.diferencia_tiempo_min, HDiff]),
    format(' ~w~t~26| $~w MXN~t~46| $~w MXN~t~66| --~n',
           ['Subtotal mano obra base', O1.subtotal_base_mxn, O2.subtotal_base_mxn]),
    format(' ~w~t~26| x~2f~t~46| x~2f~t~66| --~n',
           ['Factor complejidad', O1.factor_tarifa, O2.factor_tarifa]),
    format('--------------------------------------------------------------------------------~n', []),
    format(' ~w~t~26| $~w MXN~t~46| $~w MXN~t~66| $~w MXN~n',
           ['PRECIO TOTAL ESTIMADO', O1.costo_total_mxn, O2.costo_total_mxn, R.diferencia_costo_mxn]),
    format('--------------------------------------------------------------------------------~n', []),
    format(' -> Mas rapido de intervenir: ~w~n', [R.mas_rapido]),
    format(' -> Mas economico en taller:  ~w~n', [R.mas_economico]),
    format('================================================================================~n', []).
