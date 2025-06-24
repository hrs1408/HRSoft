from fastapi import HTTPException, Depends, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from typing import Optional
from shared.auth.jwt_handler import verify_token

security = HTTPBearer()

async def get_current_user(credentials: HTTPAuthorizationCredentials = Depends(security)) -> dict:
    """Get current user from JWT token"""
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = verify_token(credentials.credentials)
        if payload is None:
            raise credentials_exception
        
        user_id: str = payload.get("sub")
        token_type: str = payload.get("type")
        
        if user_id is None or token_type != "access":
            raise credentials_exception
            
        return {"user_id": user_id, "payload": payload}
    except Exception:
        raise credentials_exception

async def get_current_active_user(current_user: dict = Depends(get_current_user)) -> dict:
    """Get current active user"""
    # Additional validation can be added here
    # For example, check if user is active in database
    return current_user

class RequirePermissions:
    """Dependency class for permission-based access control"""
    
    def __init__(self, permissions: list[str]):
        self.permissions = permissions
    
    async def __call__(self, current_user: dict = Depends(get_current_active_user)) -> dict:
        # Check if user has required permissions
        user_permissions = current_user.get("payload", {}).get("permissions", [])
        
        if not all(permission in user_permissions for permission in self.permissions):
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions"
            )
        
        return current_user

# Common permission dependencies
require_admin = RequirePermissions(["admin"])
require_hr = RequirePermissions(["hr", "admin"])
require_manager = RequirePermissions(["manager", "hr", "admin"])
