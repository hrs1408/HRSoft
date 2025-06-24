from pydantic import BaseModel, EmailStr
from typing import Optional, List
from datetime import datetime, date
from decimal import Decimal

class DepartmentBase(BaseModel):
    name: str
    description: Optional[str] = None
    budget: Optional[int] = None

class DepartmentCreate(DepartmentBase):
    pass

class DepartmentUpdate(BaseModel):
    name: Optional[str] = None
    description: Optional[str] = None
    manager_id: Optional[int] = None
    budget: Optional[int] = None
    is_active: Optional[bool] = None

class DepartmentResponse(DepartmentBase):
    id: int
    manager_id: Optional[int] = None
    is_active: bool
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class EmployeeBase(BaseModel):
    employee_id: str
    first_name: str
    last_name: str
    email: EmailStr
    phone: Optional[str] = None
    date_of_birth: Optional[date] = None
    address: Optional[str] = None
    position: Optional[str] = None
    hire_date: Optional[date] = None
    salary: Optional[int] = None

class EmployeeCreate(EmployeeBase):
    department_id: Optional[int] = None
    manager_id: Optional[int] = None

class EmployeeUpdate(BaseModel):
    first_name: Optional[str] = None
    last_name: Optional[str] = None
    email: Optional[EmailStr] = None
    phone: Optional[str] = None
    date_of_birth: Optional[date] = None
    address: Optional[str] = None
    department_id: Optional[int] = None
    position: Optional[str] = None
    hire_date: Optional[date] = None
    salary: Optional[int] = None
    manager_id: Optional[int] = None
    is_active: Optional[bool] = None

class EmployeeResponse(EmployeeBase):
    id: int
    department_id: Optional[int] = None
    manager_id: Optional[int] = None
    is_active: bool
    created_at: datetime
    updated_at: datetime
    
    # Related data
    department: Optional[DepartmentResponse] = None

    class Config:
        from_attributes = True

class EmployeeProfileBase(BaseModel):
    bio: Optional[str] = None
    skills: Optional[str] = None
    emergency_contact_name: Optional[str] = None
    emergency_contact_phone: Optional[str] = None
    emergency_contact_relationship: Optional[str] = None

class EmployeeProfileCreate(EmployeeProfileBase):
    employee_id: int

class EmployeeProfileUpdate(EmployeeProfileBase):
    pass

class EmployeeProfileResponse(EmployeeProfileBase):
    id: int
    employee_id: int
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True

class EmployeeDetailResponse(EmployeeResponse):
    """Employee with profile details"""
    profile: Optional[EmployeeProfileResponse] = None

class EmployeeListResponse(BaseModel):
    """Paginated employee list"""
    employees: List[EmployeeResponse]
    total: int
    page: int
    page_size: int
    total_pages: int
