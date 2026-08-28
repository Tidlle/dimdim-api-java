#!/usr/bin/env bash
# ============================================================
# 06 - ACI da API Java
#
# PRE-REQUISITO: o ACI do banco (repositorio dimdim-db-oracle,
# script 05) precisa estar Running e com o log mostrando
# "DATABASE IS READY TO USE!". O ACI nao tem depends_on.
#
# Uso: ./06_aci-api-java.sh > 06_aci-api-java.log
# ============================================================
set -euo pipefail
source ./00_variaveis.sh

echo ">> Lendo credenciais do ACR..."
ACR_USERNAME=$(az acr credential show --name "${ACR_NAME}" \
  --resource-group "${RESOURCE_GROUP}" --query username --output tsv)
ACR_PASSWORD=$(az acr credential show --name "${ACR_NAME}" \
  --resource-group "${RESOURCE_GROUP}" --query "passwords[0].value" --output tsv)

echo ">> Descobrindo o FQDN do banco (os dois ACIs sao separados)..."
DB_FQDN=$(az container show \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${ACI_DB}" \
  --query ipAddress.fqdn --output tsv 2>/dev/null || true)

if [ -z "${DB_FQDN}" ]; then
  echo ""
  echo "ERRO: nao encontrei o ACI do banco (${ACI_DB})."
  echo "Rode antes o script 05_aci-oracle.sh no repositorio dimdim-db-oracle."
  exit 1
fi

JDBC_URL="jdbc:oracle:thin:@//${DB_FQDN}:${ORACLE_PORT}/${ORACLE_PDB}"
echo ">> String de conexao: ${JDBC_URL}"

echo ">> Criando o ACI ${ACI_APP}..."
az container create \
  --resource-group "${RESOURCE_GROUP}" \
  --name "${ACI_APP}" \
  --location "${LOCATION}" \
  --image "${ACR_SERVER}/${IMG_APP}:${TAG}" \
  --registry-login-server "${ACR_SERVER}" \
  --registry-username "${ACR_USERNAME}" \
  --registry-password "${ACR_PASSWORD}" \
  --os-type Linux \
  --cpu 1 \
  --memory 2 \
  --ports 8080 \
  --ip-address Public \
  --dns-name-label "${DNS_APP}" \
  --restart-policy OnFailure \
  --environment-variables \
      SPRING_DATASOURCE_URL="${JDBC_URL}" \
      SPRING_DATASOURCE_USERNAME="${ORACLE_APP_USER}" \
      TZ="America/Sao_Paulo" \
  --secure-environment-variables \
      SPRING_DATASOURCE_PASSWORD="${APP_DB_PASSWORD}"

APP_FQDN=$(az container show --resource-group "${RESOURCE_GROUP}" --name "${ACI_APP}" \
  --query ipAddress.fqdn --output tsv)

echo ""
echo ">> API publicada em: http://${APP_FQDN}:8080/api/transacoes"
echo ""
echo ">> Prova de que o container NAO roda como root:"
echo "   az container exec -g ${RESOURCE_GROUP} -n ${ACI_APP} --exec-command \"whoami\""
