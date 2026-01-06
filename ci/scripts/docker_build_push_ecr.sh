#!/bin/bash
set -euo pipefail

# FULL ECR URI passed by Jenkins
FULL_IMAGE_URI="$1"

if [[ -z "$FULL_IMAGE_URI" ]]; then
  echo "❌ Missing ECR image URI"
  exit 1
fi

# Local image (ALWAYS local, never remote)
LOCAL_IMAGE="pfs-compliance-local:latest"

echo "##################################################"
echo "🚀 Docker build"
echo "Local image : $LOCAL_IMAGE"
echo "Target ECR  : $FULL_IMAGE_URI"
echo "##################################################"

echo "📦 Building local image..."
docker build -t "$LOCAL_IMAGE" ./app/microservice

echo "✅ Local image built successfully"

# Expose local image name for Jenkins
echo "$LOCAL_IMAGE" > .local_image_name
