from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
import sys
import os

# Add shared modules to path
sys.path.append(os.path.join(os.path.dirname(__file__), "../../../"))

from shared.config.settings import get_settings
from shared.utils.logging import setup_logging
from shared.utils.exceptions import handle_exception
from app.routers import auth
from app.database import create_tables

settings = get_settings()
logger = setup_logging("auth-service")

# Create FastAPI app
app = FastAPI(
    title="HRSOFT Auth Service",
    description="Authentication and Authorization Service",
    version="1.0.0"
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(auth.router, prefix="/auth", tags=["authentication"])

# Startup event
@app.on_event("startup")
async def startup_event():
    logger.info("Starting Auth Service...")
    create_tables()
    logger.info("Auth Service started successfully!")

# Health check
@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "auth-service"}

# Root endpoint
@app.get("/")
async def root():
    return {"message": "HRSOFT Auth Service", "version": "1.0.0"}

# Exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    logger.error(f"Global exception handler: {exc}")
    return handle_exception(exc)
