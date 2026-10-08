/* =============================================================
   Datos de prueba realistas
   Empresa tipo del proyecto: 80 empleados, servicios, Santo Domingo
   Genera 15 equipos con recorrido completo por el flujo del Anexo A
   ============================================================= */

USE GestionReciclajeTecnologico;
GO

SET NOCOUNT ON;

/* Limpiar tablas transaccionales para poder re-ejecutar */
DELETE FROM dbo.EquiposEnActa;
DELETE FROM dbo.ActasEntrega;
DELETE FROM dbo.Movimientos;
DELETE FROM dbo.BorradosSeguros;
DELETE FROM dbo.Reparaciones;
DELETE FROM dbo.EvaluacionTecnica;
DELETE FROM dbo.EvaluacionFisica;
DELETE FROM dbo.Evaluaciones;
DELETE FROM dbo.Equipos;
DBCC CHECKIDENT('dbo.Equipos', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT('dbo.Evaluaciones', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT('dbo.Movimientos', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT('dbo.BorradosSeguros', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT('dbo.Reparaciones', RESEED, 0) WITH NO_INFOMSGS;
DBCC CHECKIDENT('dbo.ActasEntrega', RESEED, 0) WITH NO_INFOMSGS;

DECLARE @id_dep_ti     INT = (SELECT id_departamento FROM Departamentos WHERE nombre = N'Tecnologia de la Informacion');
DECLARE @id_dep_admin  INT = (SELECT id_departamento FROM Departamentos WHERE nombre = N'Administracion');
DECLARE @id_dep_conta  INT = (SELECT id_departamento FROM Departamentos WHERE nombre = N'Contabilidad');
DECLARE @id_dep_rrhh   INT = (SELECT id_departamento FROM Departamentos WHERE nombre = N'Recursos Humanos');
DECLARE @id_dep_vent   INT = (SELECT id_departamento FROM Departamentos WHERE nombre = N'Ventas');
DECLARE @id_dep_alma   INT = (SELECT id_departamento FROM Departamentos WHERE nombre = N'Almacen');

DECLARE @r_coord    INT = (SELECT id_responsable FROM Responsables WHERE rol = N'Coordinador');
DECLARE @r_ti       INT = (SELECT id_responsable FROM Responsables WHERE rol = N'Inventario y TI');
DECLARE @r_tecnico  INT = (SELECT id_responsable FROM Responsables WHERE rol = N'Evaluacion tecnica');

/* ---------- 15 EQUIPOS ---------- */
INSERT INTO dbo.Equipos
    (codigo_interno, tipo_equipo, marca, modelo, numero_serie, ubicacion,
     id_departamento, id_responsable, estado_equipo,
     fecha_adquisicion, fecha_ultimo_mantenimiento, fecha_retiro, motivo_retiro)
VALUES
    (N'EQ-LAP-0001', N'Laptop',     N'Dell',    N'Latitude 3520',  N'DL3520-84A21', N'Piso 2 - TI',        @id_dep_ti,    @r_ti, N'RETIRADO', '2022-03-15', '2025-01-10', '2026-08-05', N'Renovacion programada'),
    (N'EQ-LAP-0002', N'Laptop',     N'HP',      N'ProBook 450 G7', N'HP450G7-77T02',N'Piso 1 - Ventas',    @id_dep_vent,  @r_ti, N'RETIRADO', '2022-06-22', '2024-11-18', '2026-08-06', N'Renovacion programada'),
    (N'EQ-LAP-0003', N'Laptop',     N'Lenovo',  N'ThinkPad E14',   N'LT14E-99M11',  N'Piso 3 - RRHH',      @id_dep_rrhh,  @r_ti, N'RETIRADO', '2021-10-04', '2024-08-20', '2026-08-10', N'Bateria dañada, no enciende'),
    (N'EQ-LAP-0004', N'Laptop',     N'Acer',    N'Aspire 5',       N'AC5-51C09',    N'Piso 2 - Conta',     @id_dep_conta, @r_ti, N'RETIRADO', '2020-01-20', '2023-05-12', '2026-08-12', N'Pantalla dañada'),
    (N'EQ-PC-0001',  N'PC escritorio', N'HP',   N'EliteDesk 800',  N'HPED800-12A45',N'Piso 1 - Admin',     @id_dep_admin, @r_ti, N'RETIRADO', '2019-08-12', '2023-02-14', '2026-08-15', N'Renovacion programada'),
    (N'EQ-PC-0002',  N'PC escritorio', N'Dell', N'OptiPlex 3070',  N'DLOP3070-33B08',N'Piso 2 - TI',       @id_dep_ti,    @r_ti, N'RETIRADO', '2020-05-30', '2024-01-25', '2026-08-16', N'Fuente de poder dañada'),
    (N'EQ-PC-0003',  N'PC escritorio', N'Lenovo',N'ThinkCentre M75',N'LTM75-44Q12', N'Piso 3 - RRHH',      @id_dep_rrhh,  @r_ti, N'RETIRADO', '2019-11-07', '2023-09-18', '2026-08-18', N'Placa base dañada'),
    (N'EQ-PC-0004',  N'PC escritorio', N'HP',   N'ProDesk 400',    N'HPPD400-55R33',N'Piso 1 - Ventas',    @id_dep_vent,  @r_ti, N'RETIRADO', '2020-09-14', '2024-04-06', '2026-08-19', N'Renovacion programada'),
    (N'EQ-MON-0001', N'Monitor',    N'Dell',    N'P2419H',         N'DLP24-66E15',  N'Piso 1 - Admin',     @id_dep_admin, @r_ti, N'RETIRADO', '2019-08-12', NULL,         '2026-08-20', N'Renovacion programada'),
    (N'EQ-MON-0002', N'Monitor',    N'LG',      N'24MK430H',       N'LG24-77G07',   N'Piso 2 - Conta',     @id_dep_conta, @r_ti, N'RETIRADO', '2019-05-18', NULL,         '2026-08-21', N'Pantalla con lineas'),
    (N'EQ-MON-0003', N'Monitor',    N'Samsung', N'F24T350FHL',     N'SM24F-88H09',  N'Piso 3 - Almacen',   @id_dep_alma,  @r_ti, N'RETIRADO', '2020-02-25', NULL,         '2026-08-22', N'Sin señal, panel dañado'),
    (N'EQ-IMP-0001', N'Impresora',  N'HP',      N'LaserJet Pro M404',N'HPM404-11K88',N'Piso 2 - Conta',    @id_dep_conta, @r_ti, N'RETIRADO', '2020-06-10', '2024-09-14', '2026-08-25', N'Fusor gastado'),
    (N'EQ-IMP-0002', N'Impresora',  N'Epson',   N'L3150',          N'EPL3150-22J66',N'Piso 3 - RRHH',      @id_dep_rrhh,  @r_ti, N'RETIRADO', '2019-04-03', '2023-11-22', '2026-08-27', N'Cabezal dañado, sin repuesto'),
    (N'EQ-LAP-0005', N'Laptop',     N'HP',      N'EliteBook 840',  N'HP840-33P44',  N'Piso 1 - Ventas',    @id_dep_vent,  @r_ti, N'RETIRADO', '2022-11-18', '2025-05-30', '2026-09-01', N'Renovacion programada'),
    (N'EQ-PC-0005',  N'PC escritorio', N'Dell', N'Vostro 3681',    N'DLVO3681-44S00',N'Piso 1 - Admin',    @id_dep_admin, @r_ti, N'RETIRADO', '2021-01-15', '2024-06-11', '2026-09-02', N'Renovacion programada');

/* ---------- 10 EVALUACIONES TECNICAS (para los primeros 10 equipos) ---------- */
INSERT INTO dbo.Evaluaciones (id_equipo, fecha_evaluacion, id_responsable, costo_estimado_rd, reparacion_viable, clasificacion_final, destino_propuesto, firma_responsable)
SELECT id_equipo, DATEADD(day, 3, fecha_retiro), @r_tecnico,
       CASE codigo_interno
           WHEN N'EQ-LAP-0001' THEN NULL       WHEN N'EQ-LAP-0002' THEN NULL
           WHEN N'EQ-LAP-0003' THEN 4500       WHEN N'EQ-LAP-0004' THEN 8200
           WHEN N'EQ-PC-0001'  THEN NULL       WHEN N'EQ-PC-0002'  THEN 3200
           WHEN N'EQ-PC-0003'  THEN 12500      WHEN N'EQ-PC-0004'  THEN NULL
           WHEN N'EQ-MON-0001' THEN NULL       WHEN N'EQ-MON-0002' THEN 6800
       END,
       CASE codigo_interno
           WHEN N'EQ-LAP-0001' THEN NULL       WHEN N'EQ-LAP-0002' THEN NULL
           WHEN N'EQ-LAP-0003' THEN 1          WHEN N'EQ-LAP-0004' THEN 0
           WHEN N'EQ-PC-0001'  THEN NULL       WHEN N'EQ-PC-0002'  THEN 1
           WHEN N'EQ-PC-0003'  THEN 0          WHEN N'EQ-PC-0004'  THEN NULL
           WHEN N'EQ-MON-0001' THEN NULL       WHEN N'EQ-MON-0002' THEN 0
       END,
       CASE codigo_interno
           WHEN N'EQ-LAP-0001' THEN N'Reutilizable'  WHEN N'EQ-LAP-0002' THEN N'Reutilizable'
           WHEN N'EQ-LAP-0003' THEN N'Reparable'     WHEN N'EQ-LAP-0004' THEN N'No recuperable'
           WHEN N'EQ-PC-0001'  THEN N'Reutilizable'  WHEN N'EQ-PC-0002'  THEN N'Reparable'
           WHEN N'EQ-PC-0003'  THEN N'No recuperable' WHEN N'EQ-PC-0004' THEN N'Reutilizable'
           WHEN N'EQ-MON-0001' THEN N'Reutilizable'  WHEN N'EQ-MON-0002' THEN N'No recuperable'
       END,
       CASE codigo_interno
           WHEN N'EQ-LAP-0001' THEN N'Reasignacion a Recursos Humanos'
           WHEN N'EQ-LAP-0002' THEN N'Reasignacion a Almacen'
           WHEN N'EQ-LAP-0003' THEN N'Reparacion en taller interno de TI'
           WHEN N'EQ-LAP-0004' THEN N'Entrega a gestor autorizado'
           WHEN N'EQ-PC-0001'  THEN N'Reasignacion a Ventas'
           WHEN N'EQ-PC-0002'  THEN N'Reparacion en taller interno de TI'
           WHEN N'EQ-PC-0003'  THEN N'Entrega a gestor autorizado'
           WHEN N'EQ-PC-0004'  THEN N'Reasignacion a Contabilidad'
           WHEN N'EQ-MON-0001' THEN N'Reasignacion a Ventas'
           WHEN N'EQ-MON-0002' THEN N'Entrega a gestor autorizado'
       END,
       N'Firma tecnico evaluador'
FROM dbo.Equipos
WHERE codigo_interno IN (N'EQ-LAP-0001',N'EQ-LAP-0002',N'EQ-LAP-0003',N'EQ-LAP-0004',
                         N'EQ-PC-0001',N'EQ-PC-0002',N'EQ-PC-0003',N'EQ-PC-0004',
                         N'EQ-MON-0001',N'EQ-MON-0002');

/* Evaluacion fisica: 7 elementos por evaluacion (todos "Bien" salvo casos con daño) */
INSERT INTO dbo.EvaluacionFisica (id_evaluacion, elemento, estado, observaciones)
SELECT e.id_evaluacion, x.elemento,
       CASE
           WHEN eq.codigo_interno = N'EQ-LAP-0003' AND x.elemento = N'Bateria'    THEN 'D'
           WHEN eq.codigo_interno = N'EQ-LAP-0004' AND x.elemento = N'Pantalla'   THEN 'D'
           WHEN eq.codigo_interno = N'EQ-PC-0002'  AND x.elemento = N'Fuente de alimentacion' THEN 'D'
           WHEN eq.codigo_interno = N'EQ-MON-0002' AND x.elemento = N'Pantalla'   THEN 'D'
           ELSE 'B'
       END,
       CASE
           WHEN eq.codigo_interno = N'EQ-LAP-0003' AND x.elemento = N'Bateria'    THEN N'No carga, requiere reemplazo'
           WHEN eq.codigo_interno = N'EQ-LAP-0004' AND x.elemento = N'Pantalla'   THEN N'Panel roto por caida'
           WHEN eq.codigo_interno = N'EQ-PC-0002'  AND x.elemento = N'Fuente de alimentacion' THEN N'Fuente no entrega voltaje'
           WHEN eq.codigo_interno = N'EQ-MON-0002' AND x.elemento = N'Pantalla'   THEN N'Lineas verticales permanentes'
           ELSE NULL
       END
FROM dbo.Evaluaciones e
JOIN dbo.Equipos eq ON e.id_equipo = eq.id_equipo
CROSS JOIN (VALUES (N'Pantalla'),(N'Teclado'),(N'Carcasa'),(N'Cables'),
                   (N'Puertos'),(N'Bateria'),(N'Fuente de alimentacion')) x(elemento);

/* Evaluacion tecnica: 4 aspectos por evaluacion */
INSERT INTO dbo.EvaluacionTecnica (id_evaluacion, aspecto, resultado, observaciones)
SELECT e.id_evaluacion, x.aspecto,
       CASE
           WHEN eq.codigo_interno IN (N'EQ-LAP-0003',N'EQ-LAP-0004',N'EQ-PC-0002',N'EQ-PC-0003',N'EQ-MON-0002') AND x.aspecto = N'Enciende correctamente' THEN 0
           WHEN eq.codigo_interno IN (N'EQ-PC-0003') AND x.aspecto = N'Componentes internos en buen estado' THEN 0
           ELSE 1
       END,
       NULL
FROM dbo.Evaluaciones e
JOIN dbo.Equipos eq ON e.id_equipo = eq.id_equipo
CROSS JOIN (VALUES (N'Enciende correctamente'),
                   (N'Sistema operativo funciona'),
                   (N'Ejecuta los programas necesarios'),
                   (N'Componentes internos en buen estado')) x(aspecto);

/* ---------- REPARACIONES (dos equipos reparables) ---------- */
INSERT INTO dbo.Reparaciones (id_equipo, fecha_inicio, fecha_fin, falla_encontrada, trabajo_realizado, costo_rd, resultado, id_responsable, observaciones)
SELECT id_equipo, '2026-08-15', '2026-08-22',
       N'Bateria dañada', N'Reemplazo de bateria original por compatible', 4500, N'Recuperado', @r_tecnico,
       N'Equipo devuelto a inventario para reasignacion'
FROM dbo.Equipos WHERE codigo_interno = N'EQ-LAP-0003';

INSERT INTO dbo.Reparaciones (id_equipo, fecha_inicio, fecha_fin, falla_encontrada, trabajo_realizado, costo_rd, resultado, id_responsable, observaciones)
SELECT id_equipo, '2026-08-20', '2026-08-24',
       N'Fuente de poder dañada', N'Reemplazo de fuente ATX 400W', 3200, N'Recuperado', @r_tecnico,
       N'Prueba de encendido y sistema OK'
FROM dbo.Equipos WHERE codigo_interno = N'EQ-PC-0002';

/* ---------- BORRADOS SEGUROS (para los equipos que salen a gestor) ---------- */
DECLARE @m_sobre INT = (SELECT id_metodo FROM MetodosBorrado WHERE codigo = 'SOBREESCRITURA');
DECLARE @m_fisico INT = (SELECT id_metodo FROM MetodosBorrado WHERE codigo = 'DESTRUCCION_FISICA');

INSERT INTO dbo.BorradosSeguros
    (id_equipo, tipo_soporte, id_metodo, herramienta, verificacion_posterior,
     fecha_procedimiento, id_responsable_borrado, id_responsable_verifica,
     destino_autorizado, evidencia_ruta)
SELECT eq.id_equipo,
       CASE WHEN eq.tipo_equipo LIKE N'%Monitor%' THEN N'Sin almacenamiento' ELSE N'HDD 500 GB SATA' END,
       CASE WHEN eq.tipo_equipo LIKE N'%Monitor%' THEN @m_fisico ELSE @m_sobre END,
       CASE WHEN eq.tipo_equipo LIKE N'%Monitor%' THEN N'No aplica' ELSE N'DBAN 2.3.0 (metodo DoD 5220.22-M)' END,
       1, '2026-09-10', @r_ti, @r_coord,
       N'Ecologix, S.R.L.',
       N'\\CUERVO\evidencias\borrado\' + eq.codigo_interno + N'.pdf'
FROM dbo.Equipos eq
WHERE codigo_interno IN (N'EQ-LAP-0004', N'EQ-PC-0003', N'EQ-MON-0002', N'EQ-IMP-0002');

/* ---------- ACTA DE ENTREGA AL GESTOR ---------- */
DECLARE @id_ecologix INT = (SELECT id_gestor FROM GestoresRAEE WHERE nombre LIKE N'Ecologix%');
INSERT INTO dbo.ActasEntrega (empresa_entrega, id_gestor, numero_autorizacion, fecha_entrega, lugar_entrega, cantidad_equipos, peso_kg)
VALUES (N'Empresa tipo (proyecto UNICARIBE)', @id_ecologix, N'P. Ambiental num. 4116-21', '2026-09-15',
        N'Almacen central - Santo Domingo', 4, 34.50);

DECLARE @id_acta INT = SCOPE_IDENTITY();

INSERT INTO dbo.EquiposEnActa (id_acta, id_equipo, id_borrado)
SELECT @id_acta, eq.id_equipo, bs.id_borrado
FROM dbo.Equipos eq
JOIN dbo.BorradosSeguros bs ON bs.id_equipo = eq.id_equipo
WHERE eq.codigo_interno IN (N'EQ-LAP-0004', N'EQ-PC-0003', N'EQ-MON-0002', N'EQ-IMP-0002');

/* ---------- MOVIMIENTOS (recorrido completo por equipo) ---------- */

/* Diccionario estados */
DECLARE @s_reg INT = (SELECT id_estado FROM EstadosMovimiento WHERE codigo = 'REGISTRADO');
DECLARE @s_alm INT = (SELECT id_estado FROM EstadosMovimiento WHERE codigo = 'EN_ALMACEN_TEMPORAL');
DECLARE @s_eva INT = (SELECT id_estado FROM EstadosMovimiento WHERE codigo = 'EN_EVALUACION');
DECLARE @s_reu INT = (SELECT id_estado FROM EstadosMovimiento WHERE codigo = 'CLASIFICADO_REUTILIZABLE');
DECLARE @s_rep INT = (SELECT id_estado FROM EstadosMovimiento WHERE codigo = 'CLASIFICADO_REPARABLE');
DECLARE @s_nre INT = (SELECT id_estado FROM EstadosMovimiento WHERE codigo = 'CLASIFICADO_NO_RECUPERABLE');
DECLARE @s_erp INT = (SELECT id_estado FROM EstadosMovimiento WHERE codigo = 'EN_REPARACION');
DECLARE @s_rea INT = (SELECT id_estado FROM EstadosMovimiento WHERE codigo = 'REASIGNADO');
DECLARE @s_bor INT = (SELECT id_estado FROM EstadosMovimiento WHERE codigo = 'BORRADO_SEGURO_APLICADO');
DECLARE @s_ent INT = (SELECT id_estado FROM EstadosMovimiento WHERE codigo = 'ENTREGADO_A_GESTOR');
DECLARE @s_cer INT = (SELECT id_estado FROM EstadosMovimiento WHERE codigo = 'CERRADO');

/* Todos los 15 equipos: REGISTRADO */
INSERT INTO dbo.Movimientos (id_equipo, id_estado, fecha, id_responsable, observacion)
SELECT id_equipo, @s_reg, CAST(fecha_retiro AS DATETIME2), @r_ti, N'Retiro y registro (paso 1 Cap. IV.2)'
FROM dbo.Equipos;

/* Todos: EN_ALMACEN_TEMPORAL (1 dia despues) */
INSERT INTO dbo.Movimientos (id_equipo, id_estado, fecha, id_responsable, observacion)
SELECT id_equipo, @s_alm, DATEADD(day, 1, CAST(fecha_retiro AS DATETIME2)), @r_ti,
       N'Traslado al area de almacenamiento temporal'
FROM dbo.Equipos;

/* Los 10 evaluados: EN_EVALUACION + CLASIFICADO_* */
INSERT INTO dbo.Movimientos (id_equipo, id_estado, fecha, id_responsable, observacion)
SELECT id_equipo, @s_eva, DATEADD(day, 2, CAST(fecha_retiro AS DATETIME2)), @r_tecnico, N'Evaluacion tecnica iniciada'
FROM dbo.Equipos
WHERE codigo_interno IN (N'EQ-LAP-0001',N'EQ-LAP-0002',N'EQ-LAP-0003',N'EQ-LAP-0004',
                         N'EQ-PC-0001',N'EQ-PC-0002',N'EQ-PC-0003',N'EQ-PC-0004',
                         N'EQ-MON-0001',N'EQ-MON-0002');

INSERT INTO dbo.Movimientos (id_equipo, id_estado, fecha, id_responsable, observacion)
SELECT e.id_equipo,
       CASE ev.clasificacion_final
           WHEN N'Reutilizable'    THEN @s_reu
           WHEN N'Reparable'       THEN @s_rep
           WHEN N'No recuperable'  THEN @s_nre
       END,
       DATEADD(day, 4, CAST(e.fecha_retiro AS DATETIME2)), @r_tecnico,
       N'Clasificacion: ' + ev.clasificacion_final
FROM dbo.Equipos e
JOIN dbo.Evaluaciones ev ON ev.id_equipo = e.id_equipo;

/* Reutilizables: REASIGNADO con valor evitado (compra evitada, indicador Cap. IV.7) */
INSERT INTO dbo.Movimientos (id_equipo, id_estado, fecha, id_responsable, observacion, valor_evitado_rd)
SELECT eq.id_equipo, @s_rea,
       DATEADD(day, 7, CAST(eq.fecha_retiro AS DATETIME2)), @r_coord,
       N'Reasignado dentro de la empresa',
       CASE eq.tipo_equipo
           WHEN N'Laptop'         THEN 42000
           WHEN N'PC escritorio'  THEN 32000
           WHEN N'Monitor'        THEN 8500
           ELSE 5000
       END
FROM dbo.Equipos eq
JOIN dbo.Evaluaciones ev ON ev.id_equipo = eq.id_equipo
WHERE ev.clasificacion_final = N'Reutilizable';

/* Reparables: EN_REPARACION -> luego, si Recuperado, REASIGNADO */
INSERT INTO dbo.Movimientos (id_equipo, id_estado, fecha, id_responsable, observacion)
SELECT r.id_equipo, @s_erp, CAST(r.fecha_inicio AS DATETIME2), r.id_responsable,
       N'Reparacion iniciada: ' + r.falla_encontrada
FROM dbo.Reparaciones r;

INSERT INTO dbo.Movimientos (id_equipo, id_estado, fecha, id_responsable, observacion, valor_evitado_rd)
SELECT r.id_equipo, @s_rea, CAST(r.fecha_fin AS DATETIME2), @r_coord,
       N'Reasignado tras reparacion exitosa',
       CASE eq.tipo_equipo
           WHEN N'Laptop'         THEN 42000
           WHEN N'PC escritorio'  THEN 32000
           ELSE 5000
       END
FROM dbo.Reparaciones r
JOIN dbo.Equipos eq ON eq.id_equipo = r.id_equipo
WHERE r.resultado = N'Recuperado';

/* No recuperables (4): BORRADO_SEGURO_APLICADO -> ENTREGADO_A_GESTOR -> CERRADO */
INSERT INTO dbo.Movimientos (id_equipo, id_estado, fecha, id_responsable, observacion)
SELECT bs.id_equipo, @s_bor, CAST(bs.fecha_procedimiento AS DATETIME2), bs.id_responsable_borrado,
       N'Borrado seguro aplicado y verificado (' +
       (SELECT codigo FROM MetodosBorrado WHERE id_metodo = bs.id_metodo) + N')'
FROM dbo.BorradosSeguros bs;

INSERT INTO dbo.Movimientos (id_equipo, id_estado, fecha, id_responsable, observacion)
SELECT ea.id_equipo, @s_ent, CAST(ac.fecha_entrega AS DATETIME2), @r_coord,
       N'Entregado al gestor autorizado: ' + g.nombre
FROM dbo.EquiposEnActa ea
JOIN dbo.ActasEntrega ac ON ac.id_acta = ea.id_acta
JOIN dbo.GestoresRAEE g ON g.id_gestor = ac.id_gestor;

INSERT INTO dbo.Movimientos (id_equipo, id_estado, fecha, id_responsable, observacion)
SELECT ea.id_equipo, @s_cer, DATEADD(day, 1, CAST(ac.fecha_entrega AS DATETIME2)), @r_coord,
       N'Expediente cerrado (paso 5 Cap. IV.2)'
FROM dbo.EquiposEnActa ea
JOIN dbo.ActasEntrega ac ON ac.id_acta = ea.id_acta;

/* Actualizar estado del equipo segun ultima etapa alcanzada */
UPDATE eq
SET eq.estado_equipo = CASE
    WHEN eq.id_equipo IN (SELECT id_equipo FROM EquiposEnActa) THEN N'ENTREGADO'
    WHEN EXISTS (SELECT 1 FROM Movimientos m WHERE m.id_equipo = eq.id_equipo AND m.id_estado = @s_rea) THEN N'REASIGNADO'
    WHEN EXISTS (SELECT 1 FROM Reparaciones r WHERE r.id_equipo = eq.id_equipo) THEN N'REPARADO'
    WHEN EXISTS (SELECT 1 FROM Evaluaciones e WHERE e.id_equipo = eq.id_equipo) THEN N'EVALUADO'
    ELSE eq.estado_equipo
END
FROM dbo.Equipos eq;

PRINT N'Datos de prueba insertados correctamente.';
GO
