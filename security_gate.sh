#!/bin/bash

set -e

export PIPAPI_PYTHON_LOCATION="$(pwd)/venv/bin/python"


echo "========================================"
echo " DevSecOps Supply Chain Security Gate"
echo "========================================"

echo
echo "[1/3] Running pip-audit..."
python3 -m pip_audit

echo
echo "[2/3] Building Docker Image..."
docker build -t supply-chain-demo .

echo
echo "[3/3] Running Trivy Scan..."
trivy image \
  --severity HIGH,CRITICAL \
  --ignore-unfixed \
  --exit-code 0 \
  --format table \
  --output trivy-report.txt \
  supply-chain-demo

echo
echo "========================================"
echo "✅ SECURITY GATE PASSED"
echo "========================================"
