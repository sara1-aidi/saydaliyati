# Saydaliyati

Full-stack project: FastAPI + SQLite backend, Flutter frontend.

## Backend (FastAPI + SQLite)
cd backend
python -m venv .venv
.venv\Scripts\activate
pip install -r requirements.txt
uvicorn main:app --reload
# API docs: http://127.0.0.1:8000/docs

## Frontend (Flutter)
cd frontend
flutter pub get
flutter run
