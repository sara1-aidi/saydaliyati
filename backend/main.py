"""Saydaliyati REST API (FastAPI + SQLite).

Run:  uvicorn main:app --host 0.0.0.0 --port 8000 --reload
Docs: http://localhost:8000/docs   (interactive, handy to test every route)
"""
import sqlite3
from contextlib import asynccontextmanager
from datetime import datetime, timedelta, timezone
from typing import Literal, Optional

from fastapi import Depends, FastAPI, Header, HTTPException, Query, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import BaseModel, Field

from db import get_conn, init_db
from security import (DUMMY_HASH, hash_password, hash_token, new_token,
                      verify_password)

SESSION_HOURS = 12
EMAIL_PATTERN = r"^[^@\s]+@[^@\s]+\.[^@\s]+$"

Category = Literal[
    "painFever", "coldFlu", "digestive", "vitamins", "antibiotics",
    "skinCare", "babyCare", "firstAid", "devices",
]


@asynccontextmanager
async def lifespan(app: FastAPI):
    init_db()  # creates the tables and seeds demo data on first run
    yield


app = FastAPI(title="Saydaliyati API", version="1.0.0", lifespan=lifespan)

# CORS: needed ONLY when the Flutter app runs in Chrome (web). The browser first
# sends an OPTIONS "preflight" request and refuses to continue unless the server
# allows it. Phones/emulators do not need this. We use a Bearer header (no
# cookies), so allowing all origins is acceptable for development.
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(RequestValidationError)
async def validation_handler(request: Request, exc: RequestValidationError):
    """Return ONE readable message, e.g. {"detail": "price: Input should be ..."}"""
    err = exc.errors()[0]
    field = ".".join(str(p) for p in err["loc"] if p not in ("body", "query", "path"))
    msg = err.get("msg", "Invalid value")
    return JSONResponse(status_code=422, content={"detail": f"{field}: {msg}" if field else msg})


# ----------------------------------------------------------------- schemas
class RegisterIn(BaseModel):
    name: str = Field(min_length=2, max_length=80)
    email: str = Field(pattern=EMAIL_PATTERN, max_length=120)
    password: str = Field(min_length=6, max_length=64)


class LoginIn(BaseModel):
    email: str = Field(max_length=120)
    password: str = Field(max_length=64)


class ProductIn(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    brand: str = Field(default="", max_length=60)
    form: str = Field(default="", max_length=80)
    description: str = Field(default="", max_length=1000)
    price: int = Field(ge=0, le=10_000_000)
    old_price: Optional[int] = Field(default=None, ge=0, le=10_000_000)
    quantity: int = Field(ge=0, le=100_000)
    category: Category
    requires_prescription: bool = False


# ----------------------------------------------------------------- helpers
def product_out(r: sqlite3.Row) -> dict:
    return {
        "id": r["id"], "name": r["name"], "brand": r["brand"], "form": r["form"],
        "description": r["description"], "price": r["price"],
        "old_price": r["old_price"], "quantity": r["quantity"],
        "category": r["category"],
        "requires_prescription": bool(r["requires_prescription"]),
    }


def auth_out(user: sqlite3.Row, token: str) -> dict:
    return {"id": user["id"], "name": user["name"], "email": user["email"],
            "role": user["role"], "token": token}


def create_session(conn: sqlite3.Connection, user_id: int) -> str:
    token = new_token()
    expires = datetime.now(timezone.utc) + timedelta(hours=SESSION_HOURS)
    conn.execute(
        "INSERT INTO login_sessions (user_id, token_hash, expires_at) VALUES (?, ?, ?)",
        (user_id, hash_token(token), expires.isoformat()),
    )
    conn.commit()
    return token


def escape_like(text: str) -> str:
    return text.replace("\\", "\\\\").replace("%", "\\%").replace("_", "\\_")


# ------------------------------------------------------------ auth guards
def current_user(
    authorization: Optional[str] = Header(default=None),
    conn: sqlite3.Connection = Depends(get_conn),
) -> sqlite3.Row:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(401, "Authentication required.")
    token = authorization[7:].strip()
    row = conn.execute(
        """SELECT u.id, u.name, u.email, u.role, s.id AS session_id, s.expires_at
           FROM login_sessions s JOIN users u ON u.id = s.user_id
           WHERE s.token_hash = ?""",
        (hash_token(token),),
    ).fetchone()
    if row is None:
        raise HTTPException(401, "Your session is invalid. Please sign in again.")
    if datetime.fromisoformat(row["expires_at"]) < datetime.now(timezone.utc):
        conn.execute("DELETE FROM login_sessions WHERE id = ?", (row["session_id"],))
        conn.commit()
        raise HTTPException(401, "Your session has expired. Please sign in again.")
    return row


def require_pharmacist(user: sqlite3.Row = Depends(current_user)) -> sqlite3.Row:
    if user["role"] != "pharmacist":
        raise HTTPException(403, "Only the pharmacist can do this.")
    return user


# -------------------------------------------------------------------- auth
@app.get("/")
def health():
    return {"status": "ok", "app": "Saydaliyati API"}


@app.post("/auth/register", status_code=201)
def register(data: RegisterIn, conn: sqlite3.Connection = Depends(get_conn)):
    name = data.name.strip()
    email = data.email.strip().lower()
    if len(name) < 2:
        raise HTTPException(422, "name: Please enter your full name.")
    if conn.execute("SELECT 1 FROM users WHERE email = ?", (email,)).fetchone():
        raise HTTPException(409, "An account with this email already exists.")
    # Self-registration ALWAYS creates a client. Pharmacist accounts are created by the admin.
    cur = conn.execute(
        "INSERT INTO users (name, email, password_hash, role) VALUES (?, ?, ?, 'client')",
        (name, email, hash_password(data.password)),
    )
    conn.commit()
    user = conn.execute("SELECT * FROM users WHERE id = ?", (cur.lastrowid,)).fetchone()
    return auth_out(user, create_session(conn, user["id"]))


@app.post("/auth/login")
def login(data: LoginIn, conn: sqlite3.Connection = Depends(get_conn)):
    user = conn.execute(
        "SELECT * FROM users WHERE email = ?", (data.email.strip().lower(),)
    ).fetchone()
    if user is None:
        verify_password(data.password, DUMMY_HASH)  # same cost as a real check
        raise HTTPException(401, "Invalid email or password.")
    if not verify_password(data.password, user["password_hash"]):
        raise HTTPException(401, "Invalid email or password.")
    return auth_out(user, create_session(conn, user["id"]))


@app.post("/auth/logout", status_code=204)
def logout(user: sqlite3.Row = Depends(current_user),
           conn: sqlite3.Connection = Depends(get_conn)):
    conn.execute("DELETE FROM login_sessions WHERE id = ?", (user["session_id"],))
    conn.commit()


# ---------------------------------------------------------------- products
@app.get("/products")
def list_products(
    search: str = Query("", max_length=100),
    limit: int = Query(100, ge=1, le=100),  # hard cap = "search row limit" (Ex. 8)
    offset: int = Query(0, ge=0),
    conn: sqlite3.Connection = Depends(get_conn),
    user: sqlite3.Row = Depends(current_user),
):
    like = f"%{escape_like(search.strip())}%"
    rows = conn.execute(
        """SELECT * FROM products
           WHERE name LIKE ? ESCAPE '\\' OR brand LIKE ? ESCAPE '\\'
           ORDER BY id LIMIT ? OFFSET ?""",
        (like, like, limit, offset),
    ).fetchall()
    return [product_out(r) for r in rows]


@app.get("/products/{product_id}")
def get_product(product_id: int, conn: sqlite3.Connection = Depends(get_conn),
                user: sqlite3.Row = Depends(current_user)):
    row = conn.execute("SELECT * FROM products WHERE id = ?", (product_id,)).fetchone()
    if row is None:
        raise HTTPException(404, "Product not found.")
    return product_out(row)


@app.post("/products", status_code=201)
def create_product(p: ProductIn, conn: sqlite3.Connection = Depends(get_conn),
                   user: sqlite3.Row = Depends(require_pharmacist)):
    cur = conn.execute(
        """INSERT INTO products (name, brand, form, description, price, old_price,
                                 quantity, category, requires_prescription)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)""",
        (p.name.strip(), p.brand.strip(), p.form.strip(), p.description.strip(),
         p.price, p.old_price, p.quantity, p.category, int(p.requires_prescription)),
    )
    conn.commit()
    row = conn.execute("SELECT * FROM products WHERE id = ?", (cur.lastrowid,)).fetchone()
    return product_out(row)


@app.put("/products/{product_id}")
def update_product(product_id: int, p: ProductIn,
                   conn: sqlite3.Connection = Depends(get_conn),
                   user: sqlite3.Row = Depends(require_pharmacist)):
    cur = conn.execute(
        """UPDATE products SET name = ?, brand = ?, form = ?, description = ?,
                  price = ?, old_price = ?, quantity = ?, category = ?,
                  requires_prescription = ?
           WHERE id = ?""",
        (p.name.strip(), p.brand.strip(), p.form.strip(), p.description.strip(),
         p.price, p.old_price, p.quantity, p.category,
         int(p.requires_prescription), product_id),
    )
    conn.commit()
    if cur.rowcount == 0:
        raise HTTPException(404, "Product not found.")
    row = conn.execute("SELECT * FROM products WHERE id = ?", (product_id,)).fetchone()
    return product_out(row)


@app.delete("/products/{product_id}", status_code=204)
def delete_product(product_id: int, conn: sqlite3.Connection = Depends(get_conn),
                   user: sqlite3.Row = Depends(require_pharmacist)):
    cur = conn.execute("DELETE FROM products WHERE id = ?", (product_id,))
    conn.commit()
    if cur.rowcount == 0:
        raise HTTPException(404, "Product not found.")