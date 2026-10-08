# Etapa 10 · Dashboard Power BI Desktop

Este README es la guía para construir el dashboard `dashboard.pbix` con los datos que ya están en SQL Server (11 vistas listas, ver [`sql/03_vistas_powerbi.sql`](../sql/03_vistas_powerbi.sql)).

## 1. Conectar Power BI a la BD

1. Abre **Power BI Desktop**.
2. `Inicio` → `Obtener datos` → **SQL Server**.
3. Configura la conexión:
   - **Servidor:** `localhost`
   - **Base de datos:** `GestionReciclajeTecnologico`
   - **Modo de conectividad:** *Importación* (para el trabajo académico es suficiente; también sirve *DirectQuery* si quieres que refresque en vivo).
4. `Aceptar` → Windows → `Usar mis credenciales actuales` → `Conectar`.
5. En el navegador, marca las **11 vistas** que aparecen bajo `dbo`:
   - `vw_kpis_resumen` — para las **tarjetas** (KPI cards).
   - `vw_equipos_completo` — para tablas y filtros.
   - `vw_movimientos_detalle` — línea de tiempo, bitácora.
   - `vw_bitacora_equipos` — tabla resumen (formato T00 del proyecto).
   - `vw_indicador_reutilizados` / `_reparados` / `_raee_gestionados` / `_borrado_documentado` / `_permanencia_almacen` / `_compras_evitadas` / `_expedientes_completos`.
6. Pulsa `Cargar`.

## 2. Estructura sugerida del dashboard (una página)

Título arriba: **"Programa de Reciclaje Tecnológico — Panel de indicadores"** (subtítulo: "Empresa tipo · ING-101 · UNICARIBE 2026").

Layout en 3 filas:

### Fila 1 — 7 tarjetas KPI (usa `vw_kpis_resumen`)

Arrastra un visual **Tarjeta** por cada campo:

| Indicador | Campo | Formato | Color sugerido |
|---|---|---|---|
| 1. Reutilizados | `pct_reutilizados` | `##.# %` | Verde `#179347` |
| 2. Reparados | `equipos_reparados` | `#` | Azul `#151B3F` |
| 3. RAEE gestionados | `kg_raee_gestionados` | `##.# kg` | Amarillo `#FCBD1C` |
| 4. Borrado documentado | `pct_borrado_doc` | `##.# %` | Verde |
| 5. Permanencia | `dias_permanencia` | `##.# días` | Azul |
| 6. Compras evitadas | `rd_compras_evitadas` | `RD$#,##0` | Verde |
| 7. Expedientes completos | `pct_expedientes` | `##.# %` | Amarillo |

### Fila 2 — 2 gráficos

- **Distribución por clasificación final** (Gráfico de anillos)
  - Fuente: `vw_equipos_completo`
  - Leyenda: `clasificacion_final`
  - Valores: `Count of id_equipo`

- **Compras evitadas por tipo de equipo** (Barras horizontales)
  - Fuente: `vw_movimientos_detalle`
  - Filtro: `estado_codigo = "REASIGNADO"`
  - Eje Y: `tipo_equipo`
  - Valores: `Sum of valor_evitado_rd`

### Fila 3 — tabla T00 y línea de tiempo

- **Tabla T00 del proyecto** (visual **Tabla**)
  - Fuente: `vw_bitacora_equipos`
  - Columnas: `codigo_interno`, `equipo`, `clasificacion`, `ultimo_estado`, `decision`, `fecha`
  - Ordenar por `fecha`

- **Línea de tiempo del programa** (Gráfico de columnas apiladas)
  - Fuente: `vw_movimientos_detalle`
  - Eje: `fecha` (por mes)
  - Leyenda: `estado_codigo`
  - Valores: `Count of id_movimiento`

## 3. Filtros que valen la pena

En el panel derecho `Filtros de esta página`:

- `tipo_equipo` (Laptop / PC escritorio / Monitor / Impresora)
- `departamento` (los 6)
- `fecha` (rango)

## 4. Refrescar cuando se agreguen datos

Cada vez que ejecutes el flujo (por ejemplo con `python python/flujo_equipo.py --demo …` o desde la app Tkinter), los datos nuevos ya están en las vistas. Vuelve a Power BI y pulsa **`Inicio → Actualizar`**. Las tarjetas se recalculan solas.

## 5. Captura 15

Cuando el dashboard esté armado:
1. `Archivo → Exportar → Exportar a PDF`, o
2. Botón *Print Screen* de la página completa,
guarda como `capturas/15_powerbi_dashboard.png` y añade la fila correspondiente a `capturas/README.md`:

```
| 15 | 15_powerbi_dashboard.png | Panel completo con 7 KPIs, gráficos y bitácora. | El sistema termina con analítica visual conforme al Cap. IV.7. | Cap. VII § Analítica visual. |
```

---

## Alternativa sin Power BI Desktop

Si no tienes Power BI Desktop a mano, puedes:

- **Excel** → `Datos → Obtener datos → De SQL Server` → misma cadena, misma tabla `vw_bitacora_equipos` → tabla dinámica.
- **La app Tkinter ya trae el "mini dashboard"** (pestaña 5. Indicadores), captura 13 — te sirve como respaldo si el proyecto se entrega antes de armar el `.pbix`.
