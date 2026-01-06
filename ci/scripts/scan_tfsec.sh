#!/bin/bash
set -e

echo "###############################"
echo "# Lancement de TFSEC (IaC)    #"
echo "###############################"

TF_DIR="Infra/Terraform"
REPORT_DIR="ci/reports/tfsec"
REPORT_FILE="${REPORT_DIR}/tfsec-report.json"

mkdir -p "$REPORT_DIR"

# JSON output to file
tfsec "$TF_DIR" --format json > "$REPORT_FILE" || true