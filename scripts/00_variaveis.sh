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
# Banco: MySQL 8.0 (historico: Oracle e PostgreSQL foram
# testados antes e falharam sobre volumes Azure Files/CIFS;
# MySQL e o banco validado neste ambiente).
#
# A senha NAO fica aqui. Exporte antes no seu terminal:
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
export FILE_SHARE="mysql-data-dimdim"

# Instancias de Container
export ACI_DB="${RM}-aci-mysql"
export ACI_APP="${RM}-aci-api-java"
export DNS_DB="${RM}-dimdim-db"
export DNS_APP="${RM}-dimdim-api"

# Imagens
export IMG_DB="${RM}-db-mysql"
export IMG_APP="${RM}-api-java"
export TAG="v1"

# Banco
export DB_NAME="dimdim"
export DB_USER="dimdim"
export DB_PORT="3306"

# ---------- Validacao da senha ----------
if [ -z "${APP_DB_PASSWORD:-}" ]; then
  echo ""
  echo "ERRO: exporte a senha do banco antes de rodar os scripts:"
  echo ""
  echo "  export APP_DB_PASSWORD='SuaSenhaForte#2026'"
  echo ""
  return 1 2>/dev/null || exit 1
fi

echo "Variaveis carregadas."
echo "  RM.................: ${RM}"
echo "  Resource Group.....: ${RESOURCE_GROUP}"
echo "  Regiao.............: ${LOCATION}"
echo "  ACR................: ${ACR_SERVER}"
echo "  Banco..............: MySQL (${ACI_DB})"
