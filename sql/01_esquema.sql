/* =============================================================
   Sistema Informatico para la Gestion, Seguimiento y Analisis
   de los Equipos Tecnologicos
   -------------------------------------------------------------
   Proyecto Final - ING-101 - UNICARIBE (2026-09)
   Autor: Jhonniel Garcia Samboy (A00182637)
   Base de datos SQL Server: GestionReciclajeTecnologico
   Fuente: "Propuesta de Programa de Reciclaje Tecnologico -
           Corregido.docx" (Capitulos III-VI y Anexos B-G)
   Compatible con: SQL Server 2019+ y SSMS
   ============================================================= */

USE master;
GO

IF DB_ID('GestionReciclajeTecnologico') IS NOT NULL
BEGIN
    ALTER DATABASE GestionReciclajeTecnologico SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE GestionReciclajeTecnologico;
END
GO

CREATE DATABASE GestionReciclajeTecnologico;
GO

USE GestionReciclajeTecnologico;
GO

/* -------------------------------------------------------------
   CATALOGOS
   ------------------------------------------------------------- */

CREATE TABLE dbo.Departamentos (
    id_departamento  INT           IDENTITY(1,1) PRIMARY KEY,
    nombre           NVARCHAR(80)  NOT NULL UNIQUE,
    fecha_creacion   DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dbo.Responsables (
    id_responsable   INT           IDENTITY(1,1) PRIMARY KEY,
    nombre           NVARCHAR(120) NOT NULL,
    rol              NVARCHAR(40)  NOT NULL
        CHECK (rol IN (N'Coordinador', N'Inventario y TI',
                       N'Evaluacion tecnica', N'Gestor autorizado')),
    correo           NVARCHAR(120) NULL,
    telefono         NVARCHAR(40)  NULL,
    fecha_creacion   DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dbo.EstadosMovimiento (
    id_estado        INT           IDENTITY(1,1) PRIMARY KEY,
    codigo           VARCHAR(40)   NOT NULL UNIQUE,
    descripcion      NVARCHAR(120) NOT NULL,
    es_final         BIT           NOT NULL DEFAULT 0
);
GO

CREATE TABLE dbo.MetodosBorrado (
    id_metodo        INT           IDENTITY(1,1) PRIMARY KEY,
    codigo           VARCHAR(30)   NOT NULL UNIQUE,
    descripcion      NVARCHAR(200) NOT NULL
);
GO

CREATE TABLE dbo.GestoresRAEE (
    id_gestor              INT           IDENTITY(1,1) PRIMARY KEY,
    nombre                 NVARCHAR(150) NOT NULL,
    ubicacion              NVARCHAR(80)  NOT NULL,
    autorizacion           NVARCHAR(120) NOT NULL,
    actividad_autorizada   NVARCHAR(300) NOT NULL,
    telefono               NVARCHAR(60)  NULL,
    fecha_creacion         DATETIME2     NOT NULL DEFAULT SYSDATETIME()
);
GO

/* -------------------------------------------------------------
   ENTIDAD PRINCIPAL: EQUIPOS
   Origen: Anexo B (Formato de registro de inventario) - 12 campos
   ------------------------------------------------------------- */

CREATE TABLE dbo.Equipos (
    id_equipo                  INT           IDENTITY(1,1) PRIMARY KEY,
    codigo_interno             NVARCHAR(20)  NOT NULL UNIQUE,
    tipo_equipo                NVARCHAR(60)  NOT NULL,
    marca                      NVARCHAR(60)  NOT NULL,
    modelo                     NVARCHAR(60)  NOT NULL,
    numero_serie               NVARCHAR(80)  NOT NULL UNIQUE,
    ubicacion                  NVARCHAR(120) NOT NULL,
    id_departamento            INT           NOT NULL,
    id_responsable             INT           NOT NULL,
    estado_equipo              NVARCHAR(30)  NOT NULL DEFAULT N'EN_USO',
    fecha_adquisicion          DATE          NOT NULL,
    fecha_ultimo_mantenimiento DATE          NULL,
    fecha_retiro               DATE          NULL,
    motivo_retiro              NVARCHAR(200) NULL,
    fecha_creacion             DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Equipos_Departamentos
        FOREIGN KEY (id_departamento) REFERENCES dbo.Departamentos(id_departamento),
    CONSTRAINT FK_Equipos_Responsables
        FOREIGN KEY (id_responsable) REFERENCES dbo.Responsables(id_responsable),
    CONSTRAINT CK_Equipos_Estado
        CHECK (estado_equipo IN (N'EN_USO', N'RETIRADO', N'EVALUADO',
                                 N'REPARADO', N'REASIGNADO',
                                 N'ENTREGADO', N'DESTRUIDO'))
);
GO

/* -------------------------------------------------------------
   EVALUACION TECNICA - Anexo C
   ------------------------------------------------------------- */

CREATE TABLE dbo.Evaluaciones (
    id_evaluacion         INT           IDENTITY(1,1) PRIMARY KEY,
    id_equipo             INT           NOT NULL,
    fecha_evaluacion      DATE          NOT NULL,
    id_responsable        INT           NOT NULL,
    costo_estimado_rd     DECIMAL(10,2) NULL,
    reparacion_viable     BIT           NULL,
    clasificacion_final   NVARCHAR(20)  NULL
        CHECK (clasificacion_final IN (N'Reutilizable', N'Reparable', N'No recuperable')),
    destino_propuesto     NVARCHAR(120) NULL,
    firma_responsable     NVARCHAR(200) NULL,
    fecha_creacion        DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Evaluaciones_Equipos
        FOREIGN KEY (id_equipo) REFERENCES dbo.Equipos(id_equipo),
    CONSTRAINT FK_Evaluaciones_Responsables
        FOREIGN KEY (id_responsable) REFERENCES dbo.Responsables(id_responsable)
);
GO

CREATE TABLE dbo.EvaluacionFisica (
    id_ev_fisica     INT           IDENTITY(1,1) PRIMARY KEY,
    id_evaluacion    INT           NOT NULL,
    elemento         NVARCHAR(30)  NOT NULL
        CHECK (elemento IN (N'Pantalla', N'Teclado', N'Carcasa', N'Cables',
                            N'Puertos', N'Bateria', N'Fuente de alimentacion')),
    estado           CHAR(1)       NOT NULL CHECK (estado IN ('B','D')),
    observaciones    NVARCHAR(300) NULL,
    CONSTRAINT FK_EvFisica_Evaluaciones
        FOREIGN KEY (id_evaluacion) REFERENCES dbo.Evaluaciones(id_evaluacion) ON DELETE CASCADE,
    CONSTRAINT UQ_EvFisica_por_elemento UNIQUE (id_evaluacion, elemento)
);
GO

CREATE TABLE dbo.EvaluacionTecnica (
    id_ev_tecnica    INT           IDENTITY(1,1) PRIMARY KEY,
    id_evaluacion    INT           NOT NULL,
    aspecto          NVARCHAR(80)  NOT NULL
        CHECK (aspecto IN (N'Enciende correctamente',
                           N'Sistema operativo funciona',
                           N'Ejecuta los programas necesarios',
                           N'Componentes internos en buen estado')),
    resultado        BIT           NOT NULL,
    observaciones    NVARCHAR(300) NULL,
    CONSTRAINT FK_EvTecnica_Evaluaciones
        FOREIGN KEY (id_evaluacion) REFERENCES dbo.Evaluaciones(id_evaluacion) ON DELETE CASCADE,
    CONSTRAINT UQ_EvTecnica_por_aspecto UNIQUE (id_evaluacion, aspecto)
);
GO

/* -------------------------------------------------------------
   REPARACIONES - Capitulo III.4 + Capitulo IV.5
   ------------------------------------------------------------- */

CREATE TABLE dbo.Reparaciones (
    id_reparacion       INT           IDENTITY(1,1) PRIMARY KEY,
    id_equipo           INT           NOT NULL,
    fecha_inicio        DATE          NOT NULL,
    fecha_fin           DATE          NULL,
    falla_encontrada    NVARCHAR(300) NOT NULL,
    trabajo_realizado   NVARCHAR(500) NULL,
    costo_rd            DECIMAL(10,2) NULL,
    resultado           NVARCHAR(20)  NOT NULL DEFAULT N'En proceso'
        CHECK (resultado IN (N'Recuperado', N'No recuperado', N'En proceso')),
    id_responsable      INT           NOT NULL,
    observaciones       NVARCHAR(300) NULL,
    fecha_creacion      DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Reparaciones_Equipos
        FOREIGN KEY (id_equipo) REFERENCES dbo.Equipos(id_equipo),
    CONSTRAINT FK_Reparaciones_Responsables
        FOREIGN KEY (id_responsable) REFERENCES dbo.Responsables(id_responsable)
);
GO

/* -------------------------------------------------------------
   BORRADO SEGURO - Anexo D
   ------------------------------------------------------------- */

CREATE TABLE dbo.BorradosSeguros (
    id_borrado                 INT           IDENTITY(1,1) PRIMARY KEY,
    id_equipo                  INT           NOT NULL,
    tipo_soporte               NVARCHAR(60)  NOT NULL,
    id_metodo                  INT           NOT NULL,
    herramienta                NVARCHAR(120) NULL,
    verificacion_posterior     BIT           NOT NULL,
    fecha_procedimiento        DATE          NOT NULL,
    id_responsable_borrado     INT           NOT NULL,
    id_responsable_verifica    INT           NULL,
    destino_autorizado         NVARCHAR(200) NULL,
    evidencia_ruta             NVARCHAR(300) NULL,
    fecha_creacion             DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Borrados_Equipos
        FOREIGN KEY (id_equipo) REFERENCES dbo.Equipos(id_equipo),
    CONSTRAINT FK_Borrados_Metodos
        FOREIGN KEY (id_metodo) REFERENCES dbo.MetodosBorrado(id_metodo),
    CONSTRAINT FK_Borrados_ResBorrado
        FOREIGN KEY (id_responsable_borrado) REFERENCES dbo.Responsables(id_responsable),
    CONSTRAINT FK_Borrados_ResVerifica
        FOREIGN KEY (id_responsable_verifica) REFERENCES dbo.Responsables(id_responsable)
);
GO

/* -------------------------------------------------------------
   TRAZABILIDAD: MOVIMIENTOS - Capitulo IV.2
   ------------------------------------------------------------- */

CREATE TABLE dbo.Movimientos (
    id_movimiento     INT           IDENTITY(1,1) PRIMARY KEY,
    id_equipo         INT           NOT NULL,
    id_estado         INT           NOT NULL,
    fecha             DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    id_responsable    INT           NOT NULL,
    observacion       NVARCHAR(500) NULL,
    valor_evitado_rd  DECIMAL(10,2) NULL,
    CONSTRAINT FK_Movimientos_Equipos
        FOREIGN KEY (id_equipo) REFERENCES dbo.Equipos(id_equipo),
    CONSTRAINT FK_Movimientos_Estados
        FOREIGN KEY (id_estado) REFERENCES dbo.EstadosMovimiento(id_estado),
    CONSTRAINT FK_Movimientos_Responsables
        FOREIGN KEY (id_responsable) REFERENCES dbo.Responsables(id_responsable)
);
GO

CREATE INDEX IX_Movimientos_Equipo_Fecha ON dbo.Movimientos(id_equipo, fecha);
GO

/* -------------------------------------------------------------
   ACTAS DE ENTREGA - Anexo E
   ------------------------------------------------------------- */

CREATE TABLE dbo.ActasEntrega (
    id_acta               INT           IDENTITY(1,1) PRIMARY KEY,
    empresa_entrega       NVARCHAR(150) NOT NULL,
    id_gestor             INT           NOT NULL,
    numero_autorizacion   NVARCHAR(60)  NOT NULL,
    fecha_entrega         DATE          NOT NULL,
    lugar_entrega         NVARCHAR(150) NOT NULL,
    cantidad_equipos      INT           NOT NULL DEFAULT 0,
    peso_kg               DECIMAL(8,2)  NOT NULL DEFAULT 0,
    fecha_creacion        DATETIME2     NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Actas_Gestores
        FOREIGN KEY (id_gestor) REFERENCES dbo.GestoresRAEE(id_gestor)
);
GO

CREATE TABLE dbo.EquiposEnActa (
    id_equipo_acta   INT           IDENTITY(1,1) PRIMARY KEY,
    id_acta          INT           NOT NULL,
    id_equipo        INT           NOT NULL,
    id_borrado       INT           NULL,
    CONSTRAINT FK_EqActa_Actas
        FOREIGN KEY (id_acta) REFERENCES dbo.ActasEntrega(id_acta) ON DELETE CASCADE,
    CONSTRAINT FK_EqActa_Equipos
        FOREIGN KEY (id_equipo) REFERENCES dbo.Equipos(id_equipo),
    CONSTRAINT FK_EqActa_Borrados
        FOREIGN KEY (id_borrado) REFERENCES dbo.BorradosSeguros(id_borrado),
    CONSTRAINT UQ_EqActa_UnEquipoPorActa UNIQUE (id_acta, id_equipo)
);
GO

/* -------------------------------------------------------------
   CATALOGOS SEMILLA
   ------------------------------------------------------------- */

INSERT INTO dbo.EstadosMovimiento (codigo, descripcion, es_final) VALUES
    ('REGISTRADO',                 N'Equipo registrado en el inventario',                 0),
    ('EN_ALMACEN_TEMPORAL',        N'Equipo en almacen temporal',                          0),
    ('EN_EVALUACION',              N'Equipo en evaluacion tecnica',                        0),
    ('CLASIFICADO_REUTILIZABLE',   N'Clasificado como reutilizable',                       0),
    ('CLASIFICADO_REPARABLE',      N'Clasificado como reparable',                          0),
    ('CLASIFICADO_NO_RECUPERABLE', N'Clasificado como no recuperable',                     0),
    ('EN_REPARACION',              N'Equipo en proceso de reparacion',                     0),
    ('REASIGNADO',                 N'Equipo reasignado dentro de la empresa',              0),
    ('BORRADO_SEGURO_APLICADO',    N'Borrado seguro aplicado y verificado',                0),
    ('ENTREGADO_A_GESTOR',         N'Equipo entregado al gestor autorizado',               0),
    ('CERRADO',                    N'Expediente cerrado - destino final documentado',      1);
GO

INSERT INTO dbo.MetodosBorrado (codigo, descripcion) VALUES
    ('SOBREESCRITURA',      N'Sobreescritura del disco completo (norma NIST SP 800-88)'),
    ('DESTRUCCION_FISICA',  N'Destruccion fisica del soporte de almacenamiento'),
    ('DESMAGNETIZACION',    N'Desmagnetizacion del soporte');
GO

INSERT INTO dbo.GestoresRAEE (nombre, ubicacion, autorizacion, actividad_autorizada, telefono) VALUES
    (N'Planta de Almacenamiento y Trasbordo de Desechos Industriales (MIRSA)',
     N'Santiago',
     N'P. Ambiental num. 0312-04 (renovado)',
     N'Tratamiento y disposicion final por incineracion; incluye equipos electronicos',
     NULL),
    (N'Residuos Clasificados Diversos, S.R.L. (RESICLA)',
     N'Santo Domingo',
     N'P. Ambiental num. 1753-12 (renovado)',
     N'Recoleccion de residuos industriales a nivel nacional, incluye RAEE',
     N'(809) 682-1645'),
    (N'JRC Services, S.R.L.',
     N'Santo Domingo',
     N'P. Ambiental num. 4452-22',
     N'Recoleccion, transporte, clasificacion e incineracion de residuos peligrosos',
     N'(809) 563-5889'),
    (N'Ecologix, S.R.L.',
     N'Santo Domingo',
     N'P. Ambiental num. 4116-21',
     N'Recoleccion, clasificacion, almacenamiento y compra de residuos solidos y RAEE',
     N'(809) 596-7101');
GO

INSERT INTO dbo.Responsables (nombre, rol, correo) VALUES
    (N'Coordinador del Programa',         N'Coordinador',         NULL),
    (N'Encargado de Inventario y TI',     N'Inventario y TI',     NULL),
    (N'Tecnico Evaluador',                N'Evaluacion tecnica',  NULL);
GO

INSERT INTO dbo.Departamentos (nombre) VALUES
    (N'Administracion'),
    (N'Contabilidad'),
    (N'Recursos Humanos'),
    (N'Tecnologia de la Informacion'),
    (N'Almacen'),
    (N'Ventas');
GO

PRINT N'Esquema creado correctamente.';
GO
