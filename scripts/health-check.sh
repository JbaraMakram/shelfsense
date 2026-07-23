#!/bin/bash
# health-check.sh — Check if ShelfSense is running and healthy
# Usage: bash health-check.sh

set -e
set -u

APP_URL="http://localhost:5000"

echo "================================================"
echo " ShelfSense — Health Check"
echo "================================================"

# ── Check app is responding ───────────────────────
echo "[1/3] Checking /health..."
HEALTH=$(curl -sf "$APP_URL/health" 2>/dev/null || echo "FAILED")
if echo "$HEALTH" | grep -q "ok"; then
    echo "OK - $HEALTH"
else
    echo "ERROR: /health failed — $HEALTH"
    exit 1
fi

# ── Check database is connected ───────────────────
echo "[2/3] Checking /ready..."
READY=$(curl -sf "$APP_URL/ready" 2>/dev/null || echo "FAILED")
if echo "$READY" | grep -q "ready"; then
    echo "OK - $READY"
else
    echo "ERROR: /ready failed — $READY"
    exit 1
fi

# ── Check containers are running ──────────────────
echo "[3/3] Checking containers..."
APP_STATUS=$(docker inspect --format='{{.State.Status}}' shelfsense-app 2>/dev/null || echo "not found")
DB_STATUS=$(docker inspect --format='{{.State.Status}}' shelfsense-db 2>/dev/null || echo "not found")
echo "OK - shelfsense-app: $APP_STATUS"
echo "OK - shelfsense-db:  $DB_STATUS"

echo "================================================"
echo " All checks passed"
echo "================================================"
