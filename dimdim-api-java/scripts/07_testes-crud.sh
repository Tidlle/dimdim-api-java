#!/usr/bin/env bash
# ============================================================
# 07 - Roteiro de testes do CRUD em nuvem
#
# NAO rode tudo de uma vez durante a gravacao do video.
# Entre uma operacao e outra, rode o SELECT no banco
# (script 08_select-banco.sh, no repositorio do Banco).
# ============================================================
set -euo pipefail
source ./00_variaveis.sh

APP_FQDN=$(az container show --resource-group "${RESOURCE_GROUP}" \
  --name "${ACI_APP}" --query ipAddress.fqdn --output tsv)
API="http://${APP_FQDN}:8080/api/transacoes"

echo "=========================================="
echo " Endpoint: ${API}"
echo "=========================================="

echo ""
echo "--- READ (lista completa) ---"
curl -s -X GET "${API}"

echo ""
echo "--- CREATE ---"
curl -s -X POST "${API}" \
  -H "Content-Type: application/json" \
  -d @../json/01_create.json

echo ""
echo "--- Os comandos abaixo dependem do id retornado acima ---"
echo "curl -X GET    ${API}/6"
echo "curl -X PUT    ${API}/6 -H 'Content-Type: application/json' -d @../json/03_update.json"
echo "curl -X DELETE ${API}/6"
