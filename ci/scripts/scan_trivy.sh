#!/bin/bash
set -euo pipefail
IMAGE_NAME="${1:-}"

if [ -z "$IMAGE_NAME" ]; then
  echo "Usage: $0 <image>"
  exit 1
fi

# ✅ If Jenkins sets DOCKER_API_VERSION=1.43, Trivy will fail.
unset DOCKER_API_VERSION

echo "##################################"
echo "# Scan Trivy de l'image : $IMAGE_NAME"
echo "##################################"

trivy image --severity HIGH,CRITICAL --exit-code 1 --no-progress "$IMAGE_NAME"
