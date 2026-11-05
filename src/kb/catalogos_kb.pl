:- module(catalogos_kb, [
    maniobra/3,
    pieza_intervenible/1,
    sintoma_catalogo/2,
    testigo_catalogo/2
]).

/** <module> Catálogos Maestros de Maniobras, Síntomas y Testigos
 *
 * Este módulo contiene la base de conocimiento extensional (EDB) para los
 * componentes automotrices, costos/tiempos base de mano de obra y el
 * vocabulario controlado de síntomas observables y testigos/códigos OBD-II.
 *
 * Cumple con SRP al centralizar los valores tabulados de taller y DRY
 * al evitar la duplicación de nombres de piezas en otros módulos.
 */

% ==============================================================================
% 1. CATÁLOGO DE PIEZAS Y COSTOS BASE DE MANIOBRA
% maniobra(?Pieza, ?CostoBaseMXN, ?TiempoMinutos).
% ==============================================================================

% Componentes periféricos y de acceso (estorbos comunes)
maniobra(cubierta_motor,         50,   5).
maniobra(cables_bujia,           80,  10).
maniobra(bobinas_ignicion,      150,  15).
maniobra(bateria,               100,  10).
maniobra(caja_filtro_aire,      120,  15).
maniobra(conducto_aire_admision, 120,  15).
maniobra(deposito_limpiador,     100,  10).
maniobra(cuerpo_aceleracion,     300,  30).
maniobra(mangueras_vacio,        150,  20).
maniobra(pleno_admision,         650,  60).
maniobra(riel_inyectores,        350,  35).
maniobra(banda_accesorios,       200,  25).
maniobra(banda_distribucion,     800,  90).
maniobra(tolva_microfiltro,      250,  25).
maniobra(barra_estructural,      200,  15).
maniobra(tolva_enfriamiento,     400,  45).

% Componentes principales que representan servicios objetivo
maniobra(bujias,                 200,  20).
maniobra(inyectores,             400,  40).
maniobra(bomba_agua,             500,  50).
maniobra(alternador,             350,  35).
maniobra(carburador,             350,  35).

% ==============================================================================
% 2. CLASIFICACIÓN DE PIEZAS INTERVENIBLES (Servicios que un cliente solicita)
% pieza_intervenible(?Pieza).
% ==============================================================================
pieza_intervenible(bujias).
pieza_intervenible(inyectores).
pieza_intervenible(bomba_agua).
pieza_intervenible(alternador).
pieza_intervenible(bobinas_ignicion).
pieza_intervenible(cables_bujia).
pieza_intervenible(cuerpo_aceleracion).
pieza_intervenible(banda_distribucion).
pieza_intervenible(banda_accesorios).
pieza_intervenible(bateria).
pieza_intervenible(carburador).
pieza_intervenible(mangueras_vacio).
pieza_intervenible(pleno_admision).
pieza_intervenible(riel_inyectores).
pieza_intervenible(caja_filtro_aire).
pieza_intervenible(tolva_enfriamiento).

% ==============================================================================
% 3. CATÁLOGO CONTROLADO DE SÍNTOMAS OBSERVABLES
% sintoma_catalogo(?IdSintoma, ?Descripcion).
% ==============================================================================
sintoma_catalogo(tironeo_al_acelerar,             'Tironeo o jaloneo perceptible al acelerar').
sintoma_catalogo(ralenti_inestable,               'Marcha minima inestable o variaciones bruscas de RPM').
sintoma_catalogo(alto_consumo_gasolina,           'Consumo excesivo de combustible respecto al promedio').
sintoma_catalogo(perdida_potencia,                'Perdida notable de potencia bajo carga o aceleracion').
sintoma_catalogo(humo_negro,                      'Emision de humo negro visible por el escape').
sintoma_catalogo(luces_tenues,                    'Intensidad tenue o parpadeante en luces principales').
sintoma_catalogo(dificultad_arranque,             'Motor gira lento o tarda varios intentos en encender').
sintoma_catalogo(sobrecalentamiento,              'Elevacion anormal de temperatura en motor').
sintoma_catalogo(charco_anticongelante,           'Goteo o charco visible de anticongelante bajo el motor').
sintoma_catalogo(chirrido_motor,                  'Chirrido agudo proveniente del area de poleas o bandas').
sintoma_catalogo(motor_no_enciende,               'Motor da marcha pero no logra encender').
sintoma_catalogo(olor_gasolina,                   'Fuerte olor a gasolina cruda en compartimento de motor').
sintoma_catalogo(explosion_escape,                'Explosiones o contraexplosiones en escape al desacelerar').
sintoma_catalogo(silbido_en_motor,                'Silbido agudo de succion de aire en compartimento de motor').
sintoma_catalogo(motor_se_apaga_en_freno,         'El motor cae de RPM y se apaga al frenar o detenerse').
sintoma_catalogo(vibracion_excesiva_motor,        'Vibracion severa en cabina o motor durante marcha minima').
sintoma_catalogo(chasquido_al_intentar_arrancar,  'Sonido de chasquido/clic repetitivo al girar la llave sin dar marcha').
sintoma_catalogo(tablero_parpadea_al_arrancar,    'Cuadro de instrumentos parpadea o se apaga al intentar encender').
sintoma_catalogo(humo_blanco_vapor,               'Vapor denso o humo blanco saliendo del cofre').
sintoma_catalogo(golpeteo_metalico_sincronizacion,'Ruido ritmico o perdida subita de sincronizacion en distribucion').
sintoma_catalogo(ahogamiento_en_caliente,         'Motor se ahoga y dificulta el encendido tras operar en caliente').
sintoma_catalogo(respuesta_tardia_acelerador,     'Retardo perceptible (lag) al pisar el pedal del acelerador').
sintoma_catalogo(arco_electrico_visible,          'Chispa o arco electrico audible en cables de encendido').
sintoma_catalogo(olor_aceite_caliente_turbina,    'Olor intenso a aceite recalentado por falta de flujo de aire').

% ==============================================================================
% 4. CATÁLOGO CONTROLADO DE TESTIGOS DE TABLERO Y CÓDIGOS OBD-II
% testigo_catalogo(?IdTestigo, ?Descripcion).
% ==============================================================================
testigo_catalogo(check_engine,           'Testigo de averia de motor (Check Engine / MIL)').
testigo_catalogo(testigo_bateria,        'Testigo de advertencia del sistema de carga / bateria').
testigo_catalogo(testigo_temperatura,    'Testigo indicador de temperatura critica').
testigo_catalogo(codigo_p0300,           'OBD-II P0300: Fallo de encendido aleatorio o multiple').
testigo_catalogo(codigo_p0200,           'OBD-II P0200: Falla en circuito de inyectores').
testigo_catalogo(codigo_p0171,           'OBD-II P0171: Sistema demasiado pobre (Banco 1)').
testigo_catalogo(codigo_p0505,           'OBD-II P0505: Falla en control de marcha minima (IAC)').
testigo_catalogo(testigo_epc_acelerador, 'Testigo EPC / Advertencia de control electronico de aceleracion').
testigo_catalogo(codigo_p0172,           'OBD-II P0172: Sistema demasiado rico (Exceso de combustible Banco 1)').
testigo_catalogo(codigo_p0016,           'OBD-II P0016: Desfase de correlacion entre ciguenal y arbol de levas').
testigo_catalogo(codigo_p0087,           'OBD-II P0087: Presion en riel/sistema de combustible demasiado baja').
testigo_catalogo(codigo_p0101,           'OBD-II P0101: Rango/rendimiento insuficiente en flujo de aire (MAF)').
testigo_catalogo(codigo_p0351,           'OBD-II P0351: Falla en circuito primario/secundario de bobina A').
testigo_catalogo(codigo_p0562,           'OBD-II P0562: Voltaje del sistema electrico demasiado bajo').
testigo_catalogo(codigo_p2279,           'OBD-II P2279: Fuga de aire detectada en sistema de admision').
