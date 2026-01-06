#!/bin/bash
set -euo pipefail

IMAGE_NAME="$1"

echo "##################################"
echo "# Trivy scan (LOCAL image)"
echo "# Image: $IMAGE_NAME"
echo "##################################"

# Ensure Docker is usable
docker info >/dev/null 2>&1 || {
  echo "❌ Docker daemon not accessible by Jenkins"
  exit 3
}

# Ensure image exists locally
docker image inspect "$IMAGE_NAME" >/dev/null 2>&1 || {
  echo "❌ Image not found locally: $IMAGE_NAME"
  exit 4
}

# Force docker backend (NO remote / containerd / podman)
trivy image \
  --image-src docker \
  --scanners vuln \
  --severity HIGH,CRITICAL \
  --exit-code 1 \
  "$IMAGE_NAME"
