#!/bin/bash
echo "####################################"
echo "# Lancement de kube-score (K8s)    #"
echo "####################################"

# On génère le YAML à partir de Helm et on le passe à kube-score
helm template my-release ./helm/app | kube-score score - \
    --output-format human \
    --ignore-test pod-networkpolicy # On ignore si on n'a pas encore fait les network policies