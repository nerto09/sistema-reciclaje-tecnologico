# Índice de capturas del sistema informático

Cumple con la sección 21 del prompt maestro. Cada captura tiene: **qué aparece / qué demuestra / dónde se incorpora**.

---

## 15 capturas listas — Etapas 1 a 8

### Instalación y modelo de la base de datos (capturas 00-03)

| # | Archivo | Qué aparece | Qué demuestra | Dónde se incorpora |
|---|---|---|---|---|
| 00 | `00_conexion_ok.txt` | Servidor `Cuervo`, login Windows, versión SQL Server 2025. | El entorno técnico está en pie antes de crear la base. | Metodología del sistema informático. |
| 01 | `01_bd_creada.txt` | `GestionReciclajeTecnologico` con fecha, tamaño (16 MB) y credencial. | `CREATE DATABASE` del script `01_esquema.sql` ejecutó. | Cap. VII § Base de datos. |
| 02 | `02_tablas_creadas.txt` | Las **14 tablas** con número de columnas y filas iniciales. | Todas las tablas del mapa están creadas. | Cap. VII § Estructura de la base de datos. |
| 03 | `03_relaciones.txt` | Las **19 Foreign Keys**. | La trazabilidad relacional del modelo ER. | Cap. VII § Relaciones y trazabilidad. |

### Poblado con datos reales (capturas 04-08)

| # | Archivo | Qué aparece | Qué demuestra | Dónde se incorpora |
|---|---|---|---|---|
| 04 | `04_equipos_registrados.txt` | Los **15 equipos** de la empresa tipo con estado y movs. | Anexo B → tabla `Equipos`. | Cap. VII § Registro de equipos. |
| 05 | `05_evaluacion_tecnica.txt` | 10 evaluaciones + 70 físicas + 40 técnicas. | Anexo C → 3 tablas normalizadas, 7×4 exactos por evaluación. | Cap. VII § Evaluación técnica. |
| 06 | `06_clasificacion.txt` | Reutilizables/Reparables/No recuperables + detalle por equipo. | Las 3 categorías del Cap. III.4 operan y se analizan. | Cap. VII § Clasificación. |
| 07 | `07_borrado_seguro.txt` | 4 constancias completas con método, herramienta y verificador. | Anexo D → registros auditables. | Cap. VII § Seguridad de la información. |
| 08 | `08_movimientos_trazabilidad.txt` | Historial completo de `EQ-LAP-0004` + acta de entrega a Ecologix. | Trazabilidad extremo a extremo del Cap. IV.2 y Anexo E. | Cap. VII § Movimientos y trazabilidad. |

### Programa Python del diagrama de flujo (Anexo A)

| # | Archivo | Qué aparece | Qué demuestra | Dónde se incorpora |
|---|---|---|---|---|
| 09 | `09_flujo_python_reutilizable.txt` | Ejecución en vivo de `flujo_equipo.py` sobre `EQ-LAP-0005`. | El diagrama de flujo del Anexo A está codificado y escribe cada paso en SQL Server. | Cap. VII § Implementación del diagrama de flujo. |

### Interfaz Tkinter (capturas 10-13, imágenes PNG)

| # | Archivo | Qué aparece | Qué demuestra | Dónde se incorpora |
|---|---|---|---|---|
| 10 | `10_tkinter_equipos.png` | Pestaña **1. Equipos** con las 15 filas del inventario coloreadas por estado. | Anexo B se puede consultar en interfaz gráfica. | Cap. VII § Interfaz de usuario. |
| 11 | `11_tkinter_evaluacion.png` | Pestaña **2. Evaluación** con encabezado + 7 elementos físicos + 4 aspectos técnicos. | Anexo C tiene formulario funcional. | Cap. VII § Interfaz - Evaluación. |
| 12 | `12_tkinter_historial.png` | Pestaña **4. Historial** con los 7 movimientos de `EQ-LAP-0004`. | Trazabilidad visible al usuario final. | Cap. VII § Interfaz - Historial. |
| 13 | `13_tkinter_indicadores.png` | Pestaña **5. Indicadores** — los 7 cards del Cap. IV.7 en vivo. | Los indicadores del proyecto se leen de SQL Server sin BI todavía. | Cap. VII § Interfaz - Indicadores. |

### Bonus indicadores

| # | Archivo | Qué aparece | Qué demuestra |
|---|---|---|---|
| — | `10_indicadores_prueba.txt` | Los 7 indicadores del Cap. IV.7 calculados por consulta SQL. | Fórmulas del proyecto verificadas contra los datos de prueba. |

---

## Volumetría del sistema

- **14** tablas · **19** foreign keys · **8** check constraints · **4** unique · **1** índice adicional.
- **15** equipos · **10** evaluaciones (70 físicas + 40 técnicas) · **2** reparaciones · **4** borrados seguros · **75** movimientos · **1** acta · **4** equipos entregados.

### Vistas para Power BI (Etapa 9 completada)

| # | Archivo | Qué aparece | Qué demuestra | Dónde se incorpora |
|---|---|---|---|---|
| 14 | `14_vistas_powerbi.txt` | Las **11 vistas SQL** creadas + su salida real: 7 indicadores + 4 vistas de detalle (`vw_equipos_completo`, `vw_movimientos_detalle`, `vw_bitacora_equipos`, `vw_kpis_resumen`). | La capa que Power BI consumirá está lista; los 7 indicadores del Cap. IV.7 son consultables como `SELECT * FROM vw_indicador_*`. | Cap. VII § Análisis de datos con Power BI. |

### Dashboard Power BI Desktop (Etapa 10 completada)

| # | Archivo | Qué aparece | Qué demuestra | Dónde se incorpora |
|---|---|---|---|---|
| 15 | `15_powerbi_dashboard.png` | Panel completo con los 7 KPI del Cap. IV.7 arriba (barra verde superior), gráfico de anillos de **Clasificación de los equipos**, **Bitácora de equipos** (T00 del proyecto), **Compras evitadas por tipo de equipo (RD$)** y **Movimientos por mes** apilados por estado. Conectado en modo Import a las 11 vistas de SQL Server. | La analítica visual del programa cierra el ciclo `Documento → Campo → Tabla → Vista → Dashboard` que exige el prompt maestro. Cada gráfico consume una vista real, sin datos duplicados ni cálculos ajenos al esquema. | Cap. VII § Analítica visual del programa. |

## Sistema completo — 16 capturas indexadas

- Capturas 00-03 · Instalación y modelo (BD, tablas, FKs)
- Capturas 04-08 · Poblado con datos reales (Anexos B-E)
- Captura 09 · Programa Python del diagrama de flujo (Anexo A)
- Capturas 10-13 · Interfaz Tkinter (imágenes PNG reales)
- Captura 14 · Vistas SQL para Power BI
- Captura 15 · Dashboard Power BI Desktop
- Bonus: `10_indicadores_prueba.txt` con los 7 indicadores calculados por consulta

Todos los archivos vivos: BD `GestionReciclajeTecnologico` con datos reales, `dashboard.pbix` conectado, `SistemaReciclajeTecnologico.exe` empaquetado en `dist/`.
