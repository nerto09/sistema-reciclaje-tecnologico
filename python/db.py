# -*- coding: utf-8 -*-
"""Capa de acceso a datos - conexion a SQL Server via pyodbc.

Uso:
    from db import get_conn
    with get_conn() as cn:
        cur = cn.cursor()
        cur.execute("SELECT COUNT(*) FROM Equipos")
        print(cur.fetchone()[0])

Autenticacion de Windows (Trusted_Connection) - no hay contrasenas en el codigo.
"""
from __future__ import annotations
import pyodbc
from contextlib import contextmanager

SERVER   = "localhost"
DATABASE = "GestionReciclajeTecnologico"
DRIVER   = "ODBC Driver 18 for SQL Server"

_CONN_STR = (
    f"Driver={{{DRIVER}}};"
    f"Server={SERVER};"
    f"Database={DATABASE};"
    "Trusted_Connection=yes;"
    "Encrypt=yes;"
    "TrustServerCertificate=yes;"
)


@contextmanager
def get_conn():
    """Context manager - abre la conexion y la cierra al salir."""
    cn = pyodbc.connect(_CONN_STR, autocommit=False)
    try:
        yield cn
        cn.commit()
    except Exception:
        cn.rollback()
        raise
    finally:
        cn.close()


def one(sql: str, *params):
    """Devuelve una sola fila (o None) de la primera consulta."""
    with get_conn() as cn:
        row = cn.cursor().execute(sql, *params).fetchone()
        return row


def rows(sql: str, *params):
    """Devuelve todas las filas."""
    with get_conn() as cn:
        return cn.cursor().execute(sql, *params).fetchall()
