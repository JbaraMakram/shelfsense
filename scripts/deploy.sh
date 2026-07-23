#!/bin/bash
# deploy.sh — Pull latest image and restart ShelfSense
# Usage: bash deploy.sh

set -e
set -u

COMPOSE_FILE="$(dirname "$0")/../docker/docker-compose.yml"

echo "================================================"
echo " ShelfSense — Deploy"
echo "================================================"

echo "[1/4] Checking Docker..."
if ! docker info > /dev/null 2>&1; then
    echo "ERROR: Docker is not running."
    exit 1
fi
echo "OK - Docker is running"

echo "[2/4] Pulling latest images..."
docker-compose -f "$COMPOSE_FILE" pull
echo "OK - Images pulled"

echo "[3/4] Restarting services..."
docker-compose -f "$COMPOSE_FILE" up -d --build
echo "OK - Services restarted"

echo "[4/4] Checking app health..."
sleep 5
if curl -sf http://localhost:5000/health > /dev/null; then
    echo "OK - App is healthy"
else
    echo "ERROR: App not responding. Run: docker-compose logs app"
    exit 1
fi

echo "================================================"
echo " Deploy complete. App running at :5000"
echo "================================================"
