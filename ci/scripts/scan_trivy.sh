#!/bin/bash
IMAGE_NAME=$1

echo "##################################"
echo "# Scan Trivy de l'image : $IMAGE_NAME"
echo "##################################"

# --exit-code 1 : TRÈS IMPORTANT. Si Trivy trouve une faille critique, 
# il renvoie l'erreur 1, ce qui stoppe immédiatement Jenkins.
trivy image --severity HIGH,CRITICAL --exit-code 1 "$IMAGE_NAME"