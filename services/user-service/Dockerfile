FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy shared modules
COPY ../../../shared /app/shared

# Copy application code
COPY ./app /app/app

# Expose port
EXPOSE 8000

# Set environment variables
ENV PYTHONPATH=/app
ENV SERVICE_NAME=user-service

# Run the application
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
