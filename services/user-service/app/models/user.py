import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), "../../../../"))

from sqlalchemy import Column, String, Boolean, Integer, Date, ForeignKey, Text
from sqlalchemy.orm import relationship
from shared.models.base import BaseModel

class Employee(BaseModel):
    __tablename__ = "employees"
    
    # Personal Information
    employee_id = Column(String(20), unique=True, index=True, nullable=False)
    first_name = Column(String(50), nullable=False)
    last_name = Column(String(50), nullable=False)
    email = Column(String(100), unique=True, index=True, nullable=False)
    phone = Column(String(20))
    date_of_birth = Column(Date)
    address = Column(Text)
    
    # Employment Information
    department_id = Column(Integer, ForeignKey("departments.id"))
    position = Column(String(100))
    hire_date = Column(Date)
    salary = Column(Integer)  # In cents to avoid floating point issues
    is_active = Column(Boolean, default=True)
    
    # Manager relationship
    manager_id = Column(Integer, ForeignKey("employees.id"))
    manager = relationship("Employee", remote_side=[BaseModel.id])
    
    # Department relationship
    department = relationship("Department", back_populates="employees")

class Department(BaseModel):
    __tablename__ = "departments"
    
    name = Column(String(100), unique=True, nullable=False)
    description = Column(Text)
    manager_id = Column(Integer, ForeignKey("employees.id"))
    budget = Column(Integer)  # In cents
    is_active = Column(Boolean, default=True)
    
    # Relationships
    employees = relationship("Employee", back_populates="department")
    manager = relationship("Employee", foreign_keys=[manager_id])

class EmployeeProfile(BaseModel):
    __tablename__ = "employee_profiles"
    
    employee_id = Column(Integer, ForeignKey("employees.id"), unique=True)
    bio = Column(Text)
    skills = Column(Text)  # JSON string or comma-separated
    emergency_contact_name = Column(String(100))
    emergency_contact_phone = Column(String(20))
    emergency_contact_relationship = Column(String(50))
    
    # Relationship
    employee = relationship("Employee")
