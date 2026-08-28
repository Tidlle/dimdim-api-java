#!/usr/bin/env bash
# ============================================================
# 01 - Grupo de Recursos (COMPARTILHADO)
#
# Este script existe nos dois repositorios porque o Grupo de
# Recursos e usado pela API e pelo Banco.
# RODE APENAS UMA VEZ, a partir de qualquer um dos dois.
#
# Uso: ./01_resource-group.sh > 01_resource-group.log
# ============================================================
set -euo pipefail
source ./00_variaveis.sh

echo ">> Conferindo se a regiao ${LOCATION} esta liberada na assinatura..."
az account list-locations --query "[?name=='${LOCATION}'].{Nome:name, Exibicao:displayName}" -o table

echo ">> Registrando os providers necessarios..."
az provider register --namespace Microsoft.ContainerRegistry
az provider register --namespace Microsoft.ContainerInstance
az provider register --namespace Microsoft.Storage

echo ">> Criando o Grupo de Recursos ${RESOURCE_GROUP}..."
az group create \
  --name "${RESOURCE_GROUP}" \
  --location "${LOCATION}" \
  --tags projeto=dimdim disciplina=devops-cloud rm="${RM}"

echo ">> Grupo de Recursos criado."
