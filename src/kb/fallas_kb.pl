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
falla_pieza(fallo_encendido_bujias,          bujias).
falla_pieza(inyector_tapado,                 inyectores).
falla_pieza(falla_carga_alternador,          alternador).
falla_pieza(fuga_bomba_agua,                 bomba_agua).
falla_pieza(cuerpo_aceleracion_sucio,        cuerpo_aceleracion).
falla_pieza(falla_bobina_encendido,          bobinas_ignicion).
falla_pieza(carburador_descalibrado,         carburador).
falla_pieza(desgaste_banda_accesorios,       banda_accesorios).
falla_pieza(cables_bujia_aislamiento_danado, cables_bujia).
falla_pieza(bateria_celda_muerta,            bateria).
falla_pieza(banda_distribucion_desfasada,    banda_distribucion).
falla_pieza(fuga_vacio_admision,             mangueras_vacio).
falla_pieza(fisura_pleno_admision,           pleno_admision).
falla_pieza(perdida_presion_riel_combustible,riel_inyectores).
falla_pieza(filtro_aire_saturado,            caja_filtro_aire).
falla_pieza(obstruccion_tolva_enfriamiento,  tolva_enfriamiento).
falla_pieza(cortocircuito_bobina_primaria,   bobinas_ignicion).
falla_pieza(inyector_goteo_abierto,          inyectores).

% ==============================================================================
% 2. SÍNTOMAS ASOCIADOS A CADA FALLA
% falla_sintoma(?IdFalla, ?IdSintoma).
% ==============================================================================
% Fallo de encendido por bujías desgastadas
falla_sintoma(fallo_encendido_bujias, tironeo_al_acelerar).
falla_sintoma(fallo_encendido_bujias, ralenti_inestable).
falla_sintoma(fallo_encendido_bujias, alto_consumo_gasolina).

% Inyector obstruido o con falta de caudal
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

% Falla en bobina individual de ignición (circuito secundario / chispa débil)
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

% Cables de bujía con aislamiento dañado o fuga de alta tensión
falla_sintoma(cables_bujia_aislamiento_danado, arco_electrico_visible).
falla_sintoma(cables_bujia_aislamiento_danado, vibracion_excesiva_motor).
falla_sintoma(cables_bujia_aislamiento_danado, explosion_escape).

% Batería con celda en corto o descargada
falla_sintoma(bateria_celda_muerta, chasquido_al_intentar_arrancar).
falla_sintoma(bateria_celda_muerta, tablero_parpadea_al_arrancar).
falla_sintoma(bateria_celda_muerta, dificultad_arranque).

% Banda de distribución brincada o desfasada
falla_sintoma(banda_distribucion_desfasada, golpeteo_metalico_sincronizacion).
falla_sintoma(banda_distribucion_desfasada, motor_no_enciende).
falla_sintoma(banda_distribucion_desfasada, explosion_escape).

% Fuga de vacío en mangueras del sistema de admisión
falla_sintoma(fuga_vacio_admision, silbido_en_motor).
falla_sintoma(fuga_vacio_admision, ralenti_inestable).
falla_sintoma(fuga_vacio_admision, motor_se_apaga_en_freno).

% Fisura o daño en empaque del pleno de admisión
falla_sintoma(fisura_pleno_admision, silbido_en_motor).
falla_sintoma(fisura_pleno_admision, perdida_potencia).
falla_sintoma(fisura_pleno_admision, vibracion_excesiva_motor).

% Pérdida de presión en el riel de inyectores
falla_sintoma(perdida_presion_riel_combustible, dificultad_arranque).
falla_sintoma(perdida_presion_riel_combustible, perdida_potencia).
falla_sintoma(perdida_presion_riel_combustible, motor_se_apaga_en_freno).

% Filtro de aire saturado / caja obstruida
falla_sintoma(filtro_aire_saturado, alto_consumo_gasolina).
falla_sintoma(filtro_aire_saturado, respuesta_tardia_acelerador).
falla_sintoma(filtro_aire_saturado, perdida_potencia).

% Obstrucción en tolva/turbina de enfriamiento por aire (Bóxer)
falla_sintoma(obstruccion_tolva_enfriamiento, sobrecalentamiento).
falla_sintoma(obstruccion_tolva_enfriamiento, olor_aceite_caliente_turbina).
falla_sintoma(obstruccion_tolva_enfriamiento, perdida_potencia).

% Cortocircuito en devanado primario de bobina COP
falla_sintoma(cortocircuito_bobina_primaria, vibracion_excesiva_motor).
falla_sintoma(cortocircuito_bobina_primaria, explosion_escape).
falla_sintoma(cortocircuito_bobina_primaria, respuesta_tardia_acelerador).

% Inyector abierto con goteo continuo (mezcla rica / ahogamiento)
falla_sintoma(inyector_goteo_abierto, ahogamiento_en_caliente).
falla_sintoma(inyector_goteo_abierto, olor_gasolina).
falla_sintoma(inyector_goteo_abierto, humo_negro).
falla_sintoma(inyector_goteo_abierto, alto_consumo_gasolina).

% ==============================================================================
% 3. TESTIGOS DE TABLERO Y CÓDIGOS OBD-II ASOCIADOS
% falla_testigo(?IdFalla, ?IdTestigo).
% ==============================================================================
falla_testigo(fallo_encendido_bujias,           check_engine).
falla_testigo(fallo_encendido_bujias,           codigo_p0300).

falla_testigo(inyector_tapado,                  check_engine).
falla_testigo(inyector_tapado,                  codigo_p0200).

falla_testigo(falla_carga_alternador,           testigo_bateria).

falla_testigo(fuga_bomba_agua,                  testigo_temperatura).

falla_testigo(cuerpo_aceleracion_sucio,         check_engine).
falla_testigo(cuerpo_aceleracion_sucio,         codigo_p0505).

falla_testigo(falla_bobina_encendido,           check_engine).
falla_testigo(falla_bobina_encendido,           codigo_p0300).

falla_testigo(desgaste_banda_accesorios,        testigo_bateria).

falla_testigo(cables_bujia_aislamiento_danado,  check_engine).
falla_testigo(cables_bujia_aislamiento_danado,  codigo_p0300).

falla_testigo(bateria_celda_muerta,             testigo_bateria).
falla_testigo(bateria_celda_muerta,             codigo_p0562).

falla_testigo(banda_distribucion_desfasada,     check_engine).
falla_testigo(banda_distribucion_desfasada,     codigo_p0016).

falla_testigo(fuga_vacio_admision,              check_engine).
falla_testigo(fuga_vacio_admision,              codigo_p0171).
falla_testigo(fuga_vacio_admision,              codigo_p2279).

falla_testigo(fisura_pleno_admision,            check_engine).
falla_testigo(fisura_pleno_admision,            codigo_p0171).
falla_testigo(fisura_pleno_admision,            codigo_p2279).

falla_testigo(perdida_presion_riel_combustible, check_engine).
falla_testigo(perdida_presion_riel_combustible, codigo_p0087).

falla_testigo(filtro_aire_saturado,             codigo_p0101).

falla_testigo(obstruccion_tolva_enfriamiento,   testigo_temperatura).

falla_testigo(cortocircuito_bobina_primaria,    check_engine).
falla_testigo(cortocircuito_bobina_primaria,    codigo_p0351).

falla_testigo(inyector_goteo_abierto,           check_engine).
falla_testigo(inyector_goteo_abierto,           codigo_p0172).
