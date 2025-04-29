# Dockerfile for a Python application
# Use the official Python image from Docker Hub
FROM python:3.11-slim

# Set working directory
WORKDIR /app

# Copy the requirements file
COPY requirements.txt .

# Install dependencies
# Use --no-cache-dir to avoid caching the packages
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . .

CMD ["uvicorn","app.main:app","--host","0.0.0.0","--port","8800"]