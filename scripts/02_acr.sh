#!/usr/bin/env bash
# ============================================================
# 02 - Azure Container Registry (COMPARTILHADO)
#
# Um unico ACR guarda as duas imagens, em repositorios distintos:
#   <RM>-api-java   (repositorio dimdim-api-java)
#   <RM>-db-mysql   (repositorio dimdim-db-oracle)
#
# Este script existe nos dois repositorios.
# RODE APENAS UMA VEZ, a partir de qualquer um dos dois.
#
# Uso: ./02_acr.sh > 02_acr.log
# ============================================================
set -euo pipefail
source ./00_variaveis.sh

if az acr show --name "${ACR_NAME}" --resource-group "${RESOURCE_GROUP}" >/dev/null 2>&1; then
  echo ">> O ACR ${ACR_NAME} ja existe. Nada a fazer."
else
  echo ">> Criando o ACR ${ACR_NAME}..."
  az acr create \
    --resource-group "${RESOURCE_GROUP}" \
    --name "${ACR_NAME}" \
    --sku Basic \
    --location "${LOCATION}" \
    --public-network-enabled true \
    --admin-enabled true
fi

echo ">> Login Server:"
az acr show --name "${ACR_NAME}" --resource-group "${RESOURCE_GROUP}" \
  --query loginServer --output tsv
