# Sistema de Gestión y Reciclaje Tecnológico

Sistema informático desarrollado como complemento del **Proyecto Final de la asignatura ING-101 — Introducción a la Ingeniería** en la **Universidad del Caribe (UNICARIBE)**, periodo septiembre 2026.

El proyecto plantea un **Programa de gestión y reciclaje de residuos tecnológicos para una empresa** y este repositorio contiene la capa técnica que operativiza ese programa: base de datos, lógica de negocio en Python, interfaz de usuario, dashboard de indicadores y 16 capturas de evidencia.

---

## Stack

- **SQL Server 2022/2025** · 14 tablas, 19 foreign keys, 11 vistas analíticas, 8 check constraints
- **Python 3.11+** · `pyodbc`, `tkinter` · capa de datos (`db.py`), motor del flujo (`flujo_equipo.py`) y GUI de 5 pestañas (`app.py`)
- **Power BI Desktop** · dashboard `.pbix` con 7 KPIs del Cap. IV.7 del proyecto
- **PyInstaller** · empaquetado opcional a `SistemaReciclajeTecnologico.exe` (no versionado aquí)

Autenticación por Windows (Trusted Connection) — **sin contraseñas en el código**.

---

## Estructura

```
.
├── docs/        Análisis previo del PDF del proyecto y mapa documento → BD
├── sql/         01_esquema.sql · 02_datos_prueba.sql · 03_vistas_powerbi.sql
├── python/      app.py (GUI Tkinter) · flujo_equipo.py · db.py
├── powerbi/     dashboard.pbix + guía de armado
├── capturas/    16 capturas de evidencia (txt + png) con README índice
└── README.md
```

---

## Cómo ejecutarlo

### 1. Preparar la base de datos
```powershell
sqlcmd -S localhost -E -i sql\01_esquema.sql
sqlcmd -S localhost -E -i sql\02_datos_prueba.sql
sqlcmd -S localhost -E -i sql\03_vistas_powerbi.sql
```

### 2. Instalar dependencias de Python
```powershell
pip install -r requirements.txt
```

### 3. Levantar la aplicación
```powershell
python python\app.py
```

5 pestañas disponibles:
1. **Equipos** — inventario (Anexo B del proyecto)
2. **Evaluación** — ficha técnica (Anexo C)
3. **Borrado** — constancia de borrado seguro (Anexo D)
4. **Historial** — trazabilidad del equipo (Cap. IV.2 + Anexo A)
5. **Indicadores** — los 7 KPIs del Cap. IV.7

### 4. Abrir el dashboard
Abrí `powerbi/dashboard.pbix` con Power BI Desktop. Las 11 vistas SQL se conectan en modo *Import* a `localhost` → `GestionReciclajeTecnologico`.

---

## De dónde salieron los campos

El punto de partida fue el documento escrito del grupo (**Propuesta de Programa de Reciclaje Tecnológico**). Cada tabla SQL se trazó contra un capítulo o anexo del documento. El mapa completo está en [`docs/02_mapa_documento_bd.md`](docs/02_mapa_documento_bd.md).

Los 7 indicadores del Capítulo IV.7 (reutilizados, reparados, RAEE gestionados, borrado documentado, permanencia en almacén, compras evitadas, expedientes completos) se consumen desde las vistas `vw_indicador_*` para que Power BI no inventara fórmulas: la lógica vive en SQL.

---

## Capturas

Las 16 capturas de evidencia están en [`capturas/`](capturas/) y documentadas en [`capturas/README.md`](capturas/README.md). Cubren desde la conexión al servidor hasta el dashboard final.

---

## Créditos

**Proyecto Final — Grupo de 6 (ING-101, UNICARIBE 2026-09):**

| Tema | Integrante |
|---|---|
| 1 — Residuos tecnológicos y problemática en las empresas | **Jhonniel García Samboy** |
| 2 — Importancia y objetivos del programa | Miguel Feliz |
| 3 — Identificación, registro y clasificación | — |
| 4 — Propuesta del programa de gestión y reciclaje | — |
| 5 — Seguridad de la información, ética e impacto socioambiental | — |
| 6 — Beneficios, resultados esperados y conclusión | — |

> Si sos del grupo y querés que aparezca tu nombre en el tema que te tocó, abrime un issue o un PR a este README. 🙌

**Docente:** Ing. Iván V. De Paula, MGP — *Introducción a la Ingeniería*, UNICARIBE.

El sistema informático de este repositorio es un aporte técnico individual que acompaña al documento del grupo; la propuesta académica completa es colectiva.

---

## Licencia

MIT — ver [LICENSE](LICENSE). Puede usarse como referencia para proyectos académicos siempre que se cite la fuente.
