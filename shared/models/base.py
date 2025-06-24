from sqlalchemy import Column, Integer, DateTime, String
from sqlalchemy.sql import func
from shared.database.base import Base

class TimestampMixin:
    """Mixin to add timestamp fields to models"""
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now(), server_default=func.now())

class BaseModel(Base, TimestampMixin):
    """Base model with common fields"""
    __abstract__ = True
    
    id = Column(Integer, primary_key=True, index=True)
    
    def to_dict(self):
        """Convert model to dictionary"""
        return {column.name: getattr(self, column.name) for column in self.__table__.columns}
