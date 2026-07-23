# Base image — slim keeps the image small, no unnecessary OS packages
FROM python:3.11-slim

# Who maintains this image
LABEL maintainer="ShelfSense DevOps"

# Set working directory inside the container
WORKDIR /app

# Create a non-root user — never run apps as root inside containers
RUN useradd -m -u 1000 appuser

# Copy requirements first — Docker caches this layer separately
# If only app.py changes, Docker reuses the pip install cache = faster builds
COPY app/requirements.txt .

# Install dependencies — no cache keeps the image smaller
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY app/ .

# Give the non-root user ownership of the app files
RUN chown -R appuser:appuser /app

# Switch to non-root user
USER appuser

# Tell Docker this container listens on port 5000
EXPOSE 5000

# Health check — Docker itself will ping /health every 30 seconds
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')"

# Start the app with gunicorn — production-grade server, not Flask dev server
# 4 worker processes to handle multiple requests at once
CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "4", "--timeout", "120", "app:app"]
