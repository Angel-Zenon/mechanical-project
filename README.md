# Sistema Experto de Diagnóstico Automotriz y Cotización Dinámica por Topología de Desensamble

**Asignatura:** Programación Lógica y Funcional  
**Tecnología:** SWI-Prolog (Paradigma Lógico y Declarativo)  
**Arquitectura:** Modular Multicapa (No Monolítica, SRP, DRY, Clean Code)  

---

## 1. Descripción del Problema

En la industria del mantenimiento y reparación automotriz, los talleres mecánicos enfrentan dos grandes desafíos que generan pérdidas operativas, cobros injustos para los clientes y errores recurrentes en el taller:

### 1.1. La Falacia de la Tarifa Plana y la Accesibilidad Mecánica
Tradicionalmente, muchos talleres cotizan la mano de obra basándose en el nombre del servicio (por ejemplo: *"cambio de bujías"*, *"reemplazo de bomba de agua"* o *"cambio de inyectores"*) aplicando una tarifa plana o fija. Sin embargo, la dificultad real no depende únicamente del componente en sí, sino de la **arquitectura física y topología del motor**:
* **En un motor L4 simple (ej. Nissan Tsuru):** Las bujías están expuestas sobre la tapa de punterías. El mecánico únicamente desconecta los cables de bujía y las extrae con un dado. Tiempo estimado: **20 a 30 minutos** ($280 MXN).
* **En un motor V6 transversal (ej. Nissan Maxima / Honda Odyssey):** Las bujías del banco trasero están totalmente bloqueadas por la cubierta estética, el cuerpo de aceleración, mangueras de vacío y el pleno (múltiple) de admisión. Para intervenir las bujías, el mecánico debe desarmar medio compartimento superior. Tiempo estimado: **2.5 a 3 horas** ($2,250 MXN).
* **En un motor Bóxer H4 (ej. Subaru Forester):** Las bujías están orientadas horizontalmente hacia los costados del chasis, obstruidas por la batería, el depósito limpiaparabrisas y la caja del filtro de aire.

Si se intentara modelar este problema mediante programación imperativa con estructuras condicionales (`if/else` o `switch`), se produciría una explosión combinatoria inmanejable por cada combinación de vehículo, motor y servicio.

### 1.2. Incertidumbre en el Diagnóstico Clínico
Cuando un cliente acude al taller, no conoce la pieza exacta averiada; solo reporta **síntomas observables** (*tironeo al acelerar*, *ralentí inestable*, *humo negro*, *sobrecalentamiento*) y **testigos o códigos OBD-II** (*Check Engine*, *P0300*, *P0200*, *testigo de temperatura*). El taller requiere un motor de inferencia capaz de evaluar la evidencia clínica disponible, descartar fallas incompatibles con la arquitectura del auto (por ejemplo, nunca atribuir falla de inyectores a un motor carburado) y sugerir la hipótesis más probable con su grado de certeza.

### 1.3. Sobrecotización y Falta de Idempotencia en Servicios Múltiples
Cuando un cliente solicita dos o más servicios en una misma visita (ej. *cambio de bujías* y *reemplazo de inyectores* en un V6), ambos servicios requieren desmontar el pleno de admisión y el cuerpo de aceleración. En un taller empírico, se suma el costo completo de ambos servicios, **cobrando dos veces el desarme del mismo componente**. Se requiere un sistema capaz de unificar las rutas de desensamble y cobrar las piezas compartidas **una sola vez**.

---

## 2. Solución Propuesta

El sistema implementa un **Sistema Experto Declarativo en SWI-Prolog** estructurado en capas desacopladas, utilizando las siguientes técnicas de ingeniería lógica:

### 2.1. Modelado de Obstrucción Física como Grafo Acíclico Dirigido (DAG)
En lugar de almacenar secuencias fijas de pasos por cada auto, la base de conocimientos almacena únicamente la relación física inmediata:
$$\text{obstruye}(\text{Vehiculo}, \text{PiezaQueEstorba}, \text{PiezaObjetivo})$$
El motor infiere la ruta de acceso calculando la clausura transitiva sobre el grafo sin riesgo de recursión infinita mediante control de visitados y detección formal de ciclos.

### 2.2. Algoritmo de Ordenamiento Topológico DFS Post-Orden con Acumulador
Para garantizar que el mecánico retire los componentes **en estricto orden físico de afuera hacia adentro** (por ejemplo: primero la tolva superior, luego la barra estructural, luego la cubierta, luego las bobinas y finalmente las bujías), se diseñó un algoritmo de ordenamiento topológico DFS post-orden. Si un componente intermedio ya fue desmontado por una rama previa (como ocurre en estructuras diamante o servicios múltiples), el acumulador lo detecta en tiempo $O(1)$ y evita duplicarlo.

### 2.3. Idempotencia y Cotización Dinámica mediante Orden Superior
El cálculo de tiempos y costos de mano de obra se realiza transformando las listas de desensamble mediante predicados de orden superior (`maplist/3` y `foldl/4` de `library(apply)`). El costo final se ajusta por el factor de complejidad o gama del vehículo:
$$\text{CostoFinal} = \text{round}\left( \text{FactorTarifa} \times \sum_{p \in \text{PasosUnificados}} \text{CostoManiobra}(p) \right)$$

### 2.4. Motor de Inferencia Diagnóstica en Dos Niveles
* **Modo Confirmado (Estricto - 100% certeza):** Emplea el metapredicado `forall/2` para verificar que la totalidad de los síntomas y testigos requeridos por una falla estén presentes en el reporte del cliente.
* **Modo Heurístico (Sugerencia Ponderada):** Si la evidencia es parcial, calcula la intersección entre la evidencia reportada y la esperada, entregando las hipótesis ordenadas descendentemente por afinidad porcentual:
$$\text{Certeza}(\%) = \text{round}\left( \frac{|\text{EvidenciaCliente} \cap \text{EvidenciaFalla}|}{|\text{EvidenciaFalla}|} \times 100 \right)$$

### 2.5. Arquitectura Modular y Principios de Diseño
Para evitar construir un monolito y asegurar mantenibilidad académica:
* **Separación EDB vs. IDB:** La base extensional (hechos de catálogo, vehículos, topología y fallas) está estrictamente separada de los motores de inferencia.
* **Single Responsibility Principle (SRP):** Cada módulo tiene un único motivo de cambio. Solo `src/ui/reporte_cli.pl` maneja entrada/salida (`format/2`, `write`). Los motores en `core/` y la orquestación en `service/` son puramente lógicos y testeables.
* **Don't Repeat Yourself (DRY):** Las reglas de compatibilidad de piezas (`vehiculo_soporta_pieza/2`) se derivan declarativamente de los subsistemas del motor (enfriamiento, inducción, ignición) en lugar de duplicar listas por cada uno de los 10 autos.

---

## 3. Catálogo de los 10 Vehículos Modelados

| ID en Prolog | Vehículo Comercial | Arquitectura de Motor | Rasgo Topológico / Complejidad | Factor |
| :--- | :--- | :--- | :--- | :--- |
| `tsuru_gs2` | Nissan Tsuru GSII 1.6L | L4 Simple (Distribuidor) | Acceso directo casi sin estorbos periféricos. | `x1.00` |
| `chevy_pop` | Chevrolet Chevy Pop 1.6L | L4 SOHC 8V | Bomba de agua detrás de banda de distribución de hule. | `x1.00` |
| `civic_ex` | Honda Civic EX 1.8L | L4 i-VTEC | Cubierta plástica superior y bobinas individuales COP. | `x1.20` |
| `mazda3_sky` | Mazda 3 2.5L SkyActiv | L4 Inyección Directa (GDI) | Inyectores bajo pleno de admisión y riel de alta presión. | `x1.30` |
| `maxima_v6` | Nissan Maxima 3.5L V6 | V6 Transversal (VQ35) | Pleno de admisión y cuerpo obstruyen banco trasero. | `x1.50` |
| `odyssey_v6` | Honda Odyssey 3.5L V6 | V6 Transversal Minivan | Acceso sumamente apretado a pleno, bobinas y alternador. | `x1.50` |
| `forester_bx` | Subaru Forester 2.5L | Bóxer 4 cil. horizontales | Bujías laterales bloqueadas por batería, filtro y depósito. | `x1.60` |
| `vocho_sedan` | VW Sedán 1.6L Carburado | Bóxer enfriado por aire | Tolva de turbina y alternador; sin bomba de agua ni inyección. | `x1.00` |
| `lobo_v8` | Ford Lobo 5.4L Triton | V8 SOHC | Ductos de admisión y rieles profundos sobre bobinas V8. | `x1.40` |
| `bmw_325i` | BMW Serie 3 E90 2.5L | L6 Longitudinal Premium | Tolva de microfiltro y barra estructural de torretas. | `x1.80` |

---

## 4. Estructura del Proyecto

```text
project-mechanic/
├── README.md                           # Documentación técnica y guía de reporte
├── planificacion.md                    # Plan de arquitectura y roadmap por incrementos
├── run.pl                              # Punto de entrada interactivo para consola
├── src/
│   ├── kb/                             # CAPA 1: Base de Conocimiento (EDB)
│   │   ├── catalogos_kb.pl             # Maniobras base, precios, vocabulario de síntomas y testigos
│   │   ├── vehiculos_kb.pl             # 10 vehículos, multiplicadores y compatibilidad por subsistema
│   │   ├── topologia_kb.pl             # Grafos de desensamble DAG (obstruye/3) de los 10 modelos
│   │   └── fallas_kb.pl                # Mapeo clínico: Falla -> Componente, Síntomas y Testigos
│   │
│   ├── core/                           # CAPAS 2 y 3: Motores de Inferencia Lógica (IDB pura)
│   │   ├── grafo_motor.pl              # DFS post-orden, orden topológico y detector de ciclos
│   │   ├── cotizador_motor.pl          # Costeo con maplist/foldl, idempotencia e inversibilidad
│   │   └── diagnostico_motor.pl        # Diagnóstico estricto (forall/2) y heurístico ponderado
│   │
│   ├── service/                        # CAPA 4A: Orquestación / Casos de Uso (Sin I/O)
│   │   └── taller_servicio.pl          # Generación de órdenes y encadenamiento con filtro de motor
│   │
│   └── ui/                             # CAPA 4B: Presentación e Interacción de Usuario (I/O)
│       └── reporte_cli.pl              # Menú numérico (1-4) y tablas formateadas con format/2
│
└── tests/                              # SUITE DE PRUEBAS AUTOMATIZADAS (library(plunit))
    ├── run_all_tests.pl                # Runner central de pruebas
    ├── test_catalogos_vehiculos.plt    # Integridad de catálogos y compatibilidad mecánica (11 tests)
    ├── test_kb_integridad.plt          # Auditoría estática: DAG sin ciclos ni piezas huérfanas (12 tests)
    ├── test_grafo_motor.plt            # Orden físico, diamantes y clausura transitiva (7 tests)
    ├── test_cotizador_motor.plt        # Presupuestos, ahorro por idempotencia e inversibilidad (6 tests)
    ├── test_diagnostico_motor.plt      # Certeza aritmética, coincidencia estricta y ranking (6 tests)
    └── test_taller_servicio.plt        # Integración End-to-End clínica + cotización (4 tests)
```

---

## 5. Guía Rápida de Uso del Programa

### 5.1. Requisitos
* Tener instalado **SWI-Prolog** (versión 9 o 10). Para verificar en consola:
  ```powershell
  swipl --version
  ```

### 5.2. Inicio Rápido (Menú Numérico Interactivo)
1. Abre una terminal en la carpeta raíz del proyecto y ejecuta:
   ```powershell
   swipl run.pl
   ```
2. En el prompt interactivo de Prolog, escribe:
   ```prolog
   ?- menu.
   ```
3. Se desplegará el menú principal para seleccionar con números del **1 al 4**:

```text
================================================================================
        SISTEMA EXPERTO DE DIAGNOSTICO AUTOMOTRIZ Y COTIZACION DINAMICA
================================================================================
 Seleccione una opcion ingresando su numero (1-4):

  [1] Listar catalogo de vehiculos (10 modelos, arquitectura y tarifas)
  [2] Listar catalogo de sintomas observables disponibles
  [3] Listar catalogo de testigos de tablero y codigos OBD-II disponibles
  [4] Diagnosticar vehiculo y cotizar orden de trabajo (Atender cliente)
  [0] Salir del sistema
================================================================================
Ingrese su opcion [0-4]: 
```

### 5.3. Descripción de las Opciones del Menú

#### Opción `1`: Listar Catálogo de Vehículos
Muestra los 10 modelos disponibles, su configuración mecánica y su factor multiplicador de tarifa.

#### Opción `2`: Listar Catálogo de Síntomas Disponibles
Despliega el catálogo clínico completo con el identificador exacto en Prolog que puedes usar (ej. `tironeo_al_acelerar`, `ralenti_inestable`, `humo_negro`, `sobrecalentamiento`, etc.) y su descripción.

#### Opción `3`: Listar Catálogo de Testigos y Códigos OBD-II
Despliega los testigos de tablero y códigos de diagnóstico registrados (ej. `check_engine`, `codigo_p0300`, `codigo_p0200`, `testigo_bateria`, etc.).

#### Opción `4`: Atender Cliente (Diagnóstico y Cotización en Vivo)
Flujo asistido por teclado:
1. Pide seleccionar el vehículo ingresando su **número (1 al 10)** o su nombre en Prolog (ejemplo: `5` o `maxima_v6`).
2. Pide ingresar los síntomas observados separados por comas (ejemplo: `tironeo_al_acelerar, ralenti_inestable`).
3. Pide ingresar los testigos o códigos de escáner separados por comas (ejemplo: `check_engine`).
4. El sistema evalúa las hipótesis clínicas, descarta las piezas incompatibles con el motor y emite la orden de desensamble y el presupuesto desglosado:

```text
================================================================================
                   RESULTADO DE DIAGNOSTICO CLINICO
================================================================================
Dictamen:      [SUGERENCIA CLINICA] (60% de certeza heuristica)
Falla:         fallo_encendido_bujias
Componente:    bujias

================================================================================
                       ORDEN DE SERVICIO AUTOMOTRIZ
================================================================================
Vehiculo:      Nissan Maxima 3.5L V6 (maxima_v6)
Arquitectura:  v6_transversal
Factor Tarifa: x1.50
Servicio(s):   [bujias]
--------------------------------------------------------------------------------
 #   PIEZA / MANIOBRA               COSTO BASE       TIEMPO
--------------------------------------------------------------------------------
 1   cubierta_motor                 $50 MXN          5 min
 2   cuerpo_aceleracion             $300 MXN         30 min
 3   mangueras_vacio                $150 MXN         20 min
 4   pleno_admision                 $650 MXN         60 min
 5   bobinas_ignicion               $150 MXN         15 min
 6   bujias                         $200 MXN         20 min
--------------------------------------------------------------------------------
Subtotal Base (Mano de Obra):          $1500 MXN   (150 min / 2.50 hrs)
Factor de Complejidad:                     x1.50
--------------------------------------------------------------------------------
COSTO TOTAL ESTIMADO:                  $2250 MXN
================================================================================
```

---

## 6. Consultas Declarativas Directas desde Prolog

Si deseas realizar consultas directas desde el prompt `?-` sin pasar por el menú:

### 6.1. Diagnosticar y Cotizar Directamente
```prolog
?- atender_cliente_cli(maxima_v6, [tironeo_al_acelerar, ralenti_inestable], [check_engine]).
```

### 6.2. Cotizar una Orden con Servicios Múltiples (Idempotencia)
```prolog
?- cotizar_orden_multiple(maxima_v6, [bujias, inyectores], Pasos, TiempoMin, CostoMXN).
% Pasos = [cubierta_motor, cuerpo_aceleracion, mangueras_vacio, pleno_admision, bobinas_ignicion, bujias, riel_inyectores, inyectores]
% TiempoMin = 225
% CostoMXN = 3375
```

### 6.3. Consulta Inversible por Presupuesto Máximo
*¿Qué servicios le alcanza a realizar a un Nissan Tsuru con un presupuesto de $300 MXN o menos?*
```prolog
?- servicios_dentro_presupuesto(tsuru_gs2, 300, Servicio, Costo).
% Servicio = bujias, Costo = 280 ;
% Servicio = bateria, Costo = 100 ;
% ...
```

### 6.4. Inversibilidad sobre la Topología Mecánica
*¿En qué vehículos es obligatorio desmontar el pleno de admisión para poder cambiar las bujías?*
```prolog
?- setof(Carro, requiere_desmontar(Carro, bujias, pleno_admision), Autos).
% Autos = [maxima_v6, odyssey_v6].
```

---

## 7. Ejecución de Pruebas Automatizadas (Testing con `plunit`)

El proyecto cuenta con **46 pruebas unitarias y de integración** automatizadas que certifican la integridad del grafo, la ausencia de ciclos y la exactitud matemática de los presupuestos.

Para correr toda la suite de pruebas desde la terminal:
```powershell
swipl -g "consult('tests/run_all_tests.pl'), run_tests" -t halt
```

**Resultado esperado:**
```text
% All 46 tests passed in 0.041 seconds (0.031 cpu)
```
