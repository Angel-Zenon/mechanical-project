:- module(vehiculos_kb, [
    vehiculo/4,
    vehiculo_sistema/2,
    vehiculo_soporta_pieza/2
]).

:- use_module(catalogos_kb).

/** <module> Catálogo de Vehículos y Reglas de Compatibilidad Mecánica
 *
 * Define los 10 modelos de vehículos con sus características arquitectónicas
 * y multiplicadores de tarifa según gama y dificultad técnica.
 *
 * Implementa las reglas declarativas de compatibilidad (vehiculo_soporta_pieza/2)
 * siguiendo principios DRY: en lugar de acoplar estáticamente listas de piezas por auto,
 * la compatibilidad se deriva de los subsistemas del motor (enfriamiento, inducción, ignición).
 */

% ==============================================================================
% 1. CATÁLOGO MAESTRO DE LOS 10 VEHÍCULOS
% vehiculo(?IdVehiculo, ?NombreComercial, ?Arquitectura, ?FactorTarifa).
% ==============================================================================
vehiculo(tsuru_gs2,   'Nissan Tsuru GSII 1.6L',    l4_simple,      1.0).
vehiculo(chevy_pop,   'Chevrolet Chevy Pop 1.6L',  l4_sohc,        1.0).
vehiculo(civic_ex,    'Honda Civic EX 1.8L',       l4_vtec,        1.2).
vehiculo(mazda3_sky,  'Mazda 3 2.5L SkyActiv',     l4_gdi,         1.3).
vehiculo(maxima_v6,   'Nissan Maxima 3.5L V6',     v6_transversal, 1.5).
vehiculo(odyssey_v6,  'Honda Odyssey 3.5L V6',     v6_transversal, 1.5).
vehiculo(forester_bx, 'Subaru Forester 2.5L',      boxer_h4,       1.6).
vehiculo(vocho_sedan, 'VW Sedan 1.6L Carburado',   boxer_aire,     1.0).
vehiculo(lobo_v8,     'Ford Lobo 5.4L Triton',     v8_sohc,        1.4).
vehiculo(bmw_325i,    'BMW 325i E90 2.5L',         l6_premium,     1.8).

% ==============================================================================
% 2. SUBSISTEMAS Y ATRIBUTOS MECÁNICOS POR VEHÍCULO
% vehiculo_sistema(?IdVehiculo, ?Subsistema).
% ==============================================================================

% Sistema de enfriamiento
vehiculo_sistema(vocho_sedan, cooling(aire)).
vehiculo_sistema(V,           cooling(liquido)) :-
    vehiculo(V, _, _, _),
    V \= vocho_sedan.

% Sistema de inducción / alimentación de combustible
vehiculo_sistema(vocho_sedan, induction(carburador)).
vehiculo_sistema(V,           induction(inyeccion)) :-
    vehiculo(V, _, _, _),
    V \= vocho_sedan.

% Sistema de encendido / ignición
vehiculo_sistema(tsuru_gs2,   ignition(cables)).
vehiculo_sistema(chevy_pop,   ignition(cables)).
vehiculo_sistema(vocho_sedan, ignition(cables)).
vehiculo_sistema(civic_ex,    ignition(bobinas_cop)).
vehiculo_sistema(mazda3_sky,  ignition(bobinas_cop)).
vehiculo_sistema(maxima_v6,   ignition(bobinas_cop)).
vehiculo_sistema(odyssey_v6,  ignition(bobinas_cop)).
vehiculo_sistema(forester_bx, ignition(bobinas_cop)).
vehiculo_sistema(lobo_v8,     ignition(bobinas_cop)).
vehiculo_sistema(bmw_325i,    ignition(bobinas_cop)).

% Sistema de sincronización / distribución por banda de hule expuesta
vehiculo_sistema(chevy_pop,   timing(banda_distribucion)).

% Atributos estructurales y de chasis específicos
vehiculo_sistema(bmw_325i,    chassis(premium_encapsulado)).
vehiculo_sistema(forester_bx, chassis(boxer_perifericos)).
vehiculo_sistema(vocho_sedan, cooling(aire_turbina)).

% ==============================================================================
% 3. REGLAS DECLARATIVAS DE REQUISITO DE SUBSISTEMA POR PIEZA
% pieza_requiere_sistema(?Pieza, ?SubsistemaRequerido).
% ==============================================================================
pieza_requiere_sistema(bomba_agua,          cooling(liquido)).
pieza_requiere_sistema(tolva_enfriamiento,  cooling(aire_turbina)).

pieza_requiere_sistema(carburador,          induction(carburador)).
pieza_requiere_sistema(inyectores,          induction(inyeccion)).
pieza_requiere_sistema(riel_inyectores,     induction(inyeccion)).
pieza_requiere_sistema(cuerpo_aceleracion,  induction(inyeccion)).
pieza_requiere_sistema(mangueras_vacio,     induction(inyeccion)).
pieza_requiere_sistema(pleno_admision,      induction(inyeccion)).

pieza_requiere_sistema(cables_bujia,        ignition(cables)).
pieza_requiere_sistema(bobinas_ignicion,    ignition(bobinas_cop)).

pieza_requiere_sistema(banda_distribucion,  timing(banda_distribucion)).

pieza_requiere_sistema(tolva_microfiltro,   chassis(premium_encapsulado)).
pieza_requiere_sistema(barra_estructural,   chassis(premium_encapsulado)).

% ==============================================================================
% 4. COMPATIBILIDAD VEHÍCULO - PIEZA (DRY y Relacional Inversible)
% vehiculo_soporta_pieza(?IdVehiculo, ?Pieza).
% ==============================================================================
vehiculo_soporta_pieza(Vehiculo, Pieza) :-
    vehiculo(Vehiculo, _, _, _),
    maniobra(Pieza, _, _),
    % Si la pieza exige subsistemas específicos, el vehículo debe poseerlos todos:
    forall(pieza_requiere_sistema(Pieza, SisReq),
           vehiculo_sistema(Vehiculo, SisReq)).
