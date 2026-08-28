#!/usr/bin/env bash
# ============================================================
# 00 - Variaveis compartilhadas
#
# Este arquivo e IDENTICO nos dois repositorios (API e Banco).
# Se alterar em um, replique no outro.
#
# NAO EXECUTE DIRETAMENTE. Ele e carregado pelos demais:
#     source ./00_variaveis.sh
#
# As senhas NAO ficam aqui. Exporte antes no seu terminal:
#     export ORACLE_SYS_PASSWORD='TroqueEssaSenhaSys#2026'
#     export APP_DB_PASSWORD='TroqueEssaSenhaApp#2026'
# ============================================================

set -euo pipefail

# ---------- ALTERE AQUI SE NECESSARIO ----------
export RM="rm562259"                  # RM do representante do grupo
export LOCATION="chilecentral"        # regiao do projeto
# -----------------------------------------------

# Recursos compartilhados pelos dois repositorios
export RESOURCE_GROUP="rg-dimdim-${RM}"
export ACR_NAME="acrdimdim${RM}"
export ACR_SERVER="${ACR_NAME}.azurecr.io"

# Persistencia (usada pelo repositorio do Banco)
export STORAGE_ACCOUNT="stdimdim${RM}"
export FILE_SHARE="oradata-dimdim"

# Instancias de Container
export ACI_DB="${RM}-aci-oracle"
export ACI_APP="${RM}-aci-api-java"
export DNS_DB="${RM}-dimdim-db"
export DNS_APP="${RM}-dimdim-api"

# Imagens
export IMG_DB="${RM}-db-oracle"
export IMG_APP="${RM}-api-java"
export TAG="v1"

# Banco
export ORACLE_APP_USER="dimdim"
export ORACLE_PDB="FREEPDB1"
export ORACLE_PORT="1521"

# ---------- Validacao das senhas ----------
if [ -z "${ORACLE_SYS_PASSWORD:-}" ] || [ -z "${APP_DB_PASSWORD:-}" ]; then
  echo ""
  echo "ERRO: exporte as senhas antes de rodar os scripts:"
  echo ""
  echo "  export ORACLE_SYS_PASSWORD='SuaSenhaSys#2026'"
  echo "  export APP_DB_PASSWORD='SuaSenhaApp#2026'"
  echo ""
  exit 1
fi

echo "Variaveis carregadas."
echo "  RM.................: ${RM}"
echo "  Resource Group.....: ${RESOURCE_GROUP}"
echo "  Regiao.............: ${LOCATION}"
echo "  ACR................: ${ACR_SERVER}"
