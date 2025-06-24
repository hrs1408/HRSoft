import logging
import sys
from typing import Optional
from shared.config.settings import get_settings

settings = get_settings()

def setup_logging(service_name: Optional[str] = None) -> logging.Logger:
    """Setup logging configuration for services"""
    
    # Create logger
    logger_name = service_name or "hrsoft"
    logger = logging.getLogger(logger_name)
    logger.setLevel(getattr(logging, settings.log_level.upper()))
    
    # Remove existing handlers
    for handler in logger.handlers[:]:
        logger.removeHandler(handler)
    
    # Create console handler
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(getattr(logging, settings.log_level.upper()))
    
    # Create formatter
    formatter = logging.Formatter(settings.log_format)
    console_handler.setFormatter(formatter)
    
    # Add handler to logger
    logger.addHandler(console_handler)
    
    return logger

def get_logger(name: str) -> logging.Logger:
    """Get logger instance"""
    return logging.getLogger(name)

# Service-specific loggers
auth_logger = get_logger("auth-service")
user_logger = get_logger("user-service")
api_logger = get_logger("api-gateway")
