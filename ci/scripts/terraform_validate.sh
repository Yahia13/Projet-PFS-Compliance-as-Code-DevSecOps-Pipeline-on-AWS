#!/bin/bash
set -e
echo "--- 🛠️ Validation syntaxique de Terraform ---"
cd infra/terraform
terraform init -backend=false
terraform validate