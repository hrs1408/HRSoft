from sqlalchemy.orm import Session, joinedload
from sqlalchemy import or_, and_
from typing import Optional
import sys
import os
import math

sys.path.append(os.path.join(os.path.dirname(__file__), "../../../../"))

from shared.utils.exceptions import NotFoundError, DuplicateError
from app.models.user import Employee, Department, EmployeeProfile
from app.schemas.user import (
    EmployeeCreate, EmployeeUpdate, EmployeeResponse, EmployeeDetailResponse,
    EmployeeListResponse, DepartmentCreate, DepartmentUpdate, DepartmentResponse,
    EmployeeProfileCreate, EmployeeProfileUpdate, EmployeeProfileResponse
)

class UserService:
    def __init__(self, db: Session):
        self.db = db

    # Employee methods
    async def create_employee(self, employee_data: EmployeeCreate) -> EmployeeResponse:
        """Create a new employee"""
        # Check if employee_id already exists
        existing_employee = self.db.query(Employee).filter(
            Employee.employee_id == employee_data.employee_id
        ).first()
        if existing_employee:
            raise DuplicateError("Employee ID already exists")
        
        # Check if email already exists
        existing_email = self.db.query(Employee).filter(
            Employee.email == employee_data.email
        ).first()
        if existing_email:
            raise DuplicateError("Email already exists")
        
        # Validate department exists
        if employee_data.department_id:
            department = self.db.query(Department).filter(
                Department.id == employee_data.department_id
            ).first()
            if not department:
                raise NotFoundError("Department not found")
        
        # Validate manager exists
        if employee_data.manager_id:
            manager = self.db.query(Employee).filter(
                Employee.id == employee_data.manager_id
            ).first()
            if not manager:
                raise NotFoundError("Manager not found")
        
        # Create employee
        db_employee = Employee(**employee_data.dict())
        self.db.add(db_employee)
        self.db.commit()
        self.db.refresh(db_employee)
        
        return EmployeeResponse.from_orm(db_employee)

    async def list_employees(
        self,
        page: int = 1,
        page_size: int = 10,
        department_id: Optional[int] = None,
        is_active: Optional[bool] = None,
        search: Optional[str] = None
    ) -> EmployeeListResponse:
        """List employees with pagination and filters"""
        query = self.db.query(Employee).options(joinedload(Employee.department))
        
        # Apply filters
        if department_id:
            query = query.filter(Employee.department_id == department_id)
        
        if is_active is not None:
            query = query.filter(Employee.is_active == is_active)
        
        if search:
            search_filter = or_(
                Employee.first_name.ilike(f"%{search}%"),
                Employee.last_name.ilike(f"%{search}%"),
                Employee.email.ilike(f"%{search}%"),
                Employee.employee_id.ilike(f"%{search}%")
            )
            query = query.filter(search_filter)
        
        # Get total count
        total = query.count()
        
        # Apply pagination
        offset = (page - 1) * page_size
        employees = query.offset(offset).limit(page_size).all()
        
        total_pages = math.ceil(total / page_size)
        
        return EmployeeListResponse(
            employees=[EmployeeResponse.from_orm(emp) for emp in employees],
            total=total,
            page=page,
            page_size=page_size,
            total_pages=total_pages
        )

    async def get_employee_detail(self, employee_id: int) -> EmployeeDetailResponse:
        """Get employee with profile details"""
        employee = self.db.query(Employee).options(
            joinedload(Employee.department)
        ).filter(Employee.id == employee_id).first()
        
        if not employee:
            raise NotFoundError("Employee not found")
        
        # Get profile
        profile = self.db.query(EmployeeProfile).filter(
            EmployeeProfile.employee_id == employee_id
        ).first()
        
        employee_dict = EmployeeResponse.from_orm(employee).dict()
        employee_dict["profile"] = EmployeeProfileResponse.from_orm(profile) if profile else None
        
        return EmployeeDetailResponse(**employee_dict)

    async def update_employee(self, employee_id: int, employee_data: EmployeeUpdate) -> EmployeeResponse:
        """Update employee"""
        employee = self.db.query(Employee).filter(Employee.id == employee_id).first()
        if not employee:
            raise NotFoundError("Employee not found")
        
        # Check email uniqueness if email is being updated
        if employee_data.email and employee_data.email != employee.email:
            existing_email = self.db.query(Employee).filter(
                Employee.email == employee_data.email,
                Employee.id != employee_id
            ).first()
            if existing_email:
                raise DuplicateError("Email already exists")
        
        # Validate department exists if being updated
        if employee_data.department_id:
            department = self.db.query(Department).filter(
                Department.id == employee_data.department_id
            ).first()
            if not department:
                raise NotFoundError("Department not found")
        
        # Update fields
        update_data = employee_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(employee, field, value)
        
        self.db.commit()
        self.db.refresh(employee)
        
        return EmployeeResponse.from_orm(employee)

    async def delete_employee(self, employee_id: int):
        """Soft delete employee"""
        employee = self.db.query(Employee).filter(Employee.id == employee_id).first()
        if not employee:
            raise NotFoundError("Employee not found")
        
        employee.is_active = False
        self.db.commit()

    # Employee Profile methods
    async def create_employee_profile(self, profile_data: EmployeeProfileCreate) -> EmployeeProfileResponse:
        """Create employee profile"""
        # Check if employee exists
        employee = self.db.query(Employee).filter(Employee.id == profile_data.employee_id).first()
        if not employee:
            raise NotFoundError("Employee not found")
        
        # Check if profile already exists
        existing_profile = self.db.query(EmployeeProfile).filter(
            EmployeeProfile.employee_id == profile_data.employee_id
        ).first()
        if existing_profile:
            raise DuplicateError("Employee profile already exists")
        
        db_profile = EmployeeProfile(**profile_data.dict())
        self.db.add(db_profile)
        self.db.commit()
        self.db.refresh(db_profile)
        
        return EmployeeProfileResponse.from_orm(db_profile)

    async def update_employee_profile(self, employee_id: int, profile_data: EmployeeProfileUpdate) -> EmployeeProfileResponse:
        """Update employee profile"""
        profile = self.db.query(EmployeeProfile).filter(
            EmployeeProfile.employee_id == employee_id
        ).first()
        if not profile:
            raise NotFoundError("Employee profile not found")
        
        # Update fields
        update_data = profile_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(profile, field, value)
        
        self.db.commit()
        self.db.refresh(profile)
        
        return EmployeeProfileResponse.from_orm(profile)

    # Department methods
    async def create_department(self, department_data: DepartmentCreate) -> DepartmentResponse:
        """Create a new department"""
        # Check if department name already exists
        existing_dept = self.db.query(Department).filter(
            Department.name == department_data.name
        ).first()
        if existing_dept:
            raise DuplicateError("Department name already exists")
        
        db_department = Department(**department_data.dict())
        self.db.add(db_department)
        self.db.commit()
        self.db.refresh(db_department)
        
        return DepartmentResponse.from_orm(db_department)

    async def list_departments(self, is_active: Optional[bool] = None) -> list[DepartmentResponse]:
        """List all departments"""
        query = self.db.query(Department)
        
        if is_active is not None:
            query = query.filter(Department.is_active == is_active)
        
        departments = query.all()
        return [DepartmentResponse.from_orm(dept) for dept in departments]

    async def get_department(self, department_id: int) -> DepartmentResponse:
        """Get department by ID"""
        department = self.db.query(Department).filter(Department.id == department_id).first()
        if not department:
            raise NotFoundError("Department not found")
        
        return DepartmentResponse.from_orm(department)

    async def update_department(self, department_id: int, department_data: DepartmentUpdate) -> DepartmentResponse:
        """Update department"""
        department = self.db.query(Department).filter(Department.id == department_id).first()
        if not department:
            raise NotFoundError("Department not found")
        
        # Check name uniqueness if name is being updated
        if department_data.name and department_data.name != department.name:
            existing_dept = self.db.query(Department).filter(
                Department.name == department_data.name,
                Department.id != department_id
            ).first()
            if existing_dept:
                raise DuplicateError("Department name already exists")
        
        # Validate manager exists if being updated
        if department_data.manager_id:
            manager = self.db.query(Employee).filter(
                Employee.id == department_data.manager_id
            ).first()
            if not manager:
                raise NotFoundError("Manager not found")
        
        # Update fields
        update_data = department_data.dict(exclude_unset=True)
        for field, value in update_data.items():
            setattr(department, field, value)
        
        self.db.commit()
        self.db.refresh(department)
        
        return DepartmentResponse.from_orm(department)
