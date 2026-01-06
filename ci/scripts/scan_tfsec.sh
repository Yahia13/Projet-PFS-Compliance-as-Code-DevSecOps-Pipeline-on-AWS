#!/bin/bash
echo "###############################"
echo "# Lancement de TFSEC (IaC)    #"
echo "###############################"

# On scanne le dossier infra/terraform
# --format json permet de générer un rapport machine-readable
# --out permet de sauvegarder le résultat
tfsec ./Infra/Terraform --format table --out ../reports/tfsec/tfsec-report.json

# Note : tfsec renvoie un code erreur si des problèmes "HIGH" sont trouvés.