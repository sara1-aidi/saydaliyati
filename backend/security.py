"""Password hashing and login-token helpers (Exercise 1 / Exercise 8)."""
import hashlib
import secrets

import bcrypt


def hash_password(password: str) -> str:
    """bcrypt adds a random salt automatically. We store only this hash."""
    return bcrypt.hashpw(password.encode("utf-8"), bcrypt.gensalt()).decode("utf-8")


def verify_password(password: str, password_hash: str) -> bool:
    try:
        return bcrypt.checkpw(password.encode("utf-8"), password_hash.encode("utf-8"))
    except ValueError:
        return False


# Used to spend the same time when the e-mail does not exist, so an attacker
# cannot discover which e-mails have an account by measuring response time.
DUMMY_HASH = hash_password("not-a-real-password")


def new_token() -> str:
    """Long random secret sent to the app after a successful login."""
    return secrets.token_urlsafe(32)


def hash_token(token: str) -> str:
    """Only the SHA-256 fingerprint of the token is stored in the database."""
    return hashlib.sha256(token.encode("utf-8")).hexdigest()
