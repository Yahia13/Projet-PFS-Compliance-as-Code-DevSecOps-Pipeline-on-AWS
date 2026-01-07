#!/bin/bash
set -euo pipefail

IMAGE_NAME="${1:-}"
if [ -z "$IMAGE_NAME" ]; then
  echo "Usage: $0 <image>"
  exit 1
fi

echo "##################################"
echo "# Trivy scan (TAR MODE)           #"
echo "# Image: $IMAGE_NAME"
echo "##################################"

REPORT_DIR="ci/reports/trivy"
mkdir -p "$REPORT_DIR"

# Timestamped run folder (optional but clean)
TS="$(date +%Y%m%d-%H%M%S)"
JSON_REPORT="${REPORT_DIR}/trivy-report-${TS}.json"

# Ensure the image exists locally
docker image inspect "$IMAGE_NAME" >/dev/null 2>&1 || {
  echo "❌ Local image not found: $IMAGE_NAME"
  echo "   Make sure the build stage creates it before scanning."
  exit 1
}

TMP_TAR="/tmp/trivy-image-${TS}.tar"

# Export image to TAR (uses docker CLI only)
docker save "$IMAGE_NAME" -o "$TMP_TAR"

# Scan TAR input (no Docker daemon API needed)
trivy image \
  --input "$TMP_TAR" \
  --severity HIGH,CRITICAL \
  --format json \
  --output "$JSON_REPORT" \
  --exit-code 1 \
  --no-progress

rm -f "$TMP_TAR"

echo "✅ Trivy reports generated:"
