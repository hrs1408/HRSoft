import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), "../../../"))

from shared.database.base import Base, engine

def create_tables():
    """Create all tables for user service"""
    Base.metadata.create_all(bind=engine)

def drop_tables():
    """Drop all tables for user service"""
    Base.metadata.drop_all(bind=engine)
