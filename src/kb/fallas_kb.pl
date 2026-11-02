:- module(fallas_kb, [
    falla_pieza/2,
    falla_sintoma/2,
    falla_testigo/2
]).

:- use_module(catalogos_kb).

/** <module> Base de Conocimiento de Diagnóstico Automotriz
 *
 * Mapea las fallas mecánicas y electrónicas conocidas con sus componentes
 * físicos asociados (falla_pieza/2), su sintomatología perceptible (falla_sintoma/2)
 * y los testigos o códigos de diagnóstico OBD-II (falla_testigo/2).
 */

% ==============================================================================
% 1. VINCULACIÓN FALLA -> COMPONENTE FÍSICO QUE SE DEBE INTERVENIR
% falla_pieza(?IdFalla, ?PiezaObjetivo).
% ==============================================================================
falla_pieza(fallo_encendido_bujias,   bujias).
falla_pieza(inyector_tapado,          inyectores).
falla_pieza(falla_carga_alternador,   alternador).
falla_pieza(fuga_bomba_agua,          bomba_agua).
falla_pieza(cuerpo_aceleracion_sucio, cuerpo_aceleracion).
falla_pieza(falla_bobina_encendido,   bobinas_ignicion).
falla_pieza(carburador_descalibrado,  carburador).
falla_pieza(desgaste_banda_accesorios, banda_accesorios).

% ==============================================================================
% 2. SÍNTOMAS ASOCIADOS A CADA FALLA
% falla_sintoma(?IdFalla, ?IdSintoma).
% ==============================================================================
% Fallo de encendido por bujías desgastadas
falla_sintoma(fallo_encendido_bujias, tironeo_al_acelerar).
falla_sintoma(fallo_encendido_bujias, ralenti_inestable).
falla_sintoma(fallo_encendido_bujias, alto_consumo_gasolina).

% Inyector obstruido o con goteo
falla_sintoma(inyector_tapado, perdida_potencia).
falla_sintoma(inyector_tapado, humo_negro).
falla_sintoma(inyector_tapado, tironeo_al_acelerar).

% Falla del sistema de carga / alternador
falla_sintoma(falla_carga_alternador, luces_tenues).
falla_sintoma(falla_carga_alternador, dificultad_arranque).

% Fuga o avería en bomba de agua
falla_sintoma(fuga_bomba_agua, sobrecalentamiento).
falla_sintoma(fuga_bomba_agua, charco_anticongelante).

% Cuerpo de aceleración sucio o descalibrado
falla_sintoma(cuerpo_aceleracion_sucio, ralenti_inestable).
falla_sintoma(cuerpo_aceleracion_sucio, dificultad_arranque).

% Falla en bobina individual de ignición
falla_sintoma(falla_bobina_encendido, tironeo_al_acelerar).
falla_sintoma(falla_bobina_encendido, perdida_potencia).
falla_sintoma(falla_bobina_encendido, motor_no_enciende).

% Carburador descalibrado (autos clásicos / carburados)
falla_sintoma(carburador_descalibrado, ralenti_inestable).
falla_sintoma(carburador_descalibrado, humo_negro).
falla_sintoma(carburador_descalibrado, olor_gasolina).

% Banda de accesorios floja o desgastada
falla_sintoma(desgaste_banda_accesorios, chirrido_motor).
falla_sintoma(desgaste_banda_accesorios, luces_tenues).

% ==============================================================================
% 3. TESTIGOS DE TABLERO Y CÓDIGOS OBD-II ASOCIADOS
% falla_testigo(?IdFalla, ?IdTestigo).
% ==============================================================================
falla_testigo(fallo_encendido_bujias,   check_engine).
falla_testigo(fallo_encendido_bujias,   codigo_p0300).

falla_testigo(inyector_tapado,          check_engine).
falla_testigo(inyector_tapado,          codigo_p0200).

falla_testigo(falla_carga_alternador,   testigo_bateria).

falla_testigo(fuga_bomba_agua,          testigo_temperatura).

falla_testigo(cuerpo_aceleracion_sucio, check_engine).
falla_testigo(cuerpo_aceleracion_sucio, codigo_p0505).

falla_testigo(falla_bobina_encendido,   check_engine).
falla_testigo(falla_bobina_encendido,   codigo_p0300).

falla_testigo(desgaste_banda_accesorios, testigo_bateria).
