#!/usr/bin/env bash
# ============================================================
# 99 - Limpeza do laboratorio (COMPARTILHADO)
#
# Apaga TUDO: ACR, os dois ACIs, Conta de Armazenamento e os dados.
# Rode apenas depois da entrega concluida.
# ============================================================
set -euo pipefail
source ./00_variaveis.sh

read -r -p "Confirma apagar o grupo ${RESOURCE_GROUP} e TODOS os recursos? (digite SIM): " RESPOSTA
if [ "${RESPOSTA}" != "SIM" ]; then
  echo "Cancelado."
  exit 0
fi

az group delete --name "${RESOURCE_GROUP}" --yes --no-wait
echo "Exclusao disparada em segundo plano."
