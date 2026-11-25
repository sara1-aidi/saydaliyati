# Saydaliyati API (FastAPI + SQLite)

## Run
```bash
cd saydaliyati_backend
python -m venv venv
venv\Scripts\activate          # Windows   (Linux/Mac: source venv/bin/activate)
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```
- `--host 0.0.0.0` lets your phone reach the PC (same Wi-Fi).
- Interactive docs (test every route in the browser): http://localhost:8000/docs
- The database file `saydaliyati.db` is created and filled on the first start.
  Open it with **DB Browser for SQLite** (free) to see the tables.
  Delete the file to reset everything.

## Demo accounts
| Role       | Email                      | Password   |
|------------|----------------------------|------------|
| Pharmacist | pharmacist@saydaliyati.dz  | Pharma123  |
| Client     | amine@example.dz           | Client123  |

## Routes
| Method | Path              | Who          | Purpose                    |
|--------|-------------------|--------------|----------------------------|
| POST   | /auth/register    | anyone       | create a CLIENT account    |
| POST   | /auth/login       | anyone       | returns id, name, role, token |
| POST   | /auth/logout      | signed in    | deletes the session        |
| GET    | /products         | signed in    | list (?search=&limit=&offset=) |
| GET    | /products/{id}    | signed in    | one product                |
| POST   | /products         | pharmacist   | add                        |
| PUT    | /products/{id}    | pharmacist   | edit                       |
| DELETE | /products/{id}    | pharmacist   | delete                     |
