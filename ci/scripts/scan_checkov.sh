#!/bin/bash
echo "###############################"
echo "# Lancement de Checkov (IaC)  #"
echo "###############################"

checkov -d ./Infra/Terraform \
    --output cli \
    --output json --soft-fail \
    > ./ci/reports/checkov/checkov-report.json

# On utilise --soft-fail ici pour ne pas bloquer la pipeline 
# pendant que vous ajustez vos règles Terraform au début.