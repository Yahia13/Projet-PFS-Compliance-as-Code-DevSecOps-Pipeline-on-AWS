#!/bin/bash

# Arrêter le script immédiatement en cas d'erreur
set -e

# Récupération de l'URI complète de l'image passée par Jenkins
FULL_IMAGE_URI=$1

if [ -z "$FULL_IMAGE_URI" ]; then
    echo "❌ Erreur : L'URI de l'image est manquante."
    exit 1
fi

echo "##################################################"
echo "🚀 DEBUT DU PROCESSUS DOCKER POUR : $FULL_IMAGE_URI"
echo "##################################################"

# 1. Construction de l'image
echo "📦 1/2 Construction de l'image Docker..."
# On se place dans le dossier de l'application
docker build -t "$FULL_IMAGE_URI" ./app/microservice

# Note : On ne fait PAS le push ici ! 
# Pourquoi ? Parce que le Jenkinsfile veut d'abord lancer TRIVY.
# Si Trivy trouve une faille, on ne veut pas que l'image soit déjà sur ECR.

echo "✅ Image construite localement avec succès."
echo "##################################################"