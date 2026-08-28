# dimdim-api-java

API REST de transações bancárias — **Java 17 / Spring Boot 3.3** em container, publicada no Azure Container Registry e executada em um Azure Container Instance na região **Chile Central**.

Checkpoint 1 · 2º Semestre · DevOps Tools & Cloud Computing · FIAP

> **Repositório do banco de dados:** `dimdim-db-oracle` — https://github.com/<usuario>/dimdim-db-oracle
> Os dois repositórios compartilham o mesmo Grupo de Recursos e o mesmo ACR.

---

## Como os dois repositórios se relacionam

```
dimdim-db-oracle                        dimdim-api-java  (este)
      │                                        │
      │ 04_build-push-db.sh                    │ 04_build-push-api.sh
      ▼                                        ▼
      └──────────►  ACR: acrdimdimrm562259  ◄──┘
                    ├── rm562259-db-oracle:v1
                    └── rm562259-api-java:v1
      │                                        │
      │ 05_aci-oracle.sh                       │ 06_aci-api-java.sh
      ▼                                        ▼
ACI rm562259-aci-oracle  ◄── JDBC ────  ACI rm562259-aci-api-java
porta 1521                  via FQDN        porta 8080
      │
      ▼
Azure Files (persistência)
```

Como os dois ACIs são separados, a API alcança o banco pelo **FQDN público** do ACI do Oracle, nunca por `localhost`. O script `06` descobre esse FQDN automaticamente.

---

## Ordem de execução

A ordem atravessa os dois repositórios. Os scripts `00`, `01`, `02` e `99` são **idênticos** nos dois — rode `01` e `02` uma única vez, de qualquer um dos lados.

| # | Repositório | Script | O que faz |
|---|---|---|---|
| 1 | qualquer um | `01_resource-group.sh` | Grupo de Recursos |
| 2 | qualquer um | `02_acr.sh` | Container Registry |
| 3 | db-oracle | `03_storage-account.sh` | Conta de Armazenamento + File Share |
| 4 | db-oracle | `04_build-push-db.sh` | Build e push da imagem do banco |
| 5 | db-oracle | `05_aci-oracle.sh` | ACI do banco (espere ficar pronto) |
| 6 | **api-java** | `04_build-push-api.sh` | Build e push da imagem da API |
| 7 | **api-java** | `06_aci-api-java.sh` | ACI da API |
| 8 | **api-java** | `07_testes-crud.sh` | Testes do CRUD |
| 9 | db-oracle | `08_select-banco.sh` | Evidência no banco |

---

## Estrutura

```
.
├── Dockerfile                  multi-stage, roda como appuser (uid 10001)
├── pom.xml
├── src/main/
│   ├── java/br/com/fiap/dimdim/
│   │   ├── DimDimApplication.java
│   │   ├── controller/         TransacaoController, HealthController
│   │   ├── dto/                TransacaoRequest, TransacaoResponse
│   │   ├── exception/          GlobalExceptionHandler
│   │   ├── model/              Transacao
│   │   ├── repository/         TransacaoRepository
│   │   └── service/            TransacaoService
│   └── resources/application.properties
├── json/                       payloads de teste
├── scripts/
│   ├── 00_variaveis.sh         compartilhado
│   ├── 01_resource-group.sh    compartilhado
│   ├── 02_acr.sh               compartilhado
│   ├── 04_build-push-api.sh
│   ├── 06_aci-api-java.sh
│   ├── 07_testes-crud.sh
│   └── 99_cleanup.sh           compartilhado
├── docker-compose.local.yml
└── docs/folha-de-rosto-modelo.md
```

---

## Pré-requisitos

```bash
az version
docker --version
az login
az account set --subscription "<sua assinatura>"
```

O Cloud Shell **não** serve para o build: não tem o daemon do Docker. Use a VM Linux da disciplina.

Exporte as senhas na sessão — elas nunca entram no repositório:

```bash
export ORACLE_SYS_PASSWORD='TroqueEssaSenhaSys#2026'
export APP_DB_PASSWORD='TroqueEssaSenhaApp#2026'
```

---

## How To — build e push

```bash
cd scripts
./04_build-push-api.sh > 04_build-push-api.log
```

Comandos equivalentes, se precisar rodar na mão a partir da raiz do repositório:

```bash
az acr login --name acrdimdimrm562259

docker build -f Dockerfile -t rm562259-api-java:v1 .

# prova de que a aplicação não roda como root
docker run --rm --entrypoint whoami rm562259-api-java:v1     # => appuser

docker tag rm562259-api-java:v1 acrdimdimrm562259.azurecr.io/rm562259-api-java:v1
docker push acrdimdimrm562259.azurecr.io/rm562259-api-java:v1

az acr repository show-tags --name acrdimdimrm562259 --repository rm562259-api-java -o table
```

---

## How To — publicar o ACI

Só depois que o banco estiver Running:

```bash
cd scripts
./06_aci-api-java.sh > 06_aci-api-java.log
```

Verificações:

```bash
source ./00_variaveis.sh
az container list -g $RESOURCE_GROUP -o table
az container logs -g $RESOURCE_GROUP -n $ACI_APP
az container exec  -g $RESOURCE_GROUP -n $ACI_APP --exec-command "whoami"
```

---

## Endpoints

Base: `http://<FQDN-DA-API>:8080/api/transacoes`

| Operação | Método | Rota | Corpo | Resposta |
|---|---|---|---|---|
| READ (todas) | GET | `/api/transacoes` | — | 200 |
| READ (filtro) | GET | `/api/transacoes?tipo=DEBITO` | — | 200 |
| READ (por id) | GET | `/api/transacoes/{id}` | — | 200 / 404 |
| CREATE | POST | `/api/transacoes` | `json/01_create.json` | 201 |
| UPDATE | PUT | `/api/transacoes/{id}` | `json/03_update.json` | 200 / 404 |
| DELETE | DELETE | `/api/transacoes/{id}` | — | 204 / 404 |

```bash
source scripts/00_variaveis.sh
APP=$(az container show -g $RESOURCE_GROUP -n $ACI_APP --query ipAddress.fqdn -o tsv)

curl -X GET "http://$APP:8080/api/transacoes"

curl -X POST "http://$APP:8080/api/transacoes" \
  -H "Content-Type: application/json" -d @json/01_create.json

curl -X PUT "http://$APP:8080/api/transacoes/6" \
  -H "Content-Type: application/json" -d @json/03_update.json

curl -X DELETE "http://$APP:8080/api/transacoes/6"
```

---

## Configuração da aplicação

Nenhum dado sensível fica no código. Tudo vem de variável de ambiente, injetada pelo ACI:

| Variável | Origem |
|---|---|
| `SPRING_DATASOURCE_URL` | montada pelo script `06` com o FQDN do ACI do banco |
| `SPRING_DATASOURCE_USERNAME` | `dimdim` |
| `SPRING_DATASOURCE_PASSWORD` | `--secure-environment-variables` (não aparece em `az container show`) |

A aplicação não cria nem altera schema (`spring.jpa.hibernate.ddl-auto=none`). O DDL vive no repositório `dimdim-db-oracle`.

---

## Teste local

```bash
cd ../dimdim-db-oracle && docker build -t rm562259-db-oracle:v1 .
cd ../dimdim-api-java  && docker build -t rm562259-api-java:v1  .
docker compose -f docker-compose.local.yml up
curl http://localhost:8080/api/transacoes
```

Clone os dois repositórios lado a lado para que os caminhos relativos funcionem.
