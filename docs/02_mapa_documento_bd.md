# Etapa 2 — Mapa `Documento → Campo → Tabla → Relación → Indicador`

Cumple con la sección 6 del prompt maestro: relaciona lo que ya está escrito en el PDF con la estructura SQL Server y con los indicadores Power BI. Nada se inventa.

**Convención:** `[DOC]` = literal del PDF · `[DIS]` = decisión de diseño del sistema.

---

## Bloque 1 · Registro de inventario

| Documento | Campo del formulario | Tabla SQL | Columna | Tipo SQL [DIS] | Indicador Power BI |
|---|---|---|---|---|---|
| Anexo B (T03) | Tipo de equipo | `Equipos` | `tipo_equipo` | NVARCHAR(60) | Distribución por tipo |
| Anexo B (T03) | Marca | `Equipos` | `marca` | NVARCHAR(60) | Distribución por marca |
| Anexo B (T03) | Modelo | `Equipos` | `modelo` | NVARCHAR(60) | — |
| Anexo B (T03) | Número de serie | `Equipos` | `numero_serie` | NVARCHAR(80) UNIQUE | — |
| Anexo B (T03) | Código interno del activo | `Equipos` | `codigo_interno` | NVARCHAR(20) UNIQUE | Identificador clave |
| Anexo B (T03) | Ubicación | `Equipos` | `ubicacion` | NVARCHAR(120) | — |
| Anexo B (T03) | Departamento / responsable | `Equipos` → `Departamentos` + `Responsables` | `id_departamento`, `id_responsable` | INT FK | Equipos por departamento |
| Anexo B (T03) | Estado del equipo | `Equipos` | `estado_equipo` | NVARCHAR(30) CHECK | Estado actual |
| Anexo B (T03) | Fecha de adquisición | `Equipos` | `fecha_adquisicion` | DATE | Antigüedad promedio |
| Anexo B (T03) | Fecha de último mantenimiento | `Equipos` | `fecha_ultimo_mantenimiento` | DATE NULL | — |
| Anexo B (T03) | Fecha de retiro | `Equipos` | `fecha_retiro` | DATE NULL | Permanencia en almacén |
| Anexo B (T03) | Motivo del retiro | `Equipos` | `motivo_retiro` | NVARCHAR(200) NULL | Causas de retiro |

**Origen del código interno**: mencionado literal en Anexo B como "código interno del activo". El **formato** `EQ-<TIPO>-<NNNN>` (ej. `EQ-LAP-0001`) es [DIS], propuesto en Etapa 1.

---

## Bloque 2 · Evaluación técnica

Anexo C tiene tres partes; se normaliza en tres tablas.

### 2.1 Encabezado y resultado (T04 + T07)

| Documento | Campo | Tabla | Columna | Tipo |
|---|---|---|---|---|
| Anexo C T04 | Código interno | `Evaluaciones` | `id_equipo` FK → `Equipos` | INT |
| Anexo C T04 | Fecha de evaluación | `Evaluaciones` | `fecha_evaluacion` | DATE |
| Anexo C T04 | Responsable | `Evaluaciones` | `id_responsable` FK → `Responsables` | INT |
| Anexo C T07 | Costo estimado de reparación (RD$) | `Evaluaciones` | `costo_estimado_rd` | DECIMAL(10,2) NULL |
| Anexo C T07 | ¿La reparación es viable? | `Evaluaciones` | `reparacion_viable` | BIT NULL |
| Anexo C T07 | Clasificación final | `Evaluaciones` | `clasificacion_final` | NVARCHAR(20) CHECK ('Reutilizable','Reparable','No recuperable') |
| Anexo C T07 | Destino propuesto | `Evaluaciones` | `destino_propuesto` | NVARCHAR(120) |
| Anexo C T07 | Firma del responsable técnico | `Evaluaciones` | `firma_responsable` | NVARCHAR(200) NULL |

**Indicadores alimentados:** Equipos evaluados, distribución por clasificación final, tasa de viabilidad de reparación.

### 2.2 Evaluación física (T05) — 7 elementos por evaluación

Se guarda una fila por elemento:

| Documento | Campo | Tabla | Columna | Tipo |
|---|---|---|---|---|
| Anexo C T05 | `id_evaluacion` (link) | `EvaluacionFisica` | `id_evaluacion` FK | INT |
| Anexo C T05 | Elemento | `EvaluacionFisica` | `elemento` | NVARCHAR(30) CHECK (7 valores) |
| Anexo C T05 | Bien / Dañado | `EvaluacionFisica` | `estado` | CHAR(1) CHECK ('B','D') |
| Anexo C T05 | Observaciones | `EvaluacionFisica` | `observaciones` | NVARCHAR(300) NULL |

Elementos [DOC]: `Pantalla`, `Teclado`, `Carcasa`, `Cables`, `Puertos`, `Batería`, `Fuente de alimentación`.

### 2.3 Evaluación técnica (T06) — 4 aspectos por evaluación

| Documento | Campo | Tabla | Columna | Tipo |
|---|---|---|---|---|
| Anexo C T06 | `id_evaluacion` (link) | `EvaluacionTecnica` | `id_evaluacion` FK | INT |
| Anexo C T06 | Aspecto verificado | `EvaluacionTecnica` | `aspecto` | NVARCHAR(80) CHECK (4 valores) |
| Anexo C T06 | Sí / No | `EvaluacionTecnica` | `resultado` | BIT |
| Anexo C T06 | Observaciones | `EvaluacionTecnica` | `observaciones` | NVARCHAR(300) NULL |

Aspectos [DOC]: `¿Enciende correctamente?`, `¿El sistema operativo funciona?`, `¿Ejecuta los programas necesarios?`, `¿Los componentes internos están en buen estado?`.

---

## Bloque 3 · Reparaciones

Origen [DOC]: Capítulo III.4 (categoría "Reparable") y Capítulo IV.5. Los campos exactos son [DIS] siguiendo la sección 12 del prompt maestro.

| Campo | Tabla | Columna | Tipo |
|---|---|---|---|
| Equipo | `Reparaciones` | `id_equipo` FK | INT |
| Fecha de inicio | `Reparaciones` | `fecha_inicio` | DATE |
| Fecha de finalización | `Reparaciones` | `fecha_fin` | DATE NULL |
| Falla encontrada | `Reparaciones` | `falla_encontrada` | NVARCHAR(300) |
| Trabajo realizado | `Reparaciones` | `trabajo_realizado` | NVARCHAR(500) NULL |
| Costo | `Reparaciones` | `costo_rd` | DECIMAL(10,2) NULL |
| Resultado | `Reparaciones` | `resultado` | NVARCHAR(20) CHECK ('Recuperado','No recuperado','En proceso') |
| Responsable | `Reparaciones` | `id_responsable` FK | INT |
| Observaciones | `Reparaciones` | `observaciones` | NVARCHAR(300) NULL |

**Indicador alimentado:** *Equipos reparados* (Cap. IV.7 T02).

---

## Bloque 4 · Borrado seguro (Anexo D T08+T09)

| Documento | Campo | Tabla | Columna | Tipo |
|---|---|---|---|---|
| Anexo D | Equipo / código interno / n.º de serie | `BorradosSeguros` | `id_equipo` FK | INT |
| Anexo D | Tipo de soporte de almacenamiento | `BorradosSeguros` | `tipo_soporte` | NVARCHAR(60) |
| Anexo D | Método aplicado (sobreescritura / destrucción física) | `BorradosSeguros` | `id_metodo` FK → `MetodosBorrado` | INT |
| Anexo D | Herramienta / procedimiento | `BorradosSeguros` | `herramienta` | NVARCHAR(120) NULL |
| Anexo D | Verificación posterior del borrado | `BorradosSeguros` | `verificacion_posterior` | BIT |
| Anexo D | Fecha del procedimiento | `BorradosSeguros` | `fecha_procedimiento` | DATE |
| Anexo D | Responsable del borrado | `BorradosSeguros` | `id_responsable_borrado` FK | INT |
| Anexo D | Verificado por | `BorradosSeguros` | `id_responsable_verifica` FK | INT |
| Anexo D | Destino autorizado del equipo | `BorradosSeguros` | `destino_autorizado` | NVARCHAR(200) NULL |
| Anexo D | Evidencia / documentación | `BorradosSeguros` | `evidencia_ruta` | NVARCHAR(300) NULL |

Catálogo `MetodosBorrado` [DIS]: `SOBREESCRITURA`, `DESTRUCCION_FISICA`, `DESMAGNETIZACION`.

**Indicador alimentado:** *Borrado seguro documentado* (Cap. IV.7 T02).

---

## Bloque 5 · Movimientos / trazabilidad (Cap. IV.2)

Los 5 pasos del procedimiento → 11 estados. Cada transición es una fila:

| Documento | Campo | Tabla | Columna | Tipo |
|---|---|---|---|---|
| Cap. IV.2 | Equipo | `Movimientos` | `id_equipo` FK | INT |
| Cap. IV.2 | Estado / etapa | `Movimientos` | `id_estado` FK → `EstadosMovimiento` | INT |
| Cap. IV.2 | Fecha | `Movimientos` | `fecha` | DATETIME2 |
| Cap. IV.2 | Responsable | `Movimientos` | `id_responsable` FK | INT |
| Cap. IV.2 | Observación / info adicional | `Movimientos` | `observacion` | NVARCHAR(500) NULL |
| Cap. IV.7 T02 | Valor de compra evitada (RD$) | `Movimientos` | `valor_evitado_rd` | DECIMAL(10,2) NULL |

Estados [DIS] (11):
`REGISTRADO`, `EN_ALMACEN_TEMPORAL`, `EN_EVALUACION`, `CLASIFICADO_REUTILIZABLE`, `CLASIFICADO_REPARABLE`, `CLASIFICADO_NO_RECUPERABLE`, `EN_REPARACION`, `REASIGNADO`, `BORRADO_SEGURO_APLICADO`, `ENTREGADO_A_GESTOR`, `CERRADO`.

**Indicadores alimentados:** *Permanencia en almacén temporal*, *Compras evitadas*, *Expedientes completos*.

---

## Bloque 6 · Entrega al gestor (Anexo E T10-T13) y gestores (Anexo G T17)

### 6.1 Gestores RAEE (catálogo desde T17)

| Documento | Campo | Tabla | Columna |
|---|---|---|---|
| Anexo G T17 | Empresa | `GestoresRAEE` | `nombre` |
| Anexo G T17 | Ubicación | `GestoresRAEE` | `ubicacion` |
| Anexo G T17 | Autorización (permiso ambiental) | `GestoresRAEE` | `autorizacion` |
| Anexo G T17 | Actividad autorizada | `GestoresRAEE` | `actividad_autorizada` |
| Anexo G T17 | Teléfono | `GestoresRAEE` | `telefono` NULL |

Cuatro filas semilla [DOC]: **MIRSA**, **RESICLA**, **JRC Services**, **Ecologix**.

### 6.2 Acta de entrega

| Documento | Campo | Tabla | Columna |
|---|---|---|---|
| Anexo E T10 | Empresa que entrega | `ActasEntrega` | `empresa_entrega` |
| Anexo E T10 | Gestor que recibe | `ActasEntrega` | `id_gestor` FK |
| Anexo E T10 | N.º autorización del gestor | `ActasEntrega` | `numero_autorizacion` |
| Anexo E T10 | Fecha de entrega | `ActasEntrega` | `fecha_entrega` |
| Anexo E T10 | Lugar de entrega | `ActasEntrega` | `lugar_entrega` |
| Anexo E T12 | Cantidad total de equipos | `ActasEntrega` | `cantidad_equipos` |
| Anexo E T12 | Peso aproximado (kg) | `ActasEntrega` | `peso_kg` |

### 6.3 Lista de equipos entregados (T11)

| Documento | Campo | Tabla | Columna |
|---|---|---|---|
| Anexo E T11 | Acta | `EquiposEnActa` | `id_acta` FK |
| Anexo E T11 | Equipo | `EquiposEnActa` | `id_equipo` FK |
| Anexo E T11 | Constancia de borrado | `EquiposEnActa` | `id_borrado` FK → `BorradosSeguros` |

**Indicador alimentado:** *RAEE gestionados correctamente* (kg entregados).

---

## Resumen · 7 indicadores del proyecto → consultas de Power BI

Las vistas del Etapa 9 se llamarán así [DIS]:

| Indicador [DOC] | Vista SQL [DIS] | Origen |
|---|---|---|
| Equipos reutilizados | `vw_indicador_reutilizados` | `Movimientos` (estado `REASIGNADO`) / `Movimientos` (`EN_EVALUACION`) |
| Equipos reparados | `vw_indicador_reparados` | `Reparaciones.resultado='Recuperado'` |
| RAEE gestionados correctamente | `vw_indicador_raee_gestionados` | `SUM(ActasEntrega.peso_kg)` |
| Borrado seguro documentado | `vw_indicador_borrado_documentado` | `BorradosSeguros` / equipos con salida |
| Permanencia en almacén temporal | `vw_indicador_permanencia_almacen` | `DATEDIFF` entre `EN_ALMACEN_TEMPORAL` y `ENTREGADO_A_GESTOR`/`REASIGNADO` |
| Compras evitadas | `vw_indicador_compras_evitadas` | `SUM(Movimientos.valor_evitado_rd)` de `REASIGNADO` |
| Expedientes completos | `vw_indicador_expedientes_completos` | `Equipos` con al menos un movimiento `CERRADO` |
