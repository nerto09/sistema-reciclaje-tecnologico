# -*- coding: utf-8 -*-
"""Implementacion en Python del diagrama de flujo del Anexo A.

Este programa toma un equipo (por codigo interno) y lo hace recorrer el
procedimiento del Capitulo IV.2 del proyecto, registrando cada paso como un
movimiento en SQL Server. Sirve como prueba de concepto del flujo antes de
montar la interfaz Tkinter.

Diagrama de flujo implementado (Anexo A del proyecto):

    REGISTRO -> ALMACEN_TEMPORAL -> EVALUACION
                                       |
        +------------------------------+-----------------------------+
        |                              |                             |
        v                              v                             v
    REUTILIZABLE                   REPARABLE                  NO_RECUPERABLE
        |                              |                             |
        v                        EN_REPARACION                       v
    REASIGNADO                         |                    BORRADO_SEGURO
        |                    +---------+---------+                   |
        v                    |                   |                   v
     CERRADO             Recuperado         No recuperado    ENTREGADO_A_GESTOR
                             |                   |                   |
                             v                   v                   v
                        REASIGNADO         BORRADO_SEGURO        CERRADO
                             |                   |
                             v                   v
                          CERRADO       ENTREGADO_A_GESTOR
                                                 |
                                                 v
                                              CERRADO

Uso:
    python flujo_equipo.py                    # lista equipos y menu interactivo
    python flujo_equipo.py --demo EQ-LAP-0002 # camina el flujo de un equipo demo
"""
from __future__ import annotations
import argparse
import sys
from datetime import datetime
from db import get_conn


# --- utilidades ---------------------------------------------------------------

def print_h(title):
    print()
    print("=" * 72)
    print(f"  {title}")
    print("=" * 72)


def get_id_estado(cur, codigo):
    return cur.execute(
        "SELECT id_estado FROM EstadosMovimiento WHERE codigo = ?", codigo
    ).fetchone()[0]


def get_id_responsable(cur, rol):
    return cur.execute(
        "SELECT TOP 1 id_responsable FROM Responsables WHERE rol = ?", rol
    ).fetchone()[0]


def registrar_movimiento(cur, id_equipo, codigo_estado, id_responsable,
                         observacion=None, valor_evitado=None):
    id_estado = get_id_estado(cur, codigo_estado)
    cur.execute(
        """INSERT INTO Movimientos (id_equipo, id_estado, fecha, id_responsable,
                                    observacion, valor_evitado_rd)
           VALUES (?, ?, SYSDATETIME(), ?, ?, ?)""",
        id_equipo, id_estado, id_responsable, observacion, valor_evitado)
    print(f"  [OK] Movimiento registrado: {codigo_estado}"
          + (f"  |  {observacion}" if observacion else ""))


def get_equipo(cur, codigo_interno):
    row = cur.execute(
        """SELECT id_equipo, codigo_interno, tipo_equipo, marca, modelo, estado_equipo
           FROM Equipos WHERE codigo_interno = ?""", codigo_interno).fetchone()
    if not row:
        raise ValueError(f"Equipo {codigo_interno} no existe")
    return row


def get_ultima_clasificacion(cur, id_equipo):
    row = cur.execute(
        """SELECT TOP 1 clasificacion_final FROM Evaluaciones
           WHERE id_equipo = ? AND clasificacion_final IS NOT NULL
           ORDER BY fecha_evaluacion DESC""", id_equipo).fetchone()
    return row[0] if row else None


# --- pasos del flujo ----------------------------------------------------------

def paso_registro_y_almacen(cur, id_equipo, r_ti):
    print("\n[Paso 1] Retiro y registro del equipo")
    registrar_movimiento(cur, id_equipo, "REGISTRADO", r_ti,
                         "Retiro y registro (paso 1 Cap. IV.2)")
    print("\n[Paso 2] Traslado a almacen temporal")
    registrar_movimiento(cur, id_equipo, "EN_ALMACEN_TEMPORAL", r_ti,
                         "Traslado al area de almacenamiento temporal")


def paso_evaluacion(cur, id_equipo, r_tecnico):
    print("\n[Paso 3] Evaluacion tecnica")
    registrar_movimiento(cur, id_equipo, "EN_EVALUACION", r_tecnico,
                         "Evaluacion tecnica iniciada")


def paso_clasificacion(cur, id_equipo, clasificacion, r_tecnico):
    """clasificacion: 'Reutilizable' | 'Reparable' | 'No recuperable'"""
    codigo = {
        "Reutilizable":   "CLASIFICADO_REUTILIZABLE",
        "Reparable":      "CLASIFICADO_REPARABLE",
        "No recuperable": "CLASIFICADO_NO_RECUPERABLE",
    }[clasificacion]
    print(f"\n[Paso 4] Clasificacion: {clasificacion}")
    registrar_movimiento(cur, id_equipo, codigo, r_tecnico,
                         f"Clasificacion: {clasificacion}")


def paso_reasignar(cur, id_equipo, r_coord, valor_evitado_rd=None):
    print("\n[Paso 5a] Reasignacion dentro de la empresa")
    registrar_movimiento(cur, id_equipo, "REASIGNADO", r_coord,
                         "Reasignado dentro de la empresa",
                         valor_evitado=valor_evitado_rd)
    cur.execute("UPDATE Equipos SET estado_equipo = ? WHERE id_equipo = ?",
                "REASIGNADO", id_equipo)


def paso_reparacion(cur, id_equipo, falla, r_tecnico, exito=True, costo_rd=None):
    print(f"\n[Paso 5b] Reparacion: {falla}")
    registrar_movimiento(cur, id_equipo, "EN_REPARACION", r_tecnico,
                         f"Reparacion iniciada: {falla}")
    hoy = datetime.now().date()
    cur.execute(
        """INSERT INTO Reparaciones
              (id_equipo, fecha_inicio, fecha_fin, falla_encontrada,
               trabajo_realizado, costo_rd, resultado, id_responsable, observaciones)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
        id_equipo, hoy, hoy, falla,
        "Reparacion registrada por flujo_equipo.py", costo_rd,
        "Recuperado" if exito else "No recuperado",
        r_tecnico, None)
    print(f"  [OK] Reparacion registrada ({'Recuperado' if exito else 'No recuperado'})")
    return exito


def paso_borrado_seguro(cur, id_equipo, r_borra, r_verifica):
    print("\n[Paso 5c] Borrado seguro aplicado")
    id_metodo = cur.execute(
        "SELECT id_metodo FROM MetodosBorrado WHERE codigo = 'SOBREESCRITURA'"
    ).fetchone()[0]
    codigo = cur.execute(
        "SELECT codigo_interno FROM Equipos WHERE id_equipo = ?", id_equipo
    ).fetchone()[0]
    cur.execute(
        """INSERT INTO BorradosSeguros
             (id_equipo, tipo_soporte, id_metodo, herramienta,
              verificacion_posterior, fecha_procedimiento,
              id_responsable_borrado, id_responsable_verifica,
              destino_autorizado, evidencia_ruta)
           VALUES (?, ?, ?, ?, 1, CAST(SYSDATETIME() AS DATE), ?, ?, ?, ?)""",
        id_equipo, "HDD 500 GB SATA", id_metodo,
        "DBAN 2.3.0 (metodo DoD 5220.22-M)",
        r_borra, r_verifica,
        "Ecologix, S.R.L.",
        rf"\\CUERVO\evidencias\borrado\{codigo}.pdf")
    registrar_movimiento(cur, id_equipo, "BORRADO_SEGURO_APLICADO", r_borra,
                         "Borrado seguro aplicado y verificado (SOBREESCRITURA)")


def paso_entrega_a_gestor(cur, id_equipo, r_coord):
    print("\n[Paso 5d] Entrega al gestor autorizado")
    registrar_movimiento(cur, id_equipo, "ENTREGADO_A_GESTOR", r_coord,
                         "Entregado al gestor autorizado: Ecologix, S.R.L.")
    cur.execute("UPDATE Equipos SET estado_equipo = ? WHERE id_equipo = ?",
                "ENTREGADO", id_equipo)


def paso_cerrar(cur, id_equipo, r_coord):
    print("\n[Paso 6] Expediente cerrado")
    registrar_movimiento(cur, id_equipo, "CERRADO", r_coord,
                         "Expediente cerrado (paso 5 Cap. IV.2)")


# --- orquestador del flujo completo ------------------------------------------

VALORES_COMPRA_EVITADA = {
    "Laptop":         42000,
    "PC escritorio":  32000,
    "Monitor":         8500,
    "Impresora":       9500,
}


def flujo_completo(codigo_interno, clasificacion=None,
                   falla="Falla generica", exito_reparacion=True):
    """Ejecuta el diagrama de flujo del Anexo A completo para un equipo.

    Si `clasificacion` es None, la deduce de la ultima evaluacion registrada.
    """
    with get_conn() as cn:
        cur = cn.cursor()

        eq = get_equipo(cur, codigo_interno)
        id_equipo, cod, tipo, marca, modelo, estado = eq
        print_h(f"Flujo del Anexo A -> {cod}  ({marca} {modelo})")

        r_coord   = get_id_responsable(cur, "Coordinador")
        r_ti      = get_id_responsable(cur, "Inventario y TI")
        r_tecnico = get_id_responsable(cur, "Evaluacion tecnica")

        # No re-registrar si el equipo ya paso por REGISTRADO
        ya_iniciado = cur.execute(
            "SELECT COUNT(*) FROM Movimientos WHERE id_equipo = ?", id_equipo
        ).fetchone()[0] > 0

        if not ya_iniciado:
            paso_registro_y_almacen(cur, id_equipo, r_ti)

        paso_evaluacion(cur, id_equipo, r_tecnico)

        if clasificacion is None:
            clasificacion = get_ultima_clasificacion(cur, id_equipo) or "Reutilizable"

        paso_clasificacion(cur, id_equipo, clasificacion, r_tecnico)

        valor = VALORES_COMPRA_EVITADA.get(tipo, 5000)

        if clasificacion == "Reutilizable":
            paso_reasignar(cur, id_equipo, r_coord, valor_evitado_rd=valor)
            paso_cerrar(cur, id_equipo, r_coord)

        elif clasificacion == "Reparable":
            recuperado = paso_reparacion(cur, id_equipo, falla, r_tecnico,
                                         exito=exito_reparacion,
                                         costo_rd=4500)
            if recuperado:
                paso_reasignar(cur, id_equipo, r_coord, valor_evitado_rd=valor)
                paso_cerrar(cur, id_equipo, r_coord)
            else:
                paso_borrado_seguro(cur, id_equipo, r_ti, r_coord)
                paso_entrega_a_gestor(cur, id_equipo, r_coord)
                paso_cerrar(cur, id_equipo, r_coord)

        elif clasificacion == "No recuperable":
            paso_borrado_seguro(cur, id_equipo, r_ti, r_coord)
            paso_entrega_a_gestor(cur, id_equipo, r_coord)
            paso_cerrar(cur, id_equipo, r_coord)

        else:
            raise ValueError(f"Clasificacion desconocida: {clasificacion}")

        print("\n[OK] Flujo completado. Cambios persistidos en SQL Server.")


# --- utilidades interactivas -------------------------------------------------

def listar_equipos():
    print_h("Equipos registrados en el sistema")
    with get_conn() as cn:
        cur = cn.cursor()
        rows = cur.execute(
            """SELECT e.codigo_interno, e.tipo_equipo, e.marca, e.modelo,
                      e.estado_equipo,
                      (SELECT COUNT(*) FROM Movimientos WHERE id_equipo = e.id_equipo) AS n_mov
               FROM Equipos e ORDER BY e.codigo_interno""").fetchall()
    print(f"{'Codigo':14s} {'Tipo':16s} {'Marca':10s} {'Modelo':22s} {'Estado':12s} {'Mov'}")
    print("-" * 92)
    for r in rows:
        print(f"{r[0]:14s} {r[1]:16s} {r[2]:10s} {r[3]:22s} {r[4]:12s} {r[5]:>3d}")
    print(f"\nTotal: {len(rows)} equipos")


def historial_equipo(codigo_interno):
    print_h(f"Historial del equipo {codigo_interno}")
    with get_conn() as cn:
        cur = cn.cursor()
        cur.execute(
            """SELECT m.fecha, em.codigo, r.rol, m.observacion, m.valor_evitado_rd
               FROM Movimientos m
               JOIN EstadosMovimiento em ON em.id_estado = m.id_estado
               JOIN Responsables r        ON r.id_responsable = m.id_responsable
               JOIN Equipos e             ON e.id_equipo = m.id_equipo
               WHERE e.codigo_interno = ?
               ORDER BY m.fecha, m.id_movimiento""", codigo_interno)
        print(f"{'#':>3s}  {'Fecha':19s}  {'Estado':30s}  {'Rol':22s}  Observacion")
        print("-" * 120)
        for i, r in enumerate(cur.fetchall(), 1):
            v = f"  (RD${r[4]:,.2f})" if r[4] else ""
            print(f"{i:>3d}  {r[0].strftime('%Y-%m-%d %H:%M:%S')}  {r[1]:30s}  {r[2]:22s}  {r[3]}{v}")


# --- main --------------------------------------------------------------------

def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    ap.add_argument("--demo", metavar="CODIGO_INTERNO",
                    help="Ejecuta el flujo completo para el equipo dado")
    ap.add_argument("--clasificar", choices=["Reutilizable", "Reparable", "No recuperable"],
                    help="Clasificacion a aplicar en el demo")
    ap.add_argument("--historial", metavar="CODIGO_INTERNO",
                    help="Muestra el historial de movimientos del equipo")
    ap.add_argument("--listar", action="store_true", help="Lista todos los equipos")
    args = ap.parse_args()

    if args.listar:
        listar_equipos()
    elif args.historial:
        historial_equipo(args.historial)
    elif args.demo:
        flujo_completo(args.demo, clasificacion=args.clasificar)
    else:
        listar_equipos()
        print("\nOpciones:")
        print("  python flujo_equipo.py --historial EQ-LAP-0001")
        print("  python flujo_equipo.py --demo EQ-LAP-0002 --clasificar Reutilizable")


if __name__ == "__main__":
    main()
