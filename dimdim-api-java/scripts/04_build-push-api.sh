#!/usr/bin/env bash
# ============================================================
# 04 - Build e push da imagem da API
#
# O contexto do build e a RAIZ deste repositorio.
# Rode a partir da pasta scripts/.
#
# Uso: ./04_build-push-api.sh > 04_build-push-api.log
# ============================================================
set -euo pipefail
source ./00_variaveis.sh

cd ..

echo ">> Autenticando o Docker no ACR..."
az acr login --name "${ACR_NAME}"

echo ">> Build da imagem da API Java..."
docker build -f Dockerfile -t "${IMG_APP}:${TAG}" .

echo ">> Conferindo que a imagem NAO roda como root..."
docker run --rm --entrypoint whoami "${IMG_APP}:${TAG}"

echo ">> Aplicando a tag do registro..."
docker tag "${IMG_APP}:${TAG}" "${ACR_SERVER}/${IMG_APP}:${TAG}"

echo ">> Push para o ACR..."
docker push "${ACR_SERVER}/${IMG_APP}:${TAG}"

echo ">> Tags publicadas:"
az acr repository show-tags --name "${ACR_NAME}" --repository "${IMG_APP}" -o table
