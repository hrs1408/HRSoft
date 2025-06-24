from sqlalchemy.orm import Session
from datetime import timedelta
import sys
import os

sys.path.append(os.path.join(os.path.dirname(__file__), "../../../../"))

from shared.auth.jwt_handler import (
    verify_password, get_password_hash,
    create_access_token, create_refresh_token, verify_token
)
from shared.utils.exceptions import (
    AuthenticationError, NotFoundError, DuplicateError, ValidationError
)
from shared.config.settings import get_settings
from app.models.auth import User, RefreshToken
from app.schemas.auth import UserCreate, UserResponse, TokenResponse

settings = get_settings()

class AuthService:
    def __init__(self, db: Session):
        self.db = db

    async def register_user(self, user_data: UserCreate) -> UserResponse:
        """Register a new user"""
        # Check if username already exists
        existing_user = self.db.query(User).filter(User.username == user_data.username).first()
        if existing_user:
            raise DuplicateError("Username already registered")
        
        # Check if email already exists
        existing_email = self.db.query(User).filter(User.email == user_data.email).first()
        if existing_email:
            raise DuplicateError("Email already registered")
        
        # Create new user
        hashed_password = get_password_hash(user_data.password)
        db_user = User(
            username=user_data.username,
            email=user_data.email,
            full_name=user_data.full_name,
            hashed_password=hashed_password,
            permissions=["user"]  # Default permission
        )
        
        self.db.add(db_user)
        self.db.commit()
        self.db.refresh(db_user)
        
        return UserResponse.from_orm(db_user)

    async def login_user(self, username: str, password: str) -> TokenResponse:
        """Login user and return tokens"""
        user = self.db.query(User).filter(User.username == username).first()
        if not user or not verify_password(password, user.hashed_password):
            raise AuthenticationError("Incorrect username or password")
        
        if not user.is_active:
            raise AuthenticationError("Inactive user")
        
        # Create tokens
        access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
        access_token = create_access_token(
            data={"sub": str(user.id), "permissions": user.permissions},
            expires_delta=access_token_expires
        )
        refresh_token = create_refresh_token(data={"sub": str(user.id)})
        
        # Store refresh token
        db_refresh_token = RefreshToken(token=refresh_token, user_id=str(user.id))
        self.db.add(db_refresh_token)
        self.db.commit()
        
        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            expires_in=settings.access_token_expire_minutes * 60
        )

    async def refresh_access_token(self, refresh_token: str) -> TokenResponse:
        """Refresh access token"""
        # Verify refresh token
        payload = verify_token(refresh_token)
        if not payload or payload.get("type") != "refresh":
            raise AuthenticationError("Invalid refresh token")
        
        # Check if token exists and is not revoked
        db_token = self.db.query(RefreshToken).filter(
            RefreshToken.token == refresh_token,
            RefreshToken.is_revoked == False
        ).first()
        
        if not db_token:
            raise AuthenticationError("Invalid or revoked refresh token")
        
        # Get user
        user_id = payload.get("sub")
        user = self.db.query(User).filter(User.id == int(user_id)).first()
        if not user or not user.is_active:
            raise AuthenticationError("User not found or inactive")
        
        # Create new access token
        access_token_expires = timedelta(minutes=settings.access_token_expire_minutes)
        access_token = create_access_token(
            data={"sub": str(user.id), "permissions": user.permissions},
            expires_delta=access_token_expires
        )
        
        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            expires_in=settings.access_token_expire_minutes * 60
        )

    async def logout_user(self, refresh_token: str):
        """Logout user by revoking refresh token"""
        db_token = self.db.query(RefreshToken).filter(
            RefreshToken.token == refresh_token
        ).first()
        
        if db_token:
            db_token.is_revoked = True
            self.db.commit()

    async def change_password(self, user_id: str, current_password: str, new_password: str):
        """Change user password"""
        user = self.db.query(User).filter(User.id == int(user_id)).first()
        if not user:
            raise NotFoundError("User not found")
        
        if not verify_password(current_password, user.hashed_password):
            raise AuthenticationError("Incorrect current password")
        
        user.hashed_password = get_password_hash(new_password)
        self.db.commit()

    async def get_user_by_id(self, user_id: int) -> UserResponse:
        """Get user by ID"""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            raise NotFoundError("User not found")
        
        return UserResponse.from_orm(user)
