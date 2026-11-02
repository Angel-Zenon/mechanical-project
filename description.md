# Especificación Técnica y Planificación: Sistema Experto de Diagnóstico Automotriz y Cotización Dinámica por Topología de Desensamble

---

## 1. Resumen Ejecutivo

En la industria del mantenimiento automotriz, uno de los mayores problemas operativos y comerciales es la **estimación imprecisa de tiempos y costos de mano de obra** junto con la **incertidumbre en el diagnóstico de fallas**. Un mismo servicio mecánico (por ejemplo, el reemplazo o lavado de bujías, cambio de bomba de agua o reemplazo de inyectores) varía drásticamente en complejidad según la arquitectura del motor de cada vehículo.

Este proyecto propone el diseño e implementación de un **Sistema Experto en Prolog** que resuelve dos problemas acoplados mediante programación lógica declarativa:
1. **Diagnóstico asistido por síntomas y códigos/testigos de tablero:** Infiere qué componente mecánico o electrónico presenta fallas a partir de la evidencia observada.
2. **Planificación de desensamble y cotización dinámica basada en grafos de obstrucción:** Modela la disposición física de las piezas de al menos 10 vehículos como un Grafo Acíclico Dirigido (DAG), deduciendo recursivamente qué piezas estorban para llegar al componente dañado, generando la ruta exacta de desarme para el mecánico y calculando el costo real de mano de obra sin duplicar pasos compartidos.

---

## 2. Planteamiento del Problema

### 2.1. El Problema de la Accesibilidad Mecánica (Topología del Motor)
En un taller mecánico tradicional, cotizar un servicio mediante una tarifa plana resulta en pérdidas para el taller o cobros injustos para el cliente:
* **Caso A (Motor Longitudinal o L4 sencillo - ej. Nissan Tsuru):** Las bujías están en la parte superior del motor, totalmente expuestas. El mecánico solo retira los cables de bujía y extrae las bujías. Tiempo estimado: $20\text{ min}$.
* **Caso B (Motor V6 Transversal - ej. Nissan Maxima / Honda Odyssey):** Las tres bujías del banco delantero son accesibles, pero las tres bujías del banco trasero están ocultas debajo del pleno (múltiple) de admisión y el cuerpo de aceleración. Para cambiarlas, el mecánico está obligado a desmontar la cubierta estética, desconectar mangueras de vacío, desmontar el cuerpo de aceleración, retirar el múltiple de admisión y quitar las bobinas individuales antes de tocar las bujías. Tiempo estimado: $2.5\text{ a }3\text{ horas}$.

Si se intentara programar esto con reglas condicionales estáticas para cada combinación de vehículo y servicio, se produciría una explosión combinatoria inmanejable. En cambio, al modelar qué pieza obstruye físicamente a otra mediante cláusulas de Horn, el motor de inferencia SLD de Prolog puede deducir automáticamente la ruta de desarme y su costo asociado.

### 2.2. El Problema del Diagnóstico por Síntomas y Testigos
Cuando un cliente ingresa al taller, rara vez conoce la pieza exacta que falló; en su lugar, reporta **síntomas observables** (ej. *jaloneo al acelerar*, *humo negro*, *sobrecalentamiento*) y **testigos encendidos en el tablero** o códigos de escáner OBD-II (ej. `check_engine`, `testigo_bateria`, `codigo_p0300`). El sistema debe actuar como un motor de inferencia diagnóstica capaz de sugerir las fallas probables y encadenarlas directamente con el cotizador de servicio para el modelo de auto específico del cliente.

---

## 3. Objetivos del Proyecto

### 3.1. Objetivo General
Desarrollar un sistema experto declarativo en SWI-Prolog que integre el diagnóstico de fallas automotrices con el cálculo automático de rutas de desensamble y presupuestos de mano de obra, soportando una base de conocimientos de al menos 10 vehículos con distintas arquitecturas mecánicas.

### 3.2. Objetivos Específicos
1. Modelar una base de conocimientos normalizada de al menos **10 modelos de vehículos** con diferentes configuraciones mecánicas (4 cilindros en línea, V6 transversal, Boxer, V8, Turbo compacto, etc.).
2. Implementar un motor de búsqueda sobre **grafos de dependencia mecánica** que determine por clausura transitiva la secuencia ordenada de piezas a desmontar para intervenir un componente objetivo.
3. Implementar un **motor de inferencia diagnóstica** en dos niveles: coincidencia estricta (todos los síntomas presentes) y coincidencia heurística/sugerencia (porcentaje de afinidad de síntomas y testigos).
4. Garantizar la **idempotencia en presupuestos compuestos**: si un cliente solicita dos servicios cuyos caminos de desarme comparten piezas intermedias (ej. cambiar bujías e inyectores en un V6 que requieren ambos desmontar el múltiple de admisión), el sistema debe cobrar el desarme del múltiple **una sola vez**.

---

## 4. Arquitectura del Sistema

El sistema sigue una **arquitectura declarativa multicapa** para separar estrictamente los datos (hechos extensionales) de la lógica de inferencia (predicados intensionales).

```
+-------------------------------------------------------------------------+
| CAPA 4: INTERFAZ Y ORQUESTACIÓN (Consultas, Reportes, Órdenes de Trabajo)|
|         - orden_servicio_completa/5, diagnosticar_y_cotizar/4           |
+-------------------------------------------------------------------------+
                   |                                     |
                   v                                     v
+-------------------------------------+ +---------------------------------+
| CAPA 2: MOTOR DE DIAGNÓSTICO        | | CAPA 3: MOTOR TOPOLÓGICO Y COSTO|
| - Diagnóstico estricto (forall/2)   | | - Clausura transitiva (DAG)     |
| - Sugerencia ponderada (setof/3)    | | - Eliminación de duplicados     |
| - Mapeo Falla -> Pieza Objetivo     | | - Cálculo de mano de obra       |
+-------------------------------------+ +---------------------------------+
                   \                                     /
                    v                                   v
+-------------------------------------------------------------------------+
| CAPA 1: BASE DE CONOCIMIENTO NORMALIZADA (EDB - Hechos Primitivos)      |
| - vehiculo/4        - obstruye/3         - falla_sintoma/2              |
| - maniobra_base/3   - falla_pieza/2      - falla_testigo/2              |
+-------------------------------------------------------------------------+
```

---

## 5. Reglas Lógicas y Restricciones de Ingeniería a Considerar

Para que tu implementación sea robusta, académica y libre de errores lógicos durante la defensa del proyecto, debes contemplar las siguientes **7 reglas de diseño**:

### Regla 1: Representación de Obstrucción como Grafo Acíclico Dirigido (DAG)
Nunca declares listas fijas de pasos. Declara únicamente la relación física inmediata:
$$\text{obstruye}(\text{Vehiculo}, \text{PiezaQueEstorba}, \text{PiezaObjetivo})$$
* **Restricción crítica:** El grafo no debe contener ciclos (ej. la pieza $A$ obstruye a $B$ y $B$ obstruye a $A$), ya que la estrategia de búsqueda en profundidad (DFS) de Prolog entraría en recursión infinita. Aun así, se implementará una lista de nodos visitados como salvaguarda.

### Regla 2: Clausura Transitiva y Orden Topológico de Desarme
Si la pieza $A$ obstruye a $B$, y $B$ obstruye a $C$, para intervenir $C$ el mecánico debe desmontar primero $A$, luego $B$ y finalmente intervenir $C$:
1. **Caso base:** Para llegar a $Y$, se requiere desmontar $X$ si $\text{obstruye}(V, X, Y)$.
2. **Caso recursivo:** Para llegar a $Y$, se requiere desmontar $X$ si $\text{obstruye}(V, Z, Y)$ y para llegar a $Z$ se requiere desmontar $X$.

### Regla 3: Idempotencia en Desarmes con Ramificaciones o Servicios Múltiples
En motores complejos, una pieza puede estar bloqueada por dos componentes que a su vez dependen de una cubierta común (estructura de diamante en el grafo), o el cliente puede pedir dos servicios simultáneos (ej. `[bujias, inyectores]`).
* **Solución en Prolog:** Utilizar `setof/3` (o `findall/3` seguido de `list_to_set/2`) para asegurar que cada pieza previa se desmonte y se cobre **exactamente una vez**, sin importar por cuántas ramas del árbol de búsqueda SLD aparezca.

### Regla 4: Factor de Complejidad por Vehículo y Costo de Maniobra
Cada componente tiene un costo y tiempo estándar de intervención ($\text{maniobra\_base}(\text{Pieza}, \text{Costo}, \text{Minutos})$). Además, opcionalmente cada vehículo puede tener un multiplicador de tarifa según su gama o dificultad ($\text{vehiculo}(\text{Id}, \text{Marca}, \text{Modelo}, \text{FactorTarifa})$). El costo total se define formalmente como:
$$\text{CostoTotal} = \text{FactorTarifa} \times \sum_{p \in \text{PasosUnicos}} \text{CostoManiobra}(p)$$

### Regla 5: Diagnóstico en Dos Modalidades (Estricto vs. Heurístico)
En la vida real, el cliente no siempre identifica todos los síntomas de una falla:
* **Diagnóstico Confirmado (Estricto):** Se cumple cuando el vehículo presenta **todos** los síntomas y testigos asociados a una falla (implementado con el metapredicado `forall/2`).
* **Diagnóstico por Sugerencia (Heurístico):** Si el usuario ingresa una lista parcial de síntomas $S_{\text{usuario}}$, el sistema calcula cuántas coincidencias $k$ existen respecto al total de síntomas $n$ de cada falla conocida, devolviendo las fallas donde $k \ge 1$ junto con su índice de certeza:
$$\text{Certeza}(\%) = \left( \frac{|S_{\text{usuario}} \cap S_{\text{falla}}|}{|S_{\text{falla}}|} \right) \times 100$$

### Regla 6: Inversibilidad de Consultas
El diseño de los predicados debe permitir consultas en múltiples direcciones:
* Dado un carro y un servicio $\rightarrow$ obtener pasos y costo.
* Dado un presupuesto máximo y un carro $\rightarrow$ saber qué servicios preventivos le alcanza a pagar al cliente.
* Dada una pieza (ej. `pleno_admision`) $\rightarrow$ consultar en qué vehículos es necesario desmontarla para cambiar las `bujias`.

### Regla 7: Encadenamiento Diagnóstico $\rightarrow$ Servicio (End-to-End)
Cada falla diagnosticada debe estar vinculada a la pieza física que la origina mediante el hecho `falla_requiere_intervenir(Falla, PiezaObjetivo)`. Así, el sistema puede recibir síntomas de entrada y entregar directamente la cotización de reparación adaptada al modelo del auto.

---

## 6. Catálogo de los 10 Vehículos para la Base de Conocimientos

Para demostrar el poder del sistema, la base de conocimientos incluirá 10 vehículos con arquitecturas mecánicas contrastantes:

| ID en Prolog | Vehículo Real | Arquitectura de Motor | Característica de Accesibilidad en el Sistema |
| :--- | :--- | :--- | :--- |
| `tsuru_gs2` | Nissan Tsuru 1.6L | L4 Longitudinal/Transversal simple | Acceso directo casi sin obstrucciones (económico). |
| `chevy_pop` | Chevrolet Chevy 1.6L | L4 SOHC 8V | Bujías accesibles, pero la bomba de agua está obstruida por la banda de distribución. |
| `civic_ex` | Honda Civic 1.8L | L4 i-VTEC | Cubierta plástica y bobinas individuales sobre bujías; alternador de acceso medio. |
| `mazda3_sky` | Mazda 3 2.5L | L4 SkyActiv-G | Alta compresión; inyectores de inyección directa obstruidos por riel de alta presión y múltiple. |
| `maxima_v6` | Nissan Maxima 3.5L | V6 Transversal (VQ35) | **Caso crítico:** Banco trasero de bujías/bobinas bloqueado por pleno de admisión y cuerpo de aceleración. |
| `odyssey_v6` | Honda Odyssey 3.5L | V6 Transversal | Alternador y bujías traseras fuertemente obstruidos por componentes periféricos. |
| `forester_bx` | Subaru Forester 2.5L | Bóxer 4 cilindros (H4) | **Caso crítico:** Bujías laterales bloqueadas por batería, depósito limpiaparabrisas y caja de filtro de aire. |
| `vocho_sedan` | VW Sedán 1.6L | Bóxer enfriado por aire | Para acceder a componentes internos de enfriamiento hay que desmontar tolvas y generador. |
| `lobo_v8` | Ford Lobo / F-150 5.4L | V8 Tritón | Acceso profundo; rieles de combustible y conductos de aire obstruyen bancos de bobinas. |
| `bmw_325i` | BMW Serie 3 (E90) | L6 Longitudinal | Bujías del fondo (cilindros 5 y 6) bloqueadas por tolva de microfiltro de cabina y barra estructural. |

---

## 7. Alineación con el Temario y el Manual de Prácticas

Este proyecto cubre de forma transversal las competencias de la materia y reutiliza directamente los patrones del **Manual de Prácticas**:

1. **Prácticas 2 y 4 (Base de Conocimientos y Reglas Derivadas):** Modelado relacional de vehículos, piezas, síntomas y deducción lógica de dependencias.
2. **Práctica 5 (Control de Backtracking y Cut `!`):** Uso controlado del corte en reglas de clasificación de costos y formateo de reportes.
3. **Prácticas 7 y 8 (Operaciones sobre Listas):** Manipulación recursiva de listas de pasos, intersección de síntomas, concatenación (`append/3`) y conteo (`longitud/2`).
4. **Práctica 11 (Grafos y Búsqueda de Caminos DFS):** El motor de desensamble es una aplicación industrial directa del recorrido en grafos sobre la relación `obstruye/3`.
5. **Práctica 19 (`findall/3`, `bagof/3`, `setof/3`):** Recolección libre de duplicados de todas las piezas previas a desmontar y agrupación de diagnósticos posibles.
6. **Práctica 20 (Predicados de Orden Superior `maplist`, `foldl`, `include`):** Transformación de listas de piezas en listas de costos y sumatoria acumulada.
7. **Práctica 25 (Sistema Experto de Diagnóstico):** Aplicación directa del patrón `findall` + `forall` para el diagnóstico mecánico a partir de síntomas y testigos.

---

## 8. Planificación de Implementación (Roadmap en 5 Fases)

Para construir el proyecto de forma ordenada y sin bloqueos, sigue este plan incremental:

### Fase 1: Diseño y Carga de la Base de Conocimientos (Día 1-2)
* **Objetivo:** Definir los hechos primitivos sin lógica compleja.
* **Tareas:**
  1. Declarar los 10 vehículos con `vehiculo(Id, MarcaModelo, TipoMotor, FactorTarifa)`.
  2. Declarar el catálogo de piezas y su costo/tiempo de desmontaje base con `maniobra(Pieza, CostoManoObra, TiempoMin)`.
  3. Codificar la topología `obstruye(IdVehiculo, PiezaEstorbo, PiezaObjetivo)` para al menos 4 servicios clave (*bujías, inyectores, alternador, bomba de agua*) en los 10 vehículos.
* **Entregable:** Archivo `base_conocimiento.pl` libre de errores sintácticos.

### Fase 2: Motor Topológico de Desensamble y Cotización Simple (Día 3-4)
* **Objetivo:** Lograr que Prolog deduzca qué piezas quitar y cuánto cobrar para un servicio individual.
* **Tareas:**
  1. Programar el predicado recursivo `requiere_desmontar(Carro, PiezaObjetivo, PiezaPrevia)` con control de visitados.
  2. Programar `plan_desensamble(Carro, PiezaObjetivo, ListaPasos)` usando `findall/3` y eliminando duplicados preservando el orden de desarme.
  3. Programar `cotizar_servicio(Carro, PiezaObjetivo, ListaPasos, TiempoTotal, CostoTotal)`.
* **Prueba de validación:** Verificar que `cotizar_servicio(tsuru_gs2, bujias, ...)` sea mucho más corto y económico que `cotizar_servicio(maxima_v6, bujias, ...)`.

### Fase 3: Cotización Múltiple con Optimización de Pasos Compartidos (Día 5)
* **Objetivo:** Soportar órdenes de trabajo con varios servicios simultáneos sin cobrar doble las piezas comunes.
* **Tareas:**
  1. Programar `cotizar_orden_multiple(Carro, ListaObjetivos, PasosUnificados, CostoTotal)`.
  2. Comprobar que si se pide `[bujias, inyectores]` en `maxima_v6`, el `pleno_admision` aparezca una sola vez en `PasosUnificados`.

### Fase 4: Motor de Diagnóstico por Síntomas y Testigos (Día 6-7)
* **Objetivo:** Construir el módulo de escáner / sistema experto.
* **Tareas:**
  1. Definir hechos `falla_sintoma(IdFalla, Sintoma)`, `falla_testigo(IdFalla, Testigo)` y `falla_pieza(IdFalla, PiezaObjetivo)`.
  2. Implementar `diagnostico_exacto(ListaSintomas, ListaTestigos, Falla)`.
  3. Implementar `sugerir_diagnostico(ListaSintomas, ListaTestigos, Falla, PorcentajeCerteza, PiezaSugerida)`.

### Fase 5: Integración End-to-End y Menú/Reportes (Día 8)
* **Objetivo:** Unir el diagnóstico con el cotizador y formatear la salida.
* **Tareas:**
  1. Crear el predicado integrador `atender_cliente(Carro, Sintomas, Testigos, Reporte)`.
  2. Agregar un predicado de impresión formateada (`format/2`) que muestre en consola la Orden de Servicio desglosada paso a paso.
  3. Documentar las consultas de prueba para la presentación final.

---

## 9. Arquitectura de Código Base (Esqueleto Funcional de Referencia)

Puedes usar este bloque como punto de partida sólido para iniciar tu Fase 1 y Fase 2 en VS Code:

```prolog
% ==============================================================================
% MÓDULO 1: CATÁLOGO DE VEHÍCULOS Y COSTOS BASE DE MANIOBRA
% ==============================================================================
% vehiculo(Id, Nombre, Configuracion, FactorMultiplicador).
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

% maniobra(Pieza, CostoBaseMXN, TiempoMinutos).
maniobra(cubierta_motor,        50,  5).
maniobra(cables_bujia,          80,  10).
maniobra(bobinas_ignicion,      150, 15).
maniobra(bateria,               100, 10).
maniobra(caja_filtro_aire,      120, 15).
maniobra(deposito_limpiador,    100, 10).
maniobra(cuerpo_aceleracion,    300, 30).
maniobra(mangueras_vacio,       150, 20).
maniobra(pleno_admision,        650, 60).
maniobra(riel_inyectores,       350, 35).
maniobra(banda_accesorios,      200, 25).
maniobra(banda_distribucion,    800, 90).
maniobra(tolva_microfiltro,     250, 25).
maniobra(barra_estructural,     200, 15).
maniobra(tolva_enfriamiento,    400, 45).
% Piezas objetivo principales
maniobra(bujias,                200, 20).
maniobra(inyectores,            400, 40).
maniobra(bomba_agua,            500, 50).
maniobra(alternador,            350, 35).

% ==============================================================================
% MÓDULO 2: GRAFO DE OBSTRUCCIÓN MECÁNICA (Ejemplos representativos)
% obstruye(Vehiculo, PiezaQueEstorba, PiezaObjetivo).
% ==============================================================================
% 1. Tsuru: Acceso directo
obstruye(tsuru_gs2, cables_bujia, bujias).
obstruye(tsuru_gs2, banda_accesorios, alternador).
obstruye(tsuru_gs2, banda_accesorios, bomba_agua).

% 2. Chevy: Bomba de agua detrás de la distribución
obstruye(chevy_pop, cables_bujia, bujias).
obstruye(chevy_pop, banda_accesorios, banda_distribucion).
obstruye(chevy_pop, banda_distribucion, bomba_agua).

% 3. Maxima V6: Bujías e inyectores ocultos bajo el pleno de admisión
obstruye(maxima_v6, cubierta_motor, cuerpo_aceleracion).
obstruye(maxima_v6, cuerpo_aceleracion, pleno_admision).
obstruye(maxima_v6, mangueras_vacio, pleno_admision).
obstruye(maxima_v6, pleno_admision, bobinas_ignicion).
obstruye(maxima_v6, bobinas_ignicion, bujias).
obstruye(maxima_v6, pleno_admision, riel_inyectores).
obstruye(maxima_v6, riel_inyectores, inyectores).

% 4. Subaru Forester Boxer: Bujías laterales bloqueadas por periféricos
obstruye(forester_bx, bateria, bobinas_ignicion).
obstruye(forester_bx, caja_filtro_aire, bobinas_ignicion).
obstruye(forester_bx, deposito_limpiador, bobinas_ignicion).
obstruye(forester_bx, bobinas_ignicion, bujias).

% 5. BMW 325i: Cilindros traseros debajo de tolva superior y barra
obstruye(bmw_325i, tolva_microfiltro, barra_estructural).
obstruye(bmw_325i, barra_estructural, cubierta_motor).
obstruye(bmw_325i, cubierta_motor, bobinas_ignicion).
obstruye(bmw_325i, bobinas_ignicion, bujias).

% ==============================================================================
% MÓDULO 3: MOTOR DE INFERENCIA TOPOLÓGICA Y COTIZACIÓN
% ==============================================================================
% Deducción recursiva con prevención de ciclos
requiere_desmontar(Carro, Objetivo, Previa) :-
    requiere_desmontar_aux(Carro, Objetivo, Previa, [Objetivo]).

requiere_desmontar_aux(Carro, Objetivo, Previa, Visitados) :-
    obstruye(Carro, Intermedia, Objetivo),
    \+ member(Intermedia, Visitados),
    (   Previa = Intermedia
    ;   requiere_desmontar_aux(Carro, Intermedia, Previa, [Intermedia|Visitados])
    ).

% Cálculo de costos y tiempos sobre una lista de piezas
sumar_maniobras([], 0, 0).
sumar_maniobras([Pieza|Resto], CostoAcum, TiempoAcum) :-
    maniobra(Pieza, C, T),
    sumar_maniobras(Resto, CResto, TResto),
    CostoAcum is C + CResto,
    TiempoAcum is T + TResto.

% Cotización de un servicio individual o lista de servicios
cotizar(Carro, Objetivos, PasosTotales, TiempoMin, CostoFinal) :-
    vehiculo(Carro, _, _, Factor),
    (is_list(Objetivos) -> ListaObj = Objetivos ; ListaObj = [Objetivos]),
    findall(Previa, (member(Obj, ListaObj), requiere_desmontar(Carro, Obj, Previa)), PreviasBrutas),
    append(PreviasBrutas, ListaObj, TodosLosPasos),
    list_to_set(TodosLosPasos, PasosTotales),
    sumar_maniobras(PasosTotales, CostoBase, TiempoMin),
    CostoFinal is round(CostoBase * Factor).

% ==============================================================================
% MÓDULO 4: SISTEMA EXPERTO DE DIAGNÓSTICO (ESCÁNER / SÍNTOMAS)
% ==============================================================================
falla_pieza(fallo_encendido_bujias, bujias).
falla_pieza(inyector_tapado,        inyectores).
falla_pieza(falla_carga_alternador, alternador).
falla_pieza(fuga_bomba_agua,        bomba_agua).

falla_sintoma(fallo_encendido_bujias, tironeo_al_acelerar).
falla_sintoma(fallo_encendido_bujias, ralenti_inestable).
falla_sintoma(fallo_encendido_bujias, alto_consumo_gasolina).

falla_sintoma(inyector_tapado,        perdida_potencia).
falla_sintoma(inyector_tapado,        humo_negro).
falla_sintoma(inyector_tapado,        tironeo_al_acelerar).

falla_sintoma(falla_carga_alternador, luces_tenues).
falla_sintoma(falla_carga_alternador, dificultad_arranque).

falla_sintoma(fuga_bomba_agua,        sobrecalentamiento).
falla_sintoma(fuga_bomba_agua,        charco_anticongelante).

falla_testigo(fallo_encendido_bujias, check_engine).
falla_testigo(fallo_encendido_bujias, codigo_p0300).
falla_testigo(inyector_tapado,        check_engine).
falla_testigo(inyector_tapado,        codigo_p0200).
falla_testigo(falla_carga_alternador, testigo_bateria).
falla_testigo(fuga_bomba_agua,        testigo_temperatura).

% Diagnóstico heurístico por porcentaje de coincidencia
diagnosticar_y_cotizar(Carro, SintomasCliente, TestigosCliente, Falla, Certeza, Pieza, Pasos, Costo) :-
    falla_pieza(Falla, Pieza),
    findall(S, falla_sintoma(Falla, S), SintomasFalla),
    findall(T, falla_testigo(Falla, T), TestigosFalla),
    append(SintomasFalla, TestigosFalla, EvidenciaEsperada),
    append(SintomasCliente, TestigosCliente, EvidenciaCliente),
    intersection(EvidenciaEsperada, EvidenciaCliente, Coincidencias),
    length(Coincidencias, NumCoincidencias),
    NumCoincidencias > 0,
    length(EvidenciaEsperada, TotalEsperado),
    Certeza is round((NumCoincidencias / TotalEsperado) * 100),
    cotizar(Carro, Pieza, Pasos, _, Costo).
```