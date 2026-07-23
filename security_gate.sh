#!/bin/bash

set +e

echo "========================================"
echo " DevSecOps Supply Chain Security Gate"
echo "========================================"

AUDIT_FAILED=0

echo ""
echo "[1/5] Running pip-audit..."

pip-audit -r requirements.txt

if [ $? -ne 0 ]; then
    AUDIT_FAILED=1
    echo "Dependency vulnerabilities detected."
else
    echo "No dependency vulnerabilities found."
fi

echo ""
echo "[2/5] Generating CycloneDX SBOM..."

syft . -o cyclonedx-json=sbom.json

echo ""
echo "[3/5] Building Docker image..."

docker build -t supply-chain-demo .

if [ $? -ne 0 ]; then
    echo "Docker build failed."
    exit 1
fi

echo ""
echo "[4/5] Running Trivy JSON Scan..."

trivy image \
    --severity HIGH,CRITICAL \
    --format json \
    -o supply_chain_audit.json \
    supply-chain-demo

echo ""
echo "[5/5] Generating SARIF Report..."

trivy image \
    --severity HIGH,CRITICAL \
    --format sarif \
    -o results.sarif \
    supply-chain-demo

echo ""
echo "========================================"

if [ $AUDIT_FAILED -eq 1 ]; then
    echo "❌ SECURITY GATE FAILED"
    echo "High/Critical vulnerabilities detected."
    exit 1
fi

echo "✅ SECURITY GATE PASSED"

exit 0
