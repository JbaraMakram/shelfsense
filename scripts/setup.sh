#!/bin/bash
# setup.sh — Install all dependencies on a fresh Ubuntu 22.04 server
# Run this once on any new server before deploying ShelfSense
# Usage: bash setup.sh

set -e  # stop immediately if any command fails
set -u  # treat undefined variables as errors

echo "================================================"
echo " ShelfSense — Server Setup"
echo " Ubuntu 22.04"
echo "================================================"

# ── System update ─────────────────────────────────
echo "[1/5] Updating system packages..."
sudo apt update && sudo apt upgrade -y
echo "✓ System updated"

# ── Docker ────────────────────────────────────────
echo "[2/5] Installing Docker..."
sudo apt install -y docker.io
sudo systemctl enable docker
sudo systemctl start docker
sudo usermod -aG docker $USER
echo "✓ Docker installed: $(docker --version)"

# ── Docker Compose ────────────────────────────────
echo "[3/5] Installing Docker Compose..."
sudo apt install -y docker-compose
echo "✓ Docker Compose installed: $(docker-compose --version)"

# ── Python ────────────────────────────────────────
echo "[4/5] Installing Python..."
sudo apt install -y python3 python3-pip python3-venv
echo "✓ Python installed: $(python3 --version)"

# ── Git ───────────────────────────────────────────
echo "[5/5] Installing Git..."
sudo apt install -y git
echo "✓ Git installed: $(git --version)"

echo ""
echo "================================================"
echo " Setup complete. Re-login for Docker group"
echo " to take effect, then run deploy.sh"
echo "================================================"
