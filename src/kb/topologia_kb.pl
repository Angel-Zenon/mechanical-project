:- module(topologia_kb, [
    obstruye/3
]).

:- use_module(catalogos_kb).
:- use_module(vehiculos_kb).

/** <module> Topología Mecánica del Motor (Grafos Acíclicos Dirigidos - DAG)
 *
 * Representa las relaciones físicas de desensamble inmediato entre componentes
 * para los 10 modelos de vehículos.
 *
 * Convención del predicado:
 *   obstruye(+Vehiculo, +PiezaQueEstorba, +PiezaObjetivo).
 * Significado: Para retirar PiezaObjetivo en Vehiculo, primero es necesario
 * desmontar PiezaQueEstorba.
 */

% ==============================================================================
% 1. NISSAN TSURU GSII 1.6L (L4 Simple - Acceso Directo)
% ==============================================================================
obstruye(tsuru_gs2, cables_bujia,      bujias).
obstruye(tsuru_gs2, banda_accesorios,  alternador).
obstruye(tsuru_gs2, banda_accesorios,  bomba_agua).
obstruye(tsuru_gs2, riel_inyectores,   inyectores).

% ==============================================================================
% 2. CHEVROLET CHEVY POP 1.6L (L4 SOHC - Bomba tras Distribución)
% ==============================================================================
obstruye(chevy_pop, cables_bujia,        bujias).
obstruye(chevy_pop, banda_accesorios,    banda_distribucion).
obstruye(chevy_pop, banda_distribucion,  bomba_agua).
obstruye(chevy_pop, banda_accesorios,    alternador).
obstruye(chevy_pop, riel_inyectores,     inyectores).

% ==============================================================================
% 3. HONDA CIVIC EX 1.8L (L4 i-VTEC - Bobinas COP y Cubierta)
% ==============================================================================
obstruye(civic_ex, cubierta_motor,   bobinas_ignicion).
obstruye(civic_ex, bobinas_ignicion, bujias).
obstruye(civic_ex, cubierta_motor,   riel_inyectores).
obstruye(civic_ex, riel_inyectores,  inyectores).
obstruye(civic_ex, banda_accesorios, alternador).
obstruye(civic_ex, banda_accesorios, bomba_agua).

% ==============================================================================
% 4. MAZDA 3 2.5L SKYACTIV (L4 GDI - Inyección Directa y Alta Compresión)
% ==============================================================================
obstruye(mazda3_sky, cubierta_motor,   bobinas_ignicion).
obstruye(mazda3_sky, bobinas_ignicion, bujias).
obstruye(mazda3_sky, cubierta_motor,   pleno_admision).
obstruye(mazda3_sky, pleno_admision,   riel_inyectores).
obstruye(mazda3_sky, riel_inyectores,  inyectores).
obstruye(mazda3_sky, banda_accesorios, alternador).
obstruye(mazda3_sky, banda_accesorios, bomba_agua).

% ==============================================================================
% 5. NISSAN MAXIMA 3.5L V6 (V6 Transversal - Estructura Diamante en Admisión)
% ==============================================================================
obstruye(maxima_v6, cubierta_motor,      cuerpo_aceleracion).
obstruye(maxima_v6, cuerpo_aceleracion,  pleno_admision).
obstruye(maxima_v6, mangueras_vacio,     pleno_admision).
obstruye(maxima_v6, pleno_admision,      bobinas_ignicion).
obstruye(maxima_v6, bobinas_ignicion,    bujias).
obstruye(maxima_v6, pleno_admision,      riel_inyectores).
obstruye(maxima_v6, riel_inyectores,     inyectores).
obstruye(maxima_v6, banda_accesorios,    alternador).
obstruye(maxima_v6, banda_accesorios,    bomba_agua).

% ==============================================================================
% 6. HONDA ODYSSEY 3.5L V6 (V6 Transversal Minivan - Acceso Apretado)
% ==============================================================================
obstruye(odyssey_v6, cubierta_motor,     cuerpo_aceleracion).
obstruye(odyssey_v6, cuerpo_aceleracion, pleno_admision).
obstruye(odyssey_v6, mangueras_vacio,    pleno_admision).
obstruye(odyssey_v6, pleno_admision,     bobinas_ignicion).
obstruye(odyssey_v6, bobinas_ignicion,   bujias).
obstruye(odyssey_v6, pleno_admision,     riel_inyectores).
obstruye(odyssey_v6, riel_inyectores,    inyectores).
obstruye(odyssey_v6, banda_accesorios,   alternador).
obstruye(odyssey_v6, banda_accesorios,   bomba_agua).

% ==============================================================================
% 7. SUBARU FORESTER 2.5L (Bóxer H4 - Obstrucción Lateral por Periféricos)
% ==============================================================================
obstruye(forester_bx, bateria,            bobinas_ignicion).
obstruye(forester_bx, caja_filtro_aire,   bobinas_ignicion).
obstruye(forester_bx, deposito_limpiador, bobinas_ignicion).
obstruye(forester_bx, bobinas_ignicion,   bujias).
obstruye(forester_bx, riel_inyectores,    inyectores).
obstruye(forester_bx, banda_accesorios,   alternador).
obstruye(forester_bx, banda_accesorios,   bomba_agua).

% ==============================================================================
% 8. VW SEDÁN 1.6L CARBURADO (Bóxer Enfriado por Aire)
% ==============================================================================
obstruye(vocho_sedan, cables_bujia,       bujias).
obstruye(vocho_sedan, banda_accesorios,   alternador).
obstruye(vocho_sedan, alternador,         tolva_enfriamiento).
obstruye(vocho_sedan, carburador,         tolva_enfriamiento).

% ==============================================================================
% 9. FORD LOBO 5.4L TRITON (V8 SOHC - Ductos de Admisión y Rieles V8)
% ==============================================================================
obstruye(lobo_v8, conducto_aire_admision, cuerpo_aceleracion).
obstruye(lobo_v8, conducto_aire_admision, bobinas_ignicion).
obstruye(lobo_v8, bobinas_ignicion,       bujias).
obstruye(lobo_v8, cuerpo_aceleracion,     riel_inyectores).
obstruye(lobo_v8, riel_inyectores,        inyectores).
obstruye(lobo_v8, banda_accesorios,       alternador).
obstruye(lobo_v8, banda_accesorios,       bomba_agua).

% ==============================================================================
% 10. BMW 325i E90 2.5L (L6 Longitudinal Premium - Encapsulado Estructural)
% ==============================================================================
obstruye(bmw_325i, tolva_microfiltro,  barra_estructural).
obstruye(bmw_325i, barra_estructural,  cubierta_motor).
obstruye(bmw_325i, cubierta_motor,      bobinas_ignicion).
obstruye(bmw_325i, bobinas_ignicion,    bujias).
obstruye(bmw_325i, cubierta_motor,      riel_inyectores).
obstruye(bmw_325i, riel_inyectores,     inyectores).
obstruye(bmw_325i, banda_accesorios,    alternador).
obstruye(bmw_325i, banda_accesorios,    bomba_agua).
