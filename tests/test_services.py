import pytest
import asyncio
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from fastapi.testclient import TestClient
import sys
import os

# Add project root to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from shared.database.base import Base
from shared.config.settings import get_settings

# Test auth service
sys.path.append(os.path.join(os.path.dirname(__file__), "../services/auth-service"))
from app.main import app as auth_app

# Test user service  
sys.path.append(os.path.join(os.path.dirname(__file__), "../services/user-service"))
from app.main import app as user_app

def test_auth_service_health():
    """Test auth service health endpoint"""
    client = TestClient(auth_app)
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"
    assert response.json()["service"] == "auth-service"

def test_auth_service_root():
    """Test auth service root endpoint"""
    client = TestClient(auth_app)
    response = client.get("/")
    assert response.status_code == 200
    assert "HRSOFT Auth Service" in response.json()["message"]

def test_user_service_health():
    """Test user service health endpoint"""
    client = TestClient(user_app)
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"
    assert response.json()["service"] == "user-service"

def test_user_service_root():
    """Test user service root endpoint"""
    client = TestClient(user_app)
    response = client.get("/")
    assert response.status_code == 200
    assert "HRSOFT User Service" in response.json()["message"]
