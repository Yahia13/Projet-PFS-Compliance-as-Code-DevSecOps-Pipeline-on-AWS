#!/bin/bash
# On vérifie si la variable BUCKET_NAME est bien fournie par Jenkins
if [ -z "$BUCKET_NAME" ]; then
    echo "Erreur : La variable BUCKET_NAME n'est pas définie."
    exit 1
fi

TIMESTAMP=$(date +%Y%m%d-%H%M)
echo "=== Archivage des rapports vers le bucket S3 : $BUCKET_NAME ==="

# Copie récursive des rapports
aws s3 cp ci/reports/ s3://$BUCKET_NAME/reports-$TIMESTAMP/ --recursive