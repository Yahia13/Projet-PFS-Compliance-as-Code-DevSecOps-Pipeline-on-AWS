#!/bin/bash
set -e
echo "--- 🛠️ Validation syntaxique de Terraform ---"
cd Infra/Terraform
terraform init -backend=false
terraform validate