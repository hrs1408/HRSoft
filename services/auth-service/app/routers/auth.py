from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
import sys
import os

sys.path.append(os.path.join(os.path.dirname(__file__), "../../../../"))

from shared.database.base import get_db
from shared.auth.dependencies import get_current_active_user
from app.schemas.auth import (
    LoginRequest, TokenResponse, RefreshTokenRequest,
    UserCreate, UserResponse, ChangePasswordRequest,
    TokenValidationResponse
)
from app.services.auth_service import AuthService

router = APIRouter()

@router.post("/register", response_model=UserResponse)
async def register(user_data: UserCreate, db: Session = Depends(get_db)):
    """Register a new user"""
    auth_service = AuthService(db)
    return await auth_service.register_user(user_data)

@router.post("/login", response_model=TokenResponse)
async def login(login_data: LoginRequest, db: Session = Depends(get_db)):
    """Login user and return tokens"""
    auth_service = AuthService(db)
    return await auth_service.login_user(login_data.username, login_data.password)

@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(refresh_data: RefreshTokenRequest, db: Session = Depends(get_db)):
    """Refresh access token"""
    auth_service = AuthService(db)
    return await auth_service.refresh_access_token(refresh_data.refresh_token)

@router.post("/logout")
async def logout(
    refresh_data: RefreshTokenRequest,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_active_user)
):
    """Logout user and revoke refresh token"""
    auth_service = AuthService(db)
    await auth_service.logout_user(refresh_data.refresh_token)
    return {"message": "Successfully logged out"}

@router.post("/validate-token", response_model=TokenValidationResponse)
async def validate_token(current_user: dict = Depends(get_current_active_user)):
    """Validate token and return user info"""
    return TokenValidationResponse(
        valid=True,
        user_id=current_user["user_id"],
        permissions=current_user.get("payload", {}).get("permissions", [])
    )

@router.post("/change-password")
async def change_password(
    password_data: ChangePasswordRequest,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_active_user)
):
    """Change user password"""
    auth_service = AuthService(db)
    await auth_service.change_password(
        current_user["user_id"],
        password_data.current_password,
        password_data.new_password
    )
    return {"message": "Password changed successfully"}

@router.get("/me", response_model=UserResponse)
async def get_current_user_info(
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_active_user)
):
    """Get current user information"""
    auth_service = AuthService(db)
    return await auth_service.get_user_by_id(int(current_user["user_id"]))
