/* =============================================================
   VISTAS PARA POWER BI
   -------------------------------------------------------------
   Cada vista corresponde a uno de los 7 indicadores del proyecto
   (Capitulo IV.7 T02 del documento) mas 3 vistas de detalle para
   los graficos del dashboard.
   ============================================================= */

USE GestionReciclajeTecnologico;
GO

/* -------------------------------------------------------------
   INDICADORES DEL PROYECTO (7)
   ------------------------------------------------------------- */

/* Indicador 1 - Equipos reutilizados
   Formula (Cap. IV.7 T02): Equipos reasignados / equipos evaluados */
IF OBJECT_ID('dbo.vw_indicador_reutilizados','V') IS NOT NULL DROP VIEW dbo.vw_indicador_reutilizados;
GO
CREATE VIEW dbo.vw_indicador_reutilizados AS
SELECT
    CAST((SELECT COUNT(DISTINCT id_equipo)
          FROM dbo.Movimientos m
          JOIN dbo.EstadosMovimiento e ON e.id_estado = m.id_estado
          WHERE e.codigo = 'REASIGNADO') AS DECIMAL(10,2)) AS equipos_reasignados,
    CAST((SELECT COUNT(*) FROM dbo.Evaluaciones) AS DECIMAL(10,2)) AS equipos_evaluados,
    CASE WHEN (SELECT COUNT(*) FROM dbo.Evaluaciones) = 0 THEN 0
         ELSE CAST(
             (SELECT COUNT(DISTINCT id_equipo) FROM dbo.Movimientos m
              JOIN dbo.EstadosMovimiento e ON e.id_estado = m.id_estado
              WHERE e.codigo = 'REASIGNADO') * 100.0 /
             (SELECT COUNT(*) FROM dbo.Evaluaciones) AS DECIMAL(5,2)) END AS porcentaje;
GO

/* Indicador 2 - Equipos reparados
   Formula: Equipos recuperados mediante reparacion */
IF OBJECT_ID('dbo.vw_indicador_reparados','V') IS NOT NULL DROP VIEW dbo.vw_indicador_reparados;
GO
CREATE VIEW dbo.vw_indicador_reparados AS
SELECT
    COUNT(*)                     AS reparaciones_totales,
    SUM(CASE WHEN resultado = N'Recuperado' THEN 1 ELSE 0 END)     AS equipos_recuperados,
    SUM(CASE WHEN resultado = N'No recuperado' THEN 1 ELSE 0 END)  AS reparaciones_fallidas,
    SUM(CASE WHEN resultado = N'En proceso' THEN 1 ELSE 0 END)     AS reparaciones_activas,
    SUM(CASE WHEN resultado = N'Recuperado' THEN costo_rd ELSE 0 END) AS costo_recuperados_rd,
    SUM(costo_rd)                AS costo_total_rd
FROM dbo.Reparaciones;
GO

/* Indicador 3 - RAEE gestionados correctamente
   Formula: kilogramos entregados a gestor autorizado */
IF OBJECT_ID('dbo.vw_indicador_raee_gestionados','V') IS NOT NULL DROP VIEW dbo.vw_indicador_raee_gestionados;
GO
CREATE VIEW dbo.vw_indicador_raee_gestionados AS
SELECT
    COUNT(DISTINCT ac.id_acta)          AS actas_emitidas,
    ISNULL(SUM(ac.cantidad_equipos),0)  AS equipos_entregados,
    ISNULL(SUM(ac.peso_kg),0)           AS kg_entregados,
    g.nombre                            AS gestor
FROM dbo.ActasEntrega ac
JOIN dbo.GestoresRAEE g ON g.id_gestor = ac.id_gestor
GROUP BY g.nombre;
GO

/* Indicador 4 - Borrado seguro documentado
   Formula: Constancias firmadas / equipos que salieron */
IF OBJECT_ID('dbo.vw_indicador_borrado_documentado','V') IS NOT NULL DROP VIEW dbo.vw_indicador_borrado_documentado;
GO
CREATE VIEW dbo.vw_indicador_borrado_documentado AS
SELECT
    (SELECT COUNT(*) FROM dbo.BorradosSeguros)                        AS constancias_firmadas,
    (SELECT COUNT(*) FROM dbo.Equipos WHERE estado_equipo IN
        (N'ENTREGADO', N'DESTRUIDO'))                                 AS equipos_que_salieron,
    CASE WHEN (SELECT COUNT(*) FROM dbo.Equipos
               WHERE estado_equipo IN (N'ENTREGADO', N'DESTRUIDO')) = 0 THEN 0
         ELSE CAST(
             (SELECT COUNT(*) FROM dbo.BorradosSeguros) * 100.0 /
             (SELECT COUNT(*) FROM dbo.Equipos
              WHERE estado_equipo IN (N'ENTREGADO', N'DESTRUIDO'))
             AS DECIMAL(5,2)) END AS porcentaje;
GO

/* Indicador 5 - Permanencia en almacen temporal
   Formula: Dias promedio entre retiro y destino final */
IF OBJECT_ID('dbo.vw_indicador_permanencia_almacen','V') IS NOT NULL DROP VIEW dbo.vw_indicador_permanencia_almacen;
GO
CREATE VIEW dbo.vw_indicador_permanencia_almacen AS
WITH rangos AS (
    SELECT
        m.id_equipo,
        MIN(CASE WHEN em.codigo = 'EN_ALMACEN_TEMPORAL' THEN m.fecha END) AS inicio,
        MIN(CASE WHEN em.codigo IN ('REASIGNADO','ENTREGADO_A_GESTOR') THEN m.fecha END) AS fin
    FROM dbo.Movimientos m
    JOIN dbo.EstadosMovimiento em ON em.id_estado = m.id_estado
    GROUP BY m.id_equipo
)
SELECT
    COUNT(*)                                            AS equipos_medidos,
    ISNULL(AVG(DATEDIFF(day, inicio, fin) * 1.0), 0)    AS dias_promedio,
    ISNULL(MIN(DATEDIFF(day, inicio, fin)), 0)          AS dias_min,
    ISNULL(MAX(DATEDIFF(day, inicio, fin)), 0)          AS dias_max
FROM rangos
WHERE inicio IS NOT NULL AND fin IS NOT NULL;
GO

/* Indicador 6 - Compras evitadas
   Formula: Valor (RD$) de los equipos reasignados */
IF OBJECT_ID('dbo.vw_indicador_compras_evitadas','V') IS NOT NULL DROP VIEW dbo.vw_indicador_compras_evitadas;
GO
CREATE VIEW dbo.vw_indicador_compras_evitadas AS
SELECT
    COUNT(*)                              AS reasignaciones,
    ISNULL(SUM(m.valor_evitado_rd),0)     AS total_evitado_rd,
    ISNULL(AVG(m.valor_evitado_rd),0)     AS promedio_por_equipo_rd
FROM dbo.Movimientos m
JOIN dbo.EstadosMovimiento e ON e.id_estado = m.id_estado
WHERE e.codigo = 'REASIGNADO' AND m.valor_evitado_rd IS NOT NULL;
GO

/* Indicador 7 - Expedientes completos
   Formula: Equipos con destino final registrado / total */
IF OBJECT_ID('dbo.vw_indicador_expedientes_completos','V') IS NOT NULL DROP VIEW dbo.vw_indicador_expedientes_completos;
GO
CREATE VIEW dbo.vw_indicador_expedientes_completos AS
SELECT
    (SELECT COUNT(*) FROM dbo.Equipos)   AS equipos_totales,
    (SELECT COUNT(DISTINCT m.id_equipo) FROM dbo.Movimientos m
     JOIN dbo.EstadosMovimiento e ON e.id_estado = m.id_estado
     WHERE e.codigo = 'CERRADO')         AS expedientes_cerrados,
    CASE WHEN (SELECT COUNT(*) FROM dbo.Equipos) = 0 THEN 0
         ELSE CAST(
            (SELECT COUNT(DISTINCT m.id_equipo) FROM dbo.Movimientos m
             JOIN dbo.EstadosMovimiento e ON e.id_estado = m.id_estado
             WHERE e.codigo = 'CERRADO') * 100.0 /
            (SELECT COUNT(*) FROM dbo.Equipos) AS DECIMAL(5,2)) END AS porcentaje;
GO

/* -------------------------------------------------------------
   VISTAS DE DETALLE PARA GRAFICOS DEL DASHBOARD
   ------------------------------------------------------------- */

/* Vista completa de un equipo (para tablas y filtros) */
IF OBJECT_ID('dbo.vw_equipos_completo','V') IS NOT NULL DROP VIEW dbo.vw_equipos_completo;
GO
CREATE VIEW dbo.vw_equipos_completo AS
SELECT
    e.id_equipo,
    e.codigo_interno,
    e.tipo_equipo,
    e.marca,
    e.modelo,
    e.numero_serie,
    d.nombre                                  AS departamento,
    r.rol                                     AS responsable_rol,
    e.estado_equipo,
    e.fecha_adquisicion,
    e.fecha_ultimo_mantenimiento,
    e.fecha_retiro,
    e.motivo_retiro,
    (SELECT TOP 1 clasificacion_final
     FROM dbo.Evaluaciones
     WHERE id_equipo = e.id_equipo
     ORDER BY fecha_evaluacion DESC)          AS clasificacion_final,
    (SELECT COUNT(*) FROM dbo.Movimientos
     WHERE id_equipo = e.id_equipo)           AS n_movimientos,
    (SELECT COUNT(*) FROM dbo.Reparaciones
     WHERE id_equipo = e.id_equipo)           AS n_reparaciones,
    (SELECT COUNT(*) FROM dbo.BorradosSeguros
     WHERE id_equipo = e.id_equipo)           AS n_borrados
FROM dbo.Equipos e
JOIN dbo.Departamentos d ON d.id_departamento = e.id_departamento
JOIN dbo.Responsables  r ON r.id_responsable  = e.id_responsable;
GO

/* Movimientos con nombres humanos (para linea de tiempo y bitacora) */
IF OBJECT_ID('dbo.vw_movimientos_detalle','V') IS NOT NULL DROP VIEW dbo.vw_movimientos_detalle;
GO
CREATE VIEW dbo.vw_movimientos_detalle AS
SELECT
    m.id_movimiento,
    e.codigo_interno,
    e.tipo_equipo,
    em.codigo                                 AS estado_codigo,
    em.descripcion                            AS estado_descripcion,
    em.es_final,
    m.fecha,
    r.rol                                     AS responsable_rol,
    m.observacion,
    m.valor_evitado_rd,
    DATENAME(month, m.fecha)                  AS mes_nombre,
    YEAR(m.fecha)                             AS anio,
    MONTH(m.fecha)                            AS mes,
    CONVERT(varchar(10), m.fecha, 120)        AS fecha_iso
FROM dbo.Movimientos m
JOIN dbo.Equipos e             ON e.id_equipo      = m.id_equipo
JOIN dbo.EstadosMovimiento em  ON em.id_estado     = m.id_estado
JOIN dbo.Responsables r        ON r.id_responsable = m.id_responsable;
GO

/* Bitacora ejemplo (T00 del proyecto) - un renglon por equipo con su ultima decision */
IF OBJECT_ID('dbo.vw_bitacora_equipos','V') IS NOT NULL DROP VIEW dbo.vw_bitacora_equipos;
GO
CREATE VIEW dbo.vw_bitacora_equipos AS
SELECT
    e.codigo_interno,
    e.tipo_equipo + N' ' + e.marca + N' ' + e.modelo   AS equipo,
    e.estado_equipo                                    AS estado,
    (SELECT TOP 1 clasificacion_final FROM dbo.Evaluaciones
     WHERE id_equipo = e.id_equipo ORDER BY fecha_evaluacion DESC) AS clasificacion,
    (SELECT TOP 1 ev.destino_propuesto FROM dbo.Evaluaciones ev
     WHERE ev.id_equipo = e.id_equipo ORDER BY ev.fecha_evaluacion DESC) AS decision,
    e.fecha_retiro                                     AS fecha,
    (SELECT TOP 1 em.codigo FROM dbo.Movimientos m
     JOIN dbo.EstadosMovimiento em ON em.id_estado = m.id_estado
     WHERE m.id_equipo = e.id_equipo
     ORDER BY m.fecha DESC, m.id_movimiento DESC)      AS ultimo_estado
FROM dbo.Equipos e;
GO

/* Vista consolidada para el dashboard Power BI (KPIs en una sola fila) */
IF OBJECT_ID('dbo.vw_kpis_resumen','V') IS NOT NULL DROP VIEW dbo.vw_kpis_resumen;
GO
CREATE VIEW dbo.vw_kpis_resumen AS
SELECT
    (SELECT porcentaje FROM dbo.vw_indicador_reutilizados)          AS pct_reutilizados,
    (SELECT equipos_recuperados FROM dbo.vw_indicador_reparados)    AS equipos_reparados,
    (SELECT SUM(kg_entregados) FROM dbo.vw_indicador_raee_gestionados) AS kg_raee_gestionados,
    (SELECT porcentaje FROM dbo.vw_indicador_borrado_documentado)   AS pct_borrado_doc,
    (SELECT dias_promedio FROM dbo.vw_indicador_permanencia_almacen) AS dias_permanencia,
    (SELECT total_evitado_rd FROM dbo.vw_indicador_compras_evitadas) AS rd_compras_evitadas,
    (SELECT porcentaje FROM dbo.vw_indicador_expedientes_completos) AS pct_expedientes;
GO

PRINT N'10 vistas para Power BI creadas correctamente.';
GO
