from fastapi import HTTPException, status
from typing import Optional, Any

class HRSoftException(Exception):
    """Base exception for HRSOFT application"""
    def __init__(self, message: str, status_code: int = 500):
        self.message = message
        self.status_code = status_code
        super().__init__(self.message)

class AuthenticationError(HRSoftException):
    """Authentication related errors"""
    def __init__(self, message: str = "Authentication failed"):
        super().__init__(message, status.HTTP_401_UNAUTHORIZED)

class AuthorizationError(HRSoftException):
    """Authorization related errors"""
    def __init__(self, message: str = "Insufficient permissions"):
        super().__init__(message, status.HTTP_403_FORBIDDEN)

class NotFoundError(HRSoftException):
    """Resource not found errors"""
    def __init__(self, message: str = "Resource not found"):
        super().__init__(message, status.HTTP_404_NOT_FOUND)

class ValidationError(HRSoftException):
    """Data validation errors"""
    def __init__(self, message: str = "Validation failed"):
        super().__init__(message, status.HTTP_422_UNPROCESSABLE_ENTITY)

class DuplicateError(HRSoftException):
    """Duplicate resource errors"""
    def __init__(self, message: str = "Resource already exists"):
        super().__init__(message, status.HTTP_409_CONFLICT)

class ServiceUnavailableError(HRSoftException):
    """Service unavailable errors"""
    def __init__(self, message: str = "Service temporarily unavailable"):
        super().__init__(message, status.HTTP_503_SERVICE_UNAVAILABLE)

def handle_exception(e: Exception) -> HTTPException:
    """Convert custom exceptions to HTTPException"""
    if isinstance(e, HRSoftException):
        return HTTPException(status_code=e.status_code, detail=e.message)
    else:
        return HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Internal server error"
        )
