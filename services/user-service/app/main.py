from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
import sys
import os

# Add shared modules to path
sys.path.append(os.path.join(os.path.dirname(__file__), "../../../"))

from shared.config.settings import get_settings
from shared.utils.logging import setup_logging
from shared.utils.exceptions import handle_exception
from app.routers import user
from app.database import create_tables

settings = get_settings()
logger = setup_logging("user-service")

# Create FastAPI app
app = FastAPI(
    title="HRSOFT User Service",
    description="User Management Service",
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
app.include_router(user.router, prefix="/users", tags=["users"])

# Startup event
@app.on_event("startup")
async def startup_event():
    logger.info("Starting User Service...")
    create_tables()
    logger.info("User Service started successfully!")

# Health check
@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "user-service"}

# Root endpoint
@app.get("/")
async def root():
    return {"message": "HRSOFT User Service", "version": "1.0.0"}

# Exception handler
@app.exception_handler(Exception)
async def global_exception_handler(request, exc):
    logger.error(f"Global exception handler: {exc}")
    return handle_exception(exc)
