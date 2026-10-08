# Etapa 1 — Análisis del PDF del proyecto

**Fuente única:** `Propuesta de Programa de Reciclaje Tecnologico - Corregido.docx` (17 capítulos/anexos, 18 tablas).
**Alcance:** este documento cumple con la sección 23 del prompt maestro — **no se crea código todavía**. Se identifica todo lo que YA está escrito en el proyecto y se propone cómo se llevará a SQL Server + Python + Power BI, pero la aprobación queda pendiente.

**Distinción usada en todo el documento:**
- **[DOC]** — la información sale literalmente del PDF (capítulo o anexo indicado).
- **[DIS]** — decisión de diseño del sistema (nombre de tabla, tipo SQL, formato del código, etc.). No está escrito así en el PDF.

---

## 1. Contenido existente que debe conservarse

Toda la estructura académica del documento se mantiene tal cual. Ninguno de estos bloques se toca:

| Sección | Qué conserva |
|---|---|
| Introducción / Justificación | Prosa completa |
| Capítulo I | El problema y la empresa tipo |
| Capítulo II | Objetivos general y específicos, alcance |
| Capítulo III | Identificación, registro, evaluación, clasificación y destinos |
| Capítulo IV | Descripción del programa, procedimiento (5 pasos), responsables, almacenamiento, entrega, control, presupuesto y viabilidad |
| Capítulo V | Seguridad de la información, ética y contaminación |
| Capítulo VI | Beneficios y resultados esperados |
| Anexo A | **Diagrama de flujo del procedimiento** — es el que se codificará en Python |
| Anexo B | Formato de registro de inventario |
| Anexo C | Ficha de evaluación técnica |
| Anexo D | Constancia de borrado seguro |
| Anexo E | Acta de entrega a gestor autorizado |
| Anexo F | Cotizaciones del presupuesto |
| Anexo G | Marco legal + gestores autorizados |

La sección nueva ("Sistema informático para la gestión, seguimiento y análisis de los equipos tecnológicos") se **agrega al final del Capítulo IV** o como capítulo VII, sin borrar nada de lo anterior.

---

## 2. Campos identificados por capítulo/anexo

### Capítulo III — Identificación, registro y clasificación
- **3.4 Clasificación** — categorías: `Reutilizable`, `Reparable`, `No recuperable`.
- **3.5 Destino** — `Reasignación interna`, `Reparación`, `Reciclaje / entrega a gestor`.
- **3.6 Bitácora ejemplo (T00):** Equipo, Estado, Clasificación, Decisión, Fecha.

### Capítulo IV — Procedimiento
- **4.2 Los 5 pasos** — Retiro y registro → Evaluación → Clasificación → Destino → Documentación.
- **4.3 Responsables** — Coordinador del programa, Inventario/TI, Evaluación técnica, Gestor autorizado.
- **4.7 Indicadores (T02):** 7 indicadores (reutilizados, reparados, RAEE gestionados, borrado documentado, permanencia en almacén, compras evitadas, expedientes completos).
- **4.8 Presupuesto (T01):** RD$91,745.50 con 7 renglones cotizados + 3 pendientes.

### Anexo B — Formato de registro de inventario (T03)
12 campos: `Tipo de equipo`, `Marca`, `Modelo`, `Número de serie`, `Código interno del activo`, `Ubicación`, `Departamento o usuario responsable`, `Estado del equipo`, `Fecha de adquisición`, `Fecha de último mantenimiento`, `Fecha de retiro`, `Motivo del retiro`.

### Anexo C — Ficha de evaluación técnica
- **Encabezado (T04):** `Código interno del equipo`, `Fecha de evaluación`, `Responsable`.
- **Evaluación física (T05):** 7 elementos → `Pantalla`, `Teclado`, `Carcasa`, `Cables`, `Puertos`, `Batería`, `Fuente de alimentación`. Cada uno con `Bien/Dañado/Observaciones`.
- **Evaluación técnica (T06):** 4 aspectos → `¿Enciende correctamente?`, `¿El sistema operativo funciona?`, `¿Ejecuta los programas necesarios?`, `¿Los componentes internos están en buen estado?`. Cada uno con `Sí/No/Observaciones`.
- **Resultado (T07):** `Costo estimado de reparación`, `¿La reparación resulta viable?`, `Clasificación final`, `Destino propuesto`, `Firma del responsable técnico`.

### Anexo D — Constancia de borrado seguro (T08+T09)
11 campos: `Equipo`, `Código interno del activo`, `Número de serie`, `Tipo de soporte de almacenamiento`, `Método aplicado (sobreescritura/destrucción física)`, `Herramienta o procedimiento utilizado`, `Verificación posterior del borrado`, `Fecha del procedimiento`, `Responsable del borrado`, `Verificado por`, `Destino autorizado del equipo`.

### Anexo E — Acta de entrega a gestor autorizado
- **Encabezado (T10):** `Empresa que entrega`, `Gestor autorizado que recibe`, `Número de registro o autorización del gestor`, `Fecha de entrega`, `Lugar de entrega`.
- **Lista de equipos entregados (T11):** `N.º`, `Equipo`, `Código interno`, `Número de serie`, `Constancia de borrado`.
- **Totales (T12):** `Cantidad total de equipos entregados`, `Peso aproximado (kg)`.
- **Firmas (T13):** `Por la empresa`, `Por el gestor autorizado`.

### Anexo G — Marco legal y gestores
- **T15 Obligaciones legales atendidas** (5 obligaciones del Decreto 253-23).
- **T16 Prohibiciones del artículo 72** (6 actividades prohibidas).
- **T17 Gestores autorizados:** MIRSA (Santiago), RESICLA (Sto. Dgo.), JRC Services (Sto. Dgo.), Ecologix (Sto. Dgo.). Cada uno con autorización ambiental vigente y actividad autorizada.

---

## 3. Campos que se convierten en tablas SQL

Once tablas, todas con origen documental salvo las relaciones internas (marcadas [DIS]):

| # | Tabla [DIS] | Origen [DOC] | Rol |
|---|---|---|---|
| 1 | `Responsables` | Capítulo IV.3 + firmas de anexos C, D, E | Personas que operan el programa |
| 2 | `Departamentos` | Anexo B (campo "Departamento o usuario responsable") | Ubicación organizacional |
| 3 | `GestoresRAEE` | Anexo G tabla T17 | Empresas autorizadas de recolección |
| 4 | `Equipos` | Anexo B (12 campos) | Registro maestro de cada activo |
| 5 | `Evaluaciones` | Anexo C encabezado + resultado (T04+T07) | Una evaluación por equipo/fecha |
| 6 | `EvaluacionFisica` | Anexo C tabla T05 | 7 filas por evaluación (una por elemento) |
| 7 | `EvaluacionTecnica` | Anexo C tabla T06 | 4 filas por evaluación (una por aspecto) |
| 8 | `Reparaciones` | Capítulo III.4 (categoría "Reparable") + prompt sección 12 | Historial de intentos de reparación |
| 9 | `BorradosSeguros` | Anexo D (T08) | Una constancia por equipo que sale con datos |
| 10 | `Movimientos` | Capítulo IV.2 + prompt sección 14 | Bitácora de cambios de estado — trazabilidad |
| 11 | `ActasEntrega` | Anexo E (T10+T12) | Acta al gestor; enlaza con `EquiposEnActa` |
| 12 | `EquiposEnActa` | Anexo E tabla T11 | Relación N-a-N entre actas y equipos |

Categorías de clasificación (Reutilizable/Reparable/No recuperable), tipos de método de borrado, y estados del ciclo de vida se manejan como **CHECK constraints** o como catálogos pequeños; queda a definir en la Etapa 3.

---

## 4. Campos que se convierten en relaciones (claves foráneas)

| Desde | Campo | Hacia | Origen del vínculo |
|---|---|---|---|
| `Equipos` | `id_departamento` | `Departamentos` | Anexo B campo "Departamento" |
| `Equipos` | `id_responsable` | `Responsables` | Anexo B campo "responsable" |
| `Evaluaciones` | `id_equipo` | `Equipos` | Anexo C encabezado (código interno) |
| `Evaluaciones` | `id_responsable` | `Responsables` | Anexo C "responsable" |
| `EvaluacionFisica` | `id_evaluacion` | `Evaluaciones` | Estructura del Anexo C |
| `EvaluacionTecnica` | `id_evaluacion` | `Evaluaciones` | Estructura del Anexo C |
| `Reparaciones` | `id_equipo` | `Equipos` | Cap. III |
| `Reparaciones` | `id_responsable` | `Responsables` | Cap. III |
| `BorradosSeguros` | `id_equipo` | `Equipos` | Anexo D "código interno" |
| `BorradosSeguros` | `id_responsable_borrado` | `Responsables` | Anexo D "Responsable del borrado" |
| `BorradosSeguros` | `id_responsable_verifica` | `Responsables` | Anexo D "Verificado por" |
| `Movimientos` | `id_equipo` | `Equipos` | Cap. IV.2 |
| `Movimientos` | `id_responsable` | `Responsables` | Cap. IV.3 |
| `ActasEntrega` | `id_gestor` | `GestoresRAEE` | Anexo E "Gestor autorizado" |
| `EquiposEnActa` | `id_acta` | `ActasEntrega` | Anexo E tabla T11 |
| `EquiposEnActa` | `id_equipo` | `Equipos` | Anexo E tabla T11 |
| `EquiposEnActa` | `id_borrado_seguro` | `BorradosSeguros` | Anexo E T11 "Constancia de borrado" |

---

## 5. Procesos que quedan registrados como movimientos

Los 5 pasos del Capítulo IV.2 son los estados que un equipo puede tener. Cada transición se guarda como una fila en `Movimientos`:

| Estado del equipo | Origen [DOC] |
|---|---|
| `REGISTRADO` | Cap. IV.2 paso 1 — Retiro y registro |
| `EN_ALMACEN_TEMPORAL` | Cap. IV.4 |
| `EN_EVALUACION` | Cap. IV.2 paso 2 |
| `CLASIFICADO_REUTILIZABLE` | Cap. IV.2 paso 3 + Anexo C |
| `CLASIFICADO_REPARABLE` | Cap. IV.2 paso 3 + Anexo C |
| `CLASIFICADO_NO_RECUPERABLE` | Cap. IV.2 paso 3 + Anexo C |
| `EN_REPARACION` | Cap. IV.5 |
| `REASIGNADO` | Cap. III.5 (reutilización) |
| `BORRADO_SEGURO_APLICADO` | Cap. V + Anexo D |
| `ENTREGADO_A_GESTOR` | Cap. IV.6 + Anexo E |
| `CERRADO` | Cap. IV.2 paso 5 — Documentación |

Es exactamente la ruta del **diagrama de flujo del Anexo A** — que es el que se implementará en Python.

---

## 6. Indicadores que Power BI calculará

Directo de la tabla T02 del Capítulo IV.7. **Ninguno se reemplaza**:

| Indicador [DOC] | Fórmula [DOC] | Tabla(s) que lo alimenta [DIS] |
|---|---|---|
| Equipos reutilizados | Equipos reasignados / equipos evaluados | `Movimientos` (estado `REASIGNADO` / `EN_EVALUACION`) |
| Equipos reparados | Equipos recuperados mediante reparación | `Reparaciones` con resultado exitoso |
| RAEE gestionados correctamente | Kilogramos entregados a gestor autorizado | `ActasEntrega.peso_kg` acumulado |
| Borrado seguro documentado | Constancias firmadas / equipos que salieron | `BorradosSeguros` / equipos con estado `ENTREGADO_A_GESTOR` |
| Permanencia en almacén temporal | Días promedio entre retiro y destino final | `Movimientos` (diferencia de fechas por equipo) |
| Compras evitadas | Valor RD$ de los equipos reasignados | Campo `valor_estimado_rd` en `Movimientos` de `REASIGNADO` [DIS] |
| Expedientes completos | Equipos con destino final registrado / total | Consulta de completitud sobre `Equipos` + `Movimientos` |

---

## 7. Propuesta inicial de tablas (resumen ejecutivo)

```
Responsables ─┐         ┌─ Departamentos
              │         │
              └─ Equipos ─┬─ Evaluaciones ─┬─ EvaluacionFisica
                          │                └─ EvaluacionTecnica
                          ├─ Reparaciones
                          ├─ BorradosSeguros
                          ├─ Movimientos
                          └─ EquiposEnActa ── ActasEntrega ── GestoresRAEE
```

Además, dos catálogos pequeños [DIS] para no repetir strings:
- `EstadosMovimiento` (11 estados listados en el punto 5)
- `MetodosBorrado` (sobreescritura / destrucción física / desmagnetización)

El diagrama entidad-relación formal viene en la Etapa 3, ya con cardinalidades.

---

## 8. Propuesta inicial de relaciones

Ya listadas en el punto 4. En texto:
- Un equipo pertenece a un departamento y tiene un responsable actual.
- Un equipo tiene N evaluaciones (una por fecha).
- Cada evaluación tiene exactamente 7 filas de evaluación física y 4 de evaluación técnica.
- Un equipo tiene N reparaciones (posiblemente 0).
- Un equipo tiene 0 o 1 borrado seguro (el vigente).
- Un equipo tiene N movimientos.
- Un acta entrega N equipos; un equipo aparece en 0 o 1 acta.
- Cada acta va a un gestor RAEE.

---

## 9. Campos que provienen directamente del documento [DOC]

Todos los que aparecen en:
- Anexo B (12 campos de inventario)
- Anexo C (7 elementos físicos + 4 aspectos técnicos + 5 campos de resultado + 3 de encabezado)
- Anexo D (11 campos de borrado seguro)
- Anexo E (5 de encabezado + 5 columnas de lista + 2 totales)
- Anexo G T17 (4 gestores con nombre, ubicación, autorización y actividad)
- Cap. IV.3 (4 roles de responsable)
- Cap. IV.7 T02 (7 indicadores)
- Cap. IV.2 (5 pasos → 11 estados del ciclo de vida)

Estos **no se inventan**: son la columna vertebral del sistema.

---

## 10. Campos que son decisión de diseño [DIS]

Elementos que el sistema necesita para funcionar pero **no están escritos así en el PDF**. Se identifican como diseño técnico:

- **Nombre de la BD:** `GestionReciclajeTecnologico`.
- **Nombres de tablas** (Equipos, Responsables, …).
- **Claves primarias** (`id_equipo INT IDENTITY(1,1)`, etc.).
- **Formato del código interno:** `EQ-<TIPO>-<NNNN>` — por ej. `EQ-LAP-0001`, `EQ-MON-0003`. El PDF menciona el concepto de código interno pero no fija el formato.
- **Tipos de dato SQL** (VARCHAR/NVARCHAR, INT, DATE, DECIMAL, BIT).
- **Catálogos** `EstadosMovimiento` y `MetodosBorrado` (para normalizar).
- **Campos de auditoría** (`fecha_creacion DATETIME2`, `usuario_creacion NVARCHAR(60)`).
- **Vistas** para Power BI (`vw_indicador_reutilizacion`, `vw_permanencia_almacen`, etc.).
- **Interfaz Tkinter** — se decide layout, no está escrito en el PDF.
- **Conexión Python↔SQL Server** por `pyodbc + ODBC Driver 18`.
- **Nombre y estructura del dashboard Power BI.**

---

## Estado del entorno técnico (verificado hoy)

- Python 3.14.7 + Tkinter 9.0 ✓
- python-docx ✓
- **pyodbc 5.3.0** (instalado en esta sesión) ✓
- **SQL Server 2025** instancia por defecto `MSSQLSERVER` corriendo ✓
- **ODBC Driver 18 for SQL Server** ✓
- Instancia secundaria `SQLEXPRESS` (SQL Server 2019) detenida — no la usamos.

---

## Qué necesito de ti para continuar a la Etapa 2

1. **Aprobación** del análisis anterior (o correcciones).
2. **Confirmación** de la instancia SQL Server a usar. Propuesta: `localhost\MSSQLSERVER` con **autenticación de Windows** (la más simple; nada de contraseñas en el código).
3. **Confirmación** del formato del código interno propuesto (`EQ-<TIPO>-<NNNN>`).
4. Cualquier campo del documento que consideres que **falté**.

Cuando confirmes, paso a la Etapa 2 (mapa `Documento → Campo → Tabla → Relación → Indicador`), y solo cuando eso también quede aprobado creo el `esquema.sql`.
