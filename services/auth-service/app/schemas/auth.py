from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime

class UserBase(BaseModel):
    username: str
    email: EmailStr
    full_name: str

class UserCreate(UserBase):
    password: str

class UserUpdate(BaseModel):
    username: Optional[str] = None
    email: Optional[EmailStr] = None
    full_name: Optional[str] = None
    is_active: Optional[bool] = None
    permissions: Optional[List[str]] = None

class UserInDB(UserBase):
    id: int
    is_active: bool
    is_superuser: bool
    permissions: List[str]
    created_at: datetime
    updated_at: datetime

class UserResponse(UserBase):
    id: int
    is_active: bool
    is_superuser: bool
    permissions: List[str]
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class LoginRequest(BaseModel):
    username: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int

class RefreshTokenRequest(BaseModel):
    refresh_token: str

class ChangePasswordRequest(BaseModel):
    current_password: str
    new_password: str

class ResetPasswordRequest(BaseModel):
    email: EmailStr

class TokenValidationResponse(BaseModel):
    valid: bool
    user_id: Optional[str] = None
    permissions: Optional[List[str]] = None
