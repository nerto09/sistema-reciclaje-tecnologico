# -*- coding: utf-8 -*-
"""Interfaz grafica (Tkinter) del Sistema de Gestion de Reciclaje Tecnologico.

Cinco pestañas conectadas a la BD `GestionReciclajeTecnologico`:
  1. Equipos    - listado del inventario (Anexo B)
  2. Evaluacion - registrar evaluacion tecnica (Anexo C)
  3. Borrado    - registrar constancia de borrado seguro (Anexo D)
  4. Historial  - trazabilidad del equipo (Cap. IV.2 + Anexo A)
  5. Indicadores - los 7 indicadores del Cap. IV.7 T02

Uso:
    python app.py                # abre la aplicacion
    python app.py --auto-capture # captura cada pestaña en capturas/10_, 11_, 12_
"""
from __future__ import annotations
import sys, os, argparse
from datetime import datetime, date
import tkinter as tk
from tkinter import ttk, messagebox

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from db import get_conn

# Paleta UNICARIBE
AZUL   = "#151B3F"
VERDE  = "#179347"
AMAR   = "#FCBD1C"
ROJO   = "#C01224"
GRIS   = "#5A5A5A"
BG     = "#FFFFFF"
BG_ALT = "#F4F5F8"


class App(tk.Tk):
    def __init__(self):
        super().__init__()
        self.title("Sistema de Gestion de Reciclaje Tecnologico  -  UNICARIBE / ING-101")
        self.geometry("1440x780")
        self.configure(bg=BG)
        self._style()
        self._header()
        self._statusbar()
        self._tabs()

    # ---------- estilo ----------
    def _style(self):
        st = ttk.Style(self)
        try:
            st.theme_use("clam")
        except tk.TclError:
            pass
        st.configure("TNotebook", background=BG, borderwidth=0)
        st.configure("TNotebook.Tab", padding=(18, 10), font=("Segoe UI", 10, "bold"))
        st.map("TNotebook.Tab",
               background=[("selected", AZUL)],
               foreground=[("selected", "#FFFFFF"), ("!selected", GRIS)])
        st.configure("Treeview", rowheight=24, font=("Segoe UI", 9))
        st.configure("Treeview.Heading", font=("Segoe UI", 9, "bold"),
                     background=AZUL, foreground="#FFFFFF")
        st.configure("TButton", padding=(12, 6), font=("Segoe UI", 9, "bold"))
        st.configure("Accent.TButton", background=VERDE, foreground="#FFFFFF")
        st.map("Accent.TButton", background=[("active", "#0E7A38")])

    # ---------- header ----------
    def _header(self):
        head = tk.Frame(self, bg=AZUL, height=60)
        head.pack(fill="x")
        head.pack_propagate(False)
        tk.Label(head, text="UNICARIBE",
                 bg=AZUL, fg=AMAR, font=("Segoe UI", 14, "bold")).pack(side="left", padx=20)
        tk.Label(head,
                 text="Programa de Reciclaje Tecnologico  -  Modulo de gestion de equipos",
                 bg=AZUL, fg="#FFFFFF", font=("Segoe UI", 11)).pack(side="left")
        tk.Label(head, text="ING-101  -  Trabajo Final 2026",
                 bg=AZUL, fg="#B0B4C7", font=("Segoe UI", 9)).pack(side="right", padx=20)

    # ---------- tabs ----------
    def _tabs(self):
        self.nb = ttk.Notebook(self)
        self.nb.pack(fill="both", expand=True, padx=10, pady=10)
        self.tab_equipos     = TabEquipos(self.nb, self)
        self.tab_evaluacion  = TabEvaluacion(self.nb, self)
        self.tab_borrado     = TabBorrado(self.nb, self)
        self.tab_historial   = TabHistorial(self.nb, self)
        self.tab_indicadores = TabIndicadores(self.nb, self)
        self.nb.add(self.tab_equipos,     text="  1. Equipos  ")
        self.nb.add(self.tab_evaluacion,  text="  2. Evaluacion  ")
        self.nb.add(self.tab_borrado,     text="  3. Borrado seguro  ")
        self.nb.add(self.tab_historial,   text="  4. Historial  ")
        self.nb.add(self.tab_indicadores, text="  5. Indicadores  ")

    def _statusbar(self):
        self.status = tk.Label(self, bd=1, relief="sunken", anchor="w",
                               bg=BG_ALT, fg=GRIS, font=("Segoe UI", 9),
                               text="Conectado a SQL Server localhost / GestionReciclajeTecnologico")
        self.status.pack(side="bottom", fill="x")

    def set_status(self, txt):
        self.status.configure(text=txt)


# =============================================================================
# TAB 1 - EQUIPOS
# =============================================================================
class TabEquipos(tk.Frame):
    def __init__(self, master, app):
        super().__init__(master, bg=BG)
        self.app = app
        tk.Label(self, text="Inventario de equipos tecnologicos (Anexo B del proyecto)",
                 bg=BG, fg=AZUL, font=("Segoe UI", 13, "bold")).pack(anchor="w", padx=20, pady=(20, 4))
        tk.Label(self, text="15 equipos de la empresa tipo, categorizados por su estado actual",
                 bg=BG, fg=GRIS, font=("Segoe UI", 9)).pack(anchor="w", padx=20)

        cols = ("codigo", "tipo", "marca", "modelo", "depto", "estado",
                "fecha_adq", "fecha_ret", "movs")
        head = ("Codigo interno", "Tipo", "Marca", "Modelo", "Departamento",
                "Estado", "Adquisicion", "Retiro", "Mov.")
        widths = (110, 110, 80, 140, 170, 110, 90, 90, 50)

        wrap = tk.Frame(self, bg=BG); wrap.pack(fill="both", expand=True, padx=20, pady=10)
        self.tree = ttk.Treeview(wrap, columns=cols, show="headings", height=18)
        for c, h, w in zip(cols, head, widths):
            self.tree.heading(c, text=h)
            self.tree.column(c, width=w, anchor="w")
        vsb = ttk.Scrollbar(wrap, orient="vertical", command=self.tree.yview)
        self.tree.configure(yscrollcommand=vsb.set)
        self.tree.pack(side="left", fill="both", expand=True)
        vsb.pack(side="right", fill="y")

        self.tree.tag_configure("reasig",  background="#E9F5EE")
        self.tree.tag_configure("entreg",  background="#FBE7E9")
        self.tree.tag_configure("retir",   background="#FFF6DE")

        bar = tk.Frame(self, bg=BG); bar.pack(fill="x", padx=20, pady=10)
        ttk.Button(bar, text="Actualizar", command=self.cargar).pack(side="left")
        self.lbl_total = tk.Label(bar, text="", bg=BG, fg=GRIS, font=("Segoe UI", 9))
        self.lbl_total.pack(side="right")
        self.cargar()

    def cargar(self):
        self.tree.delete(*self.tree.get_children())
        with get_conn() as cn:
            rows = cn.cursor().execute("""
                SELECT e.codigo_interno, e.tipo_equipo, e.marca, e.modelo,
                       d.nombre, e.estado_equipo,
                       CONVERT(varchar(10), e.fecha_adquisicion, 120),
                       CONVERT(varchar(10), e.fecha_retiro, 120),
                       (SELECT COUNT(*) FROM Movimientos WHERE id_equipo = e.id_equipo)
                FROM Equipos e JOIN Departamentos d ON d.id_departamento = e.id_departamento
                ORDER BY e.codigo_interno""").fetchall()
        for r in rows:
            tag = ("reasig" if r[5] == "REASIGNADO"
                   else "entreg" if r[5] == "ENTREGADO"
                   else "retir" if r[5] == "RETIRADO"
                   else "")
            self.tree.insert("", "end", values=tuple("" if v is None else v for v in r), tags=(tag,))
        self.lbl_total.config(text=f"Total: {len(rows)} equipos")
        self.app.set_status(f"Equipos cargados: {len(rows)}")


# =============================================================================
# TAB 2 - EVALUACION
# =============================================================================
class TabEvaluacion(tk.Frame):
    def __init__(self, master, app):
        super().__init__(master, bg=BG)
        self.app = app
        tk.Label(self, text="Ficha de evaluacion tecnica (Anexo C del proyecto)",
                 bg=BG, fg=AZUL, font=("Segoe UI", 13, "bold")).pack(anchor="w", padx=20, pady=(20, 4))

        wrap = tk.Frame(self, bg=BG); wrap.pack(fill="both", expand=True, padx=20, pady=10)

        # --- panel izquierdo: encabezado + resultado
        izq = tk.LabelFrame(wrap, text="  Encabezado y resultado  ",
                            bg=BG, fg=AZUL, font=("Segoe UI", 10, "bold"), padx=16, pady=10)
        izq.pack(side="left", fill="y", padx=(0, 12))

        tk.Label(izq, text="Codigo del equipo:", bg=BG, fg=GRIS, font=("Segoe UI", 9)).grid(row=0, column=0, sticky="w", pady=6)
        self.cb_equipo = ttk.Combobox(izq, width=22, state="readonly", font=("Segoe UI", 10))
        self.cb_equipo.grid(row=0, column=1, sticky="w", pady=6)

        tk.Label(izq, text="Fecha:", bg=BG, fg=GRIS, font=("Segoe UI", 9)).grid(row=1, column=0, sticky="w", pady=6)
        self.e_fecha = tk.Entry(izq, width=24, font=("Segoe UI", 10))
        self.e_fecha.insert(0, date.today().isoformat())
        self.e_fecha.grid(row=1, column=1, sticky="w", pady=6)

        tk.Label(izq, text="Costo estim. (RD$):", bg=BG, fg=GRIS, font=("Segoe UI", 9)).grid(row=2, column=0, sticky="w", pady=6)
        self.e_costo = tk.Entry(izq, width=24, font=("Segoe UI", 10))
        self.e_costo.grid(row=2, column=1, sticky="w", pady=6)

        tk.Label(izq, text="Reparacion viable:", bg=BG, fg=GRIS, font=("Segoe UI", 9)).grid(row=3, column=0, sticky="w", pady=6)
        self.cb_viable = ttk.Combobox(izq, width=22, state="readonly",
                                      values=["", "Si", "No"], font=("Segoe UI", 10))
        self.cb_viable.grid(row=3, column=1, sticky="w", pady=6)

        tk.Label(izq, text="Clasificacion final:", bg=BG, fg=GRIS, font=("Segoe UI", 9)).grid(row=4, column=0, sticky="w", pady=6)
        self.cb_clasif = ttk.Combobox(izq, width=22, state="readonly",
                                      values=["Reutilizable", "Reparable", "No recuperable"],
                                      font=("Segoe UI", 10))
        self.cb_clasif.grid(row=4, column=1, sticky="w", pady=6)

        tk.Label(izq, text="Destino propuesto:", bg=BG, fg=GRIS, font=("Segoe UI", 9)).grid(row=5, column=0, sticky="w", pady=6)
        self.e_destino = tk.Entry(izq, width=24, font=("Segoe UI", 10))
        self.e_destino.grid(row=5, column=1, sticky="w", pady=6)

        tk.Label(izq, text="Responsable tecnico:", bg=BG, fg=GRIS, font=("Segoe UI", 9)).grid(row=6, column=0, sticky="w", pady=6)
        self.cb_resp = ttk.Combobox(izq, width=22, state="readonly", font=("Segoe UI", 10))
        self.cb_resp.grid(row=6, column=1, sticky="w", pady=6)

        ttk.Button(izq, text="Registrar evaluacion",
                   command=self.guardar, style="Accent.TButton").grid(row=7, column=0, columnspan=2, pady=(14, 4))
        self.msg = tk.Label(izq, text="", bg=BG, fg=VERDE, font=("Segoe UI", 9, "bold"))
        self.msg.grid(row=8, column=0, columnspan=2, pady=(6, 0))

        # --- panel derecho: chequeos fisicos y tecnicos
        der = tk.Frame(wrap, bg=BG); der.pack(side="left", fill="both", expand=True)

        gf = tk.LabelFrame(der, text="  Evaluacion fisica (Anexo C, 7 elementos)  ",
                           bg=BG, fg=AZUL, font=("Segoe UI", 10, "bold"), padx=12, pady=8)
        gf.pack(fill="x")
        self.chk_fisica = {}
        elementos = ["Pantalla", "Teclado", "Carcasa", "Cables",
                     "Puertos", "Bateria", "Fuente de alimentacion"]
        for i, el in enumerate(elementos):
            row = i // 2; col = i % 2
            var = tk.StringVar(value="B")
            f = tk.Frame(gf, bg=BG); f.grid(row=row, column=col, sticky="w", padx=6, pady=4)
            tk.Label(f, text=el, bg=BG, fg=GRIS, font=("Segoe UI", 9), width=22, anchor="w").pack(side="left")
            tk.Radiobutton(f, text="Bien",   value="B", variable=var,
                           bg=BG, fg=VERDE, font=("Segoe UI", 9)).pack(side="left", padx=2)
            tk.Radiobutton(f, text="Dañado", value="D", variable=var,
                           bg=BG, fg=ROJO, font=("Segoe UI", 9)).pack(side="left", padx=2)
            self.chk_fisica[el] = var

        gt = tk.LabelFrame(der, text="  Evaluacion tecnica (Anexo C, 4 aspectos)  ",
                           bg=BG, fg=AZUL, font=("Segoe UI", 10, "bold"), padx=12, pady=8)
        gt.pack(fill="x", pady=(10, 0))
        self.chk_tecnica = {}
        aspectos = ["Enciende correctamente",
                    "Sistema operativo funciona",
                    "Ejecuta los programas necesarios",
                    "Componentes internos en buen estado"]
        for i, asp in enumerate(aspectos):
            var = tk.IntVar(value=1)
            f = tk.Frame(gt, bg=BG); f.pack(fill="x", pady=3)
            tk.Label(f, text=asp, bg=BG, fg=GRIS, font=("Segoe UI", 9), width=36, anchor="w").pack(side="left")
            tk.Radiobutton(f, text="Si", value=1, variable=var,
                           bg=BG, fg=VERDE, font=("Segoe UI", 9)).pack(side="left", padx=6)
            tk.Radiobutton(f, text="No", value=0, variable=var,
                           bg=BG, fg=ROJO, font=("Segoe UI", 9)).pack(side="left")
            self.chk_tecnica[asp] = var

        self.cargar_comboboxes()

    def cargar_comboboxes(self):
        with get_conn() as cn:
            equipos = [r[0] for r in cn.cursor().execute(
                "SELECT codigo_interno FROM Equipos ORDER BY codigo_interno").fetchall()]
            resps = [f"{r[0]} - {r[1]}" for r in cn.cursor().execute(
                "SELECT id_responsable, rol FROM Responsables ORDER BY id_responsable").fetchall()]
        self.cb_equipo.configure(values=equipos)
        self.cb_resp.configure(values=resps)
        if equipos: self.cb_equipo.current(2)  # una laptop
        if resps:   self.cb_resp.current(2)    # tecnico
        self.cb_clasif.current(0)
        self.cb_viable.current(1)
        self.e_costo.insert(0, "5500")
        self.e_destino.insert(0, "Reasignacion a Recursos Humanos")

    def guardar(self):
        try:
            with get_conn() as cn:
                cur = cn.cursor()
                id_eq = cur.execute("SELECT id_equipo FROM Equipos WHERE codigo_interno = ?",
                                    self.cb_equipo.get()).fetchone()[0]
                id_resp = int(self.cb_resp.get().split(" - ")[0])
                costo = float(self.e_costo.get()) if self.e_costo.get().strip() else None
                viable = {"Si": 1, "No": 0, "": None}[self.cb_viable.get()]
                cur.execute("""INSERT INTO Evaluaciones
                    (id_equipo, fecha_evaluacion, id_responsable, costo_estimado_rd,
                     reparacion_viable, clasificacion_final, destino_propuesto, firma_responsable)
                    OUTPUT INSERTED.id_evaluacion
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?)""",
                    id_eq, self.e_fecha.get(), id_resp, costo, viable,
                    self.cb_clasif.get(), self.e_destino.get(),
                    "Registrado desde interfaz Tkinter")
                id_ev = cur.fetchone()[0]
                for el, var in self.chk_fisica.items():
                    cur.execute("""INSERT INTO EvaluacionFisica (id_evaluacion, elemento, estado, observaciones)
                                   VALUES (?, ?, ?, NULL)""", id_ev, el, var.get())
                for asp, var in self.chk_tecnica.items():
                    cur.execute("""INSERT INTO EvaluacionTecnica (id_evaluacion, aspecto, resultado, observaciones)
                                   VALUES (?, ?, ?, NULL)""", id_ev, asp, var.get())
            self.msg.configure(text=f"Evaluacion #{id_ev} registrada correctamente")
            self.app.set_status(f"Evaluacion {id_ev} guardada para {self.cb_equipo.get()}")
        except Exception as ex:
            self.msg.configure(text=f"Error: {ex}", fg=ROJO)


# =============================================================================
# TAB 3 - BORRADO SEGURO
# =============================================================================
class TabBorrado(tk.Frame):
    def __init__(self, master, app):
        super().__init__(master, bg=BG)
        self.app = app
        tk.Label(self, text="Constancia de borrado seguro (Anexo D del proyecto)",
                 bg=BG, fg=AZUL, font=("Segoe UI", 13, "bold")).pack(anchor="w", padx=20, pady=(20, 4))
        tk.Label(self, text="Decreto 253-23, art. 19: obligatorio destruir la informacion antes de entregar el equipo",
                 bg=BG, fg=ROJO, font=("Segoe UI", 9, "italic")).pack(anchor="w", padx=20)

        f = tk.Frame(self, bg=BG); f.pack(fill="x", padx=20, pady=20)

        def row(r, label, widget):
            tk.Label(f, text=label, bg=BG, fg=GRIS, font=("Segoe UI", 9),
                     width=22, anchor="w").grid(row=r, column=0, sticky="w", pady=6)
            widget.grid(row=r, column=1, sticky="w", pady=6)

        self.cb_equipo = ttk.Combobox(f, width=32, state="readonly", font=("Segoe UI", 10))
        row(0, "Equipo:", self.cb_equipo)

        self.e_soporte = tk.Entry(f, width=34, font=("Segoe UI", 10))
        self.e_soporte.insert(0, "HDD 500 GB SATA")
        row(1, "Tipo de soporte:", self.e_soporte)

        self.cb_metodo = ttk.Combobox(f, width=32, state="readonly", font=("Segoe UI", 10))
        row(2, "Metodo aplicado:", self.cb_metodo)

        self.e_herramienta = tk.Entry(f, width=34, font=("Segoe UI", 10))
        self.e_herramienta.insert(0, "DBAN 2.3.0 (metodo DoD 5220.22-M)")
        row(3, "Herramienta:", self.e_herramienta)

        self.cb_verif = ttk.Combobox(f, width=32, state="readonly",
                                     values=["Si", "No"], font=("Segoe UI", 10))
        self.cb_verif.current(0)
        row(4, "Verificacion posterior:", self.cb_verif)

        self.e_fecha = tk.Entry(f, width=34, font=("Segoe UI", 10))
        self.e_fecha.insert(0, date.today().isoformat())
        row(5, "Fecha del procedimiento:", self.e_fecha)

        self.cb_resp_b = ttk.Combobox(f, width=32, state="readonly", font=("Segoe UI", 10))
        row(6, "Responsable del borrado:", self.cb_resp_b)

        self.cb_resp_v = ttk.Combobox(f, width=32, state="readonly", font=("Segoe UI", 10))
        row(7, "Verificado por:", self.cb_resp_v)

        self.e_destino = tk.Entry(f, width=34, font=("Segoe UI", 10))
        self.e_destino.insert(0, "Ecologix, S.R.L.")
        row(8, "Destino autorizado:", self.e_destino)

        self.e_evid = tk.Entry(f, width=34, font=("Segoe UI", 10))
        self.e_evid.insert(0, r"\\CUERVO\evidencias\borrado\EQ-XXX-XXXX.pdf")
        row(9, "Evidencia (ruta):", self.e_evid)

        ttk.Button(f, text="Registrar constancia",
                   command=self.guardar, style="Accent.TButton").grid(row=10, column=0, columnspan=2, pady=14)
        self.msg = tk.Label(f, text="", bg=BG, fg=VERDE, font=("Segoe UI", 9, "bold"))
        self.msg.grid(row=11, column=0, columnspan=2)

        self.cargar_comboboxes()

    def cargar_comboboxes(self):
        with get_conn() as cn:
            eqs = [r[0] for r in cn.cursor().execute(
                "SELECT codigo_interno FROM Equipos ORDER BY codigo_interno").fetchall()]
            mets = [f"{r[0]} - {r[1]}" for r in cn.cursor().execute(
                "SELECT codigo, descripcion FROM MetodosBorrado").fetchall()]
            resps = [f"{r[0]} - {r[1]}" for r in cn.cursor().execute(
                "SELECT id_responsable, rol FROM Responsables ORDER BY id_responsable").fetchall()]
        self.cb_equipo.configure(values=eqs); self.cb_equipo.current(3)
        self.cb_metodo.configure(values=mets); self.cb_metodo.current(0)
        self.cb_resp_b.configure(values=resps); self.cb_resp_b.current(1)
        self.cb_resp_v.configure(values=resps); self.cb_resp_v.current(0)

    def guardar(self):
        try:
            with get_conn() as cn:
                cur = cn.cursor()
                id_eq = cur.execute("SELECT id_equipo FROM Equipos WHERE codigo_interno = ?",
                                    self.cb_equipo.get()).fetchone()[0]
                cod_m = self.cb_metodo.get().split(" - ")[0]
                id_m = cur.execute("SELECT id_metodo FROM MetodosBorrado WHERE codigo = ?", cod_m).fetchone()[0]
                id_rb = int(self.cb_resp_b.get().split(" - ")[0])
                id_rv = int(self.cb_resp_v.get().split(" - ")[0])
                cur.execute("""INSERT INTO BorradosSeguros
                    (id_equipo, tipo_soporte, id_metodo, herramienta,
                     verificacion_posterior, fecha_procedimiento,
                     id_responsable_borrado, id_responsable_verifica,
                     destino_autorizado, evidencia_ruta)
                    OUTPUT INSERTED.id_borrado
                    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                    id_eq, self.e_soporte.get(), id_m, self.e_herramienta.get(),
                    1 if self.cb_verif.get() == "Si" else 0,
                    self.e_fecha.get(), id_rb, id_rv,
                    self.e_destino.get(), self.e_evid.get())
                id_b = cur.fetchone()[0]
            self.msg.configure(text=f"Constancia #{id_b} registrada correctamente")
            self.app.set_status(f"Constancia {id_b} guardada para {self.cb_equipo.get()}")
        except Exception as ex:
            self.msg.configure(text=f"Error: {ex}", fg=ROJO)


# =============================================================================
# TAB 4 - HISTORIAL
# =============================================================================
class TabHistorial(tk.Frame):
    def __init__(self, master, app):
        super().__init__(master, bg=BG)
        self.app = app
        tk.Label(self, text="Historial completo de un equipo (Capitulo IV.2 - trazabilidad)",
                 bg=BG, fg=AZUL, font=("Segoe UI", 13, "bold")).pack(anchor="w", padx=20, pady=(20, 4))

        f = tk.Frame(self, bg=BG); f.pack(fill="x", padx=20, pady=10)
        tk.Label(f, text="Equipo:", bg=BG, fg=GRIS, font=("Segoe UI", 10)).pack(side="left")
        self.cb_equipo = ttk.Combobox(f, width=22, state="readonly", font=("Segoe UI", 10))
        self.cb_equipo.pack(side="left", padx=8)
        ttk.Button(f, text="Consultar", command=self.cargar).pack(side="left", padx=6)

        self.lbl_res = tk.Label(f, text="", bg=BG, fg=GRIS, font=("Segoe UI", 9))
        self.lbl_res.pack(side="right")

        cols = ("i", "fecha", "estado", "responsable", "obs", "valor")
        head = ("#", "Fecha", "Estado", "Responsable", "Observacion", "Valor RD$")
        widths = (30, 145, 210, 140, 470, 90)

        wrap = tk.Frame(self, bg=BG); wrap.pack(fill="both", expand=True, padx=20, pady=10)
        self.tree = ttk.Treeview(wrap, columns=cols, show="headings", height=18)
        for c, h, w in zip(cols, head, widths):
            self.tree.heading(c, text=h)
            self.tree.column(c, width=w, anchor="w")
        vsb = ttk.Scrollbar(wrap, orient="vertical", command=self.tree.yview)
        self.tree.configure(yscrollcommand=vsb.set)
        self.tree.pack(side="left", fill="both", expand=True)
        vsb.pack(side="right", fill="y")

        self.tree.tag_configure("alt", background=BG_ALT)

        with get_conn() as cn:
            eqs = [r[0] for r in cn.cursor().execute(
                "SELECT codigo_interno FROM Equipos ORDER BY codigo_interno").fetchall()]
        self.cb_equipo.configure(values=eqs)
        if eqs:
            self.cb_equipo.set("EQ-LAP-0004")   # el que tiene el historial completo
            self.cargar()

    def cargar(self):
        self.tree.delete(*self.tree.get_children())
        cod = self.cb_equipo.get()
        if not cod: return
        with get_conn() as cn:
            rows = cn.cursor().execute("""
                SELECT m.fecha, em.codigo, r.rol, m.observacion, m.valor_evitado_rd
                FROM Movimientos m
                JOIN EstadosMovimiento em ON em.id_estado = m.id_estado
                JOIN Responsables r        ON r.id_responsable = m.id_responsable
                JOIN Equipos e             ON e.id_equipo = m.id_equipo
                WHERE e.codigo_interno = ?
                ORDER BY m.fecha, m.id_movimiento""", cod).fetchall()
        for i, r in enumerate(rows, 1):
            val = f"RD${r[4]:,.2f}" if r[4] else ""
            self.tree.insert("", "end",
                values=(i, r[0].strftime("%Y-%m-%d %H:%M:%S"), r[1], r[2], r[3], val),
                tags=("alt",) if i % 2 == 0 else ())
        self.lbl_res.config(text=f"Equipo {cod}: {len(rows)} movimientos")
        self.app.set_status(f"Historial de {cod}: {len(rows)} movimientos")


# =============================================================================
# TAB 5 - INDICADORES
# =============================================================================
class TabIndicadores(tk.Frame):
    def __init__(self, master, app):
        super().__init__(master, bg=BG)
        self.app = app
        tk.Label(self, text="Indicadores del programa (Capitulo IV.7 T02)",
                 bg=BG, fg=AZUL, font=("Segoe UI", 13, "bold")).pack(anchor="w", padx=20, pady=(20, 4))
        tk.Label(self, text="Los 7 indicadores del proyecto, calculados en vivo desde SQL Server",
                 bg=BG, fg=GRIS, font=("Segoe UI", 9)).pack(anchor="w", padx=20)

        self.frame = tk.Frame(self, bg=BG); self.frame.pack(fill="both", expand=True, padx=20, pady=15)
        self.actualizar()

        ttk.Button(self, text="Recalcular",
                   command=self.actualizar, style="Accent.TButton").pack(pady=(0, 10))

    def actualizar(self):
        for w in self.frame.winfo_children():
            w.destroy()

        with get_conn() as cn:
            cur = cn.cursor()
            reut = cur.execute("""SELECT COUNT(DISTINCT id_equipo) FROM Movimientos m
                                  JOIN EstadosMovimiento e ON e.id_estado = m.id_estado
                                  WHERE e.codigo = 'REASIGNADO'""").fetchone()[0]
            evals = cur.execute("SELECT COUNT(*) FROM Evaluaciones").fetchone()[0]
            reps  = cur.execute("SELECT COUNT(*), COALESCE(SUM(costo_rd),0) FROM Reparaciones WHERE resultado='Recuperado'").fetchone()
            raee  = cur.execute("SELECT COALESCE(SUM(peso_kg),0), COALESCE(SUM(cantidad_equipos),0) FROM ActasEntrega").fetchone()
            bs    = cur.execute("SELECT COUNT(*) FROM BorradosSeguros").fetchone()[0]
            sal   = cur.execute("SELECT COUNT(*) FROM Equipos WHERE estado_equipo IN ('ENTREGADO','DESTRUIDO')").fetchone()[0]
            perm  = cur.execute("""
              WITH r AS (
                SELECT m.id_equipo,
                       MIN(CASE WHEN em.codigo='EN_ALMACEN_TEMPORAL' THEN m.fecha END) i,
                       MIN(CASE WHEN em.codigo IN ('REASIGNADO','ENTREGADO_A_GESTOR') THEN m.fecha END) f
                FROM Movimientos m JOIN EstadosMovimiento em ON em.id_estado = m.id_estado
                GROUP BY m.id_equipo)
              SELECT AVG(DATEDIFF(day, i, f)*1.0) FROM r WHERE i IS NOT NULL AND f IS NOT NULL""").fetchone()[0] or 0
            valev = cur.execute("SELECT COALESCE(SUM(valor_evitado_rd),0) FROM Movimientos").fetchone()[0]
            cerr  = cur.execute("""SELECT COUNT(DISTINCT id_equipo) FROM Movimientos m
                                   JOIN EstadosMovimiento e ON e.id_estado=m.id_estado WHERE e.codigo='CERRADO'""").fetchone()[0]
            tot   = cur.execute("SELECT COUNT(*) FROM Equipos").fetchone()[0]

        cards = [
            ("1. Equipos reutilizados",          f"{(reut/evals*100 if evals else 0):.1f} %",
             f"{reut} de {evals} evaluados",     VERDE),
            ("2. Equipos reparados",             f"{reps[0]}",
             f"Costo: RD${reps[1]:,.2f}",        AZUL),
            ("3. RAEE gestionados",              f"{raee[0]:.1f} kg",
             f"{raee[1]} equipos entregados",    AMAR),
            ("4. Borrado seguro documentado",    f"{(bs/sal*100 if sal else 0):.0f} %",
             f"{bs} constancias / {sal} salidas", VERDE),
            ("5. Permanencia en almacen",        f"{perm:.1f} dias",
             "promedio entre retiro y destino",  AZUL),
            ("6. Compras evitadas",              f"RD${valev:,.0f}",
             "por reasignaciones internas",      VERDE),
            ("7. Expedientes completos",         f"{(cerr/tot*100 if tot else 0):.1f} %",
             f"{cerr} cerrados / {tot} equipos", AMAR),
        ]

        for c in range(3):
            self.frame.columnconfigure(c, weight=1, uniform="c")
        for i, (titulo, valor, sub, color) in enumerate(cards):
            row = i // 3; col = i % 3
            card = tk.Frame(self.frame, bg=BG_ALT, bd=0, highlightthickness=1,
                            highlightbackground="#E4E6EE")
            card.grid(row=row, column=col, padx=8, pady=8, sticky="nsew", ipadx=10, ipady=10)
            self.frame.columnconfigure(col, weight=1)
            tk.Label(card, text=titulo, bg=BG_ALT, fg=GRIS,
                     font=("Segoe UI", 9, "bold"), anchor="w").pack(fill="x", padx=8, pady=(4, 0))
            tk.Label(card, text=valor, bg=BG_ALT, fg=color,
                     font=("Segoe UI", 26, "bold")).pack(anchor="w", padx=8)
            tk.Label(card, text=sub, bg=BG_ALT, fg=GRIS,
                     font=("Segoe UI", 9)).pack(anchor="w", padx=8, pady=(0, 6))

        self.app.set_status("Indicadores recalculados en vivo")


# =============================================================================
# ENTRY POINT + AUTO CAPTURE
# =============================================================================

def _grab_window(app, path):
    app.update_idletasks()
    app.attributes("-topmost", True)
    app.lift()
    app.focus_force()
    app.update()
    x = app.winfo_rootx(); y = app.winfo_rooty()
    w = app.winfo_width(); h = app.winfo_height()
    from PIL import ImageGrab
    ImageGrab.grab(bbox=(x, y, x + w, y + h)).save(path)
    print("captura:", path)


def auto_capture(app, out_dir):
    tabs = [
        (0, "10_tkinter_equipos.png"),
        (1, "11_tkinter_evaluacion.png"),
        (3, "12_tkinter_historial.png"),
        (4, "13_tkinter_indicadores.png"),
    ]
    it = iter(tabs)
    def next_shot():
        try:
            idx, name = next(it)
        except StopIteration:
            app.after(300, app.destroy); return
        app.nb.select(idx)
        app.after(900, lambda: (_grab_window(app, os.path.join(out_dir, name)),
                                app.after(300, next_shot)))
    app.geometry("+40+40")
    app.attributes("-topmost", True)
    app.after(1200, next_shot)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--auto-capture", metavar="DIR",
                    help="Guarda una captura PNG de cada pestaña en DIR y cierra")
    args = ap.parse_args()

    app = App()
    if args.auto_capture:
        os.makedirs(args.auto_capture, exist_ok=True)
        auto_capture(app, args.auto_capture)
    app.mainloop()


if __name__ == "__main__":
    main()
