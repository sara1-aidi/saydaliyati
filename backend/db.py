"""SQLite database: schema, connection and first-run seed data."""
import json
import sqlite3
from pathlib import Path

from security import hash_password

DB_PATH = Path(__file__).with_name("saydaliyati.db")
SEED_PATH = Path(__file__).with_name("seed_products.json")

SCHEMA = """
CREATE TABLE IF NOT EXISTS users (
    id            INTEGER PRIMARY KEY AUTOINCREMENT,
    name          TEXT NOT NULL,
    email         TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role          TEXT NOT NULL CHECK (role IN ('client', 'pharmacist')),
    created_at    TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
    id                    INTEGER PRIMARY KEY AUTOINCREMENT,
    name                  TEXT NOT NULL,
    brand                 TEXT NOT NULL DEFAULT '',
    form                  TEXT NOT NULL DEFAULT '',
    description           TEXT NOT NULL DEFAULT '',
    price                 INTEGER NOT NULL CHECK (price >= 0),
    old_price             INTEGER,
    quantity              INTEGER NOT NULL CHECK (quantity >= 0),
    category              TEXT NOT NULL,
    requires_prescription INTEGER NOT NULL DEFAULT 0
);

-- One row per successful login. Only a hash of the token is stored.
CREATE TABLE IF NOT EXISTS login_sessions (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id    INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash TEXT NOT NULL UNIQUE,
    expires_at TEXT NOT NULL,
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Created now so Exercises 4 and 5 (orders) need no schema change.
CREATE TABLE IF NOT EXISTS orders (
    id         INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id    INTEGER NOT NULL REFERENCES users(id),
    total      INTEGER NOT NULL,
    status     TEXT NOT NULL DEFAULT 'pending',
    created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS order_items (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    order_id     INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id   INTEGER REFERENCES products(id) ON DELETE SET NULL,
    product_name TEXT NOT NULL,
    unit_price   INTEGER NOT NULL,
    quantity     INTEGER NOT NULL
);
"""


def get_conn():
    """FastAPI dependency: one connection per request."""
    conn = sqlite3.connect(DB_PATH, check_same_thread=False)
    conn.row_factory = sqlite3.Row
    conn.execute("PRAGMA foreign_keys = ON")
    try:
        yield conn
    finally:
        conn.close()


def init_db() -> None:
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON")
    conn.executescript(SCHEMA)

    if conn.execute("SELECT COUNT(*) FROM users").fetchone()[0] == 0:
        demo_users = [
            ("Dr. Samira Benali", "pharmacist@saydaliyati.dz", "Pharma123", "pharmacist"),
            ("Amine Boudiaf", "amine@example.dz", "Client123", "client"),
        ]
        for name, email, password, role in demo_users:
            conn.execute(
                "INSERT INTO users (name, email, password_hash, role) VALUES (?, ?, ?, ?)",
                (name, email, hash_password(password), role),
            )

    if conn.execute("SELECT COUNT(*) FROM products").fetchone()[0] == 0:
        for p in json.loads(SEED_PATH.read_text(encoding="utf-8")):
            conn.execute(
                """INSERT INTO products
                   (name, brand, form, description, price, old_price,
                    quantity, category, requires_prescription)
                   VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
                (p["name"], p["brand"], p["form"], p["description"], p["price"],
                 p["old_price"], p["quantity"], p["category"],
                 1 if p["requires_prescription"] else 0),
            )

    conn.commit()
    conn.close()
