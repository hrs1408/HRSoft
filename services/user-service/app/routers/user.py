from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from typing import Optional
import sys
import os

sys.path.append(os.path.join(os.path.dirname(__file__), "../../../../"))

from shared.database.base import get_db
from shared.auth.dependencies import get_current_active_user, require_hr
from app.schemas.user import (
    EmployeeCreate, EmployeeUpdate, EmployeeResponse, EmployeeDetailResponse,
    EmployeeListResponse, DepartmentCreate, DepartmentUpdate, DepartmentResponse,
    EmployeeProfileCreate, EmployeeProfileUpdate, EmployeeProfileResponse
)
from app.services.user_service import UserService

router = APIRouter()

# Employee endpoints
@router.post("/employees/", response_model=EmployeeResponse)
async def create_employee(
    employee_data: EmployeeCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_hr)
):
    """Create a new employee (HR only)"""
    user_service = UserService(db)
    return await user_service.create_employee(employee_data)

@router.get("/employees/", response_model=EmployeeListResponse)
async def list_employees(
    page: int = Query(1, ge=1),
    page_size: int = Query(10, ge=1, le=100),
    department_id: Optional[int] = None,
    is_active: Optional[bool] = None,
    search: Optional[str] = None,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_active_user)
):
    """List employees with pagination and filters"""
    user_service = UserService(db)
    return await user_service.list_employees(
        page=page,
        page_size=page_size,
        department_id=department_id,
        is_active=is_active,
        search=search
    )

@router.get("/employees/{employee_id}", response_model=EmployeeDetailResponse)
async def get_employee(
    employee_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_active_user)
):
    """Get employee by ID"""
    user_service = UserService(db)
    return await user_service.get_employee_detail(employee_id)

@router.put("/employees/{employee_id}", response_model=EmployeeResponse)
async def update_employee(
    employee_id: int,
    employee_data: EmployeeUpdate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_hr)
):
    """Update employee (HR only)"""
    user_service = UserService(db)
    return await user_service.update_employee(employee_id, employee_data)

@router.delete("/employees/{employee_id}")
async def delete_employee(
    employee_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_hr)
):
    """Soft delete employee (HR only)"""
    user_service = UserService(db)
    await user_service.delete_employee(employee_id)
    return {"message": "Employee deleted successfully"}

# Employee Profile endpoints
@router.post("/employees/{employee_id}/profile", response_model=EmployeeProfileResponse)
async def create_employee_profile(
    employee_id: int,
    profile_data: EmployeeProfileCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_active_user)
):
    """Create employee profile"""
    user_service = UserService(db)
    profile_data.employee_id = employee_id
    return await user_service.create_employee_profile(profile_data)

@router.put("/employees/{employee_id}/profile", response_model=EmployeeProfileResponse)
async def update_employee_profile(
    employee_id: int,
    profile_data: EmployeeProfileUpdate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_active_user)
):
    """Update employee profile"""
    user_service = UserService(db)
    return await user_service.update_employee_profile(employee_id, profile_data)

# Department endpoints
@router.post("/departments/", response_model=DepartmentResponse)
async def create_department(
    department_data: DepartmentCreate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_hr)
):
    """Create a new department (HR only)"""
    user_service = UserService(db)
    return await user_service.create_department(department_data)

@router.get("/departments/", response_model=list[DepartmentResponse])
async def list_departments(
    is_active: Optional[bool] = None,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_active_user)
):
    """List all departments"""
    user_service = UserService(db)
    return await user_service.list_departments(is_active=is_active)

@router.get("/departments/{department_id}", response_model=DepartmentResponse)
async def get_department(
    department_id: int,
    db: Session = Depends(get_db),
    current_user: dict = Depends(get_current_active_user)
):
    """Get department by ID"""
    user_service = UserService(db)
    return await user_service.get_department(department_id)

@router.put("/departments/{department_id}", response_model=DepartmentResponse)
async def update_department(
    department_id: int,
    department_data: DepartmentUpdate,
    db: Session = Depends(get_db),
    current_user: dict = Depends(require_hr)
):
    """Update department (HR only)"""
    user_service = UserService(db)
    return await user_service.update_department(department_id, department_data)
