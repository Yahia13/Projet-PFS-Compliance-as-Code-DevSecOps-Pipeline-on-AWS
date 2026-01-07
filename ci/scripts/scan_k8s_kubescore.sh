#!/bin/bash
set -euo pipefail

echo "####################################"
echo "# Lancement de kube-score (K8s)    #"
echo "####################################"

CHART_DIR="./helm/app"              # adjust if needed
RENDERED="ci/reports/kube-score/rendered.yaml"
REPORT="ci/reports/kube-score/kube-score.txt"

mkdir -p ci/reports/kube-score

# Render chart into real YAML first
helm template microservice-app "$CHART_DIR" > "$RENDERED"

# Run kube-score on rendered output
kube-score score "$RENDERED" > "$REPORT"

echo "✅ kube-score report saved to $REPORT"
