import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), "../../../../"))

from sqlalchemy import Column, String, Boolean, JSON
from shared.models.base import BaseModel

class User(BaseModel):
    __tablename__ = "users"
    
    username = Column(String(50), unique=True, index=True, nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    full_name = Column(String(100), nullable=False)
    hashed_password = Column(String(255), nullable=False)
    is_active = Column(Boolean, default=True)
    is_superuser = Column(Boolean, default=False)
    permissions = Column(JSON, default=list)  # List of permission strings

class RefreshToken(BaseModel):
    __tablename__ = "refresh_tokens"
    
    token = Column(String(500), unique=True, index=True, nullable=False)
    user_id = Column(String(50), nullable=False)
    is_revoked = Column(Boolean, default=False)
