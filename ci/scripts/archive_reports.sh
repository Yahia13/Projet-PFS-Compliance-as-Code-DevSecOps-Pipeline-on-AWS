#!/bin/bash
# Remplace par ton nom de bucket défini dans Terraform
S3_BUCKET="pfs-security-reports-${AWS_ACCOUNT_ID}"

echo "--- 📦 Archivage des rapports sur S3 ---"
if [ -d "ci/reports" ]; then
    aws s3 cp ci/reports/ s3://${S3_BUCKET}/build-${BUILD_ID}/ --recursive
else
    echo "⚠️ Aucun rapport trouvé à archiver."
fi
