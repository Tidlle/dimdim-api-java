# dimdim-api-java

API REST de transações bancárias — **Java 17 / Spring Boot 3.3** em container, publicada no Azure Container Registry e executada em um Azure Container Instance na região **Chile Central**.

Checkpoint 1 · 2º Semestre · DevOps Tools & Cloud Computing · FIAP

> **Repositório do banco de dados:** `dimdim-db-mysql` — https://github.com/Tidlle/dimdim-db-mysql
> Os dois repositórios compartilham o mesmo Grupo de Recursos e o mesmo ACR.

## Equipe

| RM | Nome completo |
|----|---------------|
| RM562259 | *(representante do grupo)* |
| RM562707 | João Victor Alcântara |

---

## Como os dois repositórios se relacionam

```
dimdim-db-mysql                         dimdim-api-java  (este)
      │                                        │
      │ 04_build-push-db.sh                    │ 04_build-push-api.sh
      ▼                                        ▼
      └──────────►  ACR: acrdimdimrm562259  ◄──┘
                    ├── rm562259-db-mysql:v1
                    └── rm562259-api-java:v1
      │                                        │
      │ 05_aci-mysql.sh                        │ 06_aci-api-java.sh
      ▼                                        ▼
ACI rm562259-aci-mysql   ◄── JDBC ────  ACI rm562259-aci-api-java
porta 3306                  via FQDN        porta 8080
      │
      ▼
Azure Files (persistência em /var/lib/mysql)
```

Como os dois ACIs são separados, a API alcança o banco pelo **FQDN público** do ACI do MySQL, nunca por `localhost`. O script `06` descobre esse FQDN automaticamente e monta a URL JDBC.

---

## Ordem de execução

A ordem atravessa os dois repositórios. Os scripts `00`, `01`, `02` e `99` são **idênticos** nos dois — rode `01` e `02` uma única vez, de qualquer um dos lados.

| # | Repositório | Script | O que faz |
|---|---|---|---|
| 1 | qualquer um | `01_resource-group.sh` | Grupo de Recursos |
| 2 | qualquer um | `02_acr.sh` | Container Registry |
| 3 | db-mysql | `03_storage-account.sh` | Conta de Armazenamento + File Share |
| 4 | db-mysql | `04_build-push-db.sh` | Build e push da imagem do banco |
| 5 | db-mysql | `05_aci-mysql.sh` | ACI do banco (espere ficar pronto) |
| 6 | **api-java** | `04_build-push-api.sh` | Build e push da imagem da API |
| 7 | **api-java** | `06_aci-api-java.sh` | ACI da API |
| 8 | **api-java** | `07_testes-crud.sh` | Testes do CRUD |
| 9 | db-mysql | `08_select-banco.sh` | Evidência no banco |

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
└── docs/folha-de-rosto-modelo.md
```

O único `application.properties` que vale é o de `src/main/resources/` — é ele que o Maven empacota no JAR.

---

## Container sem privilégio administrativo

Requisito do checkpoint. O estágio de runtime do Dockerfile cria um usuário comum e troca para ele antes do `ENTRYPOINT`:

```dockerfile
RUN groupadd -g 10001 appgroup \
 && useradd -u 10001 -g appgroup -m -s /bin/bash appuser
USER 10001:10001
EXPOSE 8080
```

A porta 8080 foi escolhida por estar acima de 1024 — usuário sem privilégio não pode abrir portas baixas.

Verificação local e em nuvem:

```bash
docker run --rm --entrypoint whoami rm562259-api-java:v1        # => appuser

source scripts/00_variaveis.sh
az container exec -g $RESOURCE_GROUP -n $ACI_APP --exec-command "whoami"   # => appuser
az container exec -g $RESOURCE_GROUP -n $ACI_APP --exec-command "id"       # => uid=10001
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

Exporte a senha na sessão — ela nunca entra no repositório:

```bash
export APP_DB_PASSWORD='TroqueEssaSenhaApp#2026'
```

Precisa ser a mesma senha usada ao criar o ACI do banco.

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

Só depois que o banco estiver Running e com `ready for connections` no log:

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

Procure por `Started DimDimApplication` no log.

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

Payloads de teste versionados em [`json/`](json/): `01_create.json`, `02_read.json`, `03_update.json`, `04_delete.json` e `05_create_invalido.json`.

---

## Configuração da aplicação

Nenhum dado sensível fica no código. Tudo vem de variável de ambiente, injetada pelo ACI:

| Variável | Origem |
|---|---|
| `SPRING_DATASOURCE_URL` | montada pelo script `06` com o FQDN do ACI do banco |
| `SPRING_DATASOURCE_USERNAME` | `dimdim` |
| `SPRING_DATASOURCE_PASSWORD` | `--secure-environment-variables` (não aparece em `az container show`) |

Driver: `com.mysql.cj.jdbc.Driver`, via `mysql-connector-j`.

A aplicação não cria nem altera schema (`spring.jpa.hibernate.ddl-auto=none`). O DDL vive no repositório `dimdim-db-mysql`.

---

## Teste local

Clone os dois repositórios lado a lado e construa as duas imagens:

```bash
cd ../dimdim-db-mysql && docker build -t rm562259-db-mysql:v1 .
cd ../dimdim-api-java && docker build -t rm562259-api-java:v1 .
```

Suba o banco:

```bash
export APP_DB_PASSWORD='TroqueEssaSenhaApp#2026'

docker network create dimdim-net

docker run -d --name dimdim-mysql --network dimdim-net -p 3306:3306 \
  -e MYSQL_DATABASE=dimdim \
  -e MYSQL_USER=dimdim \
  -e MYSQL_PASSWORD="$APP_DB_PASSWORD" \
  -e MYSQL_ROOT_PASSWORD="$APP_DB_PASSWORD" \
  rm562259-db-mysql:v1

docker logs -f dimdim-mysql     # aguarde "ready for connections"
```

Suba a API:

```bash
docker run -d --name dimdim-api --network dimdim-net -p 8080:8080 \
  -e SPRING_DATASOURCE_URL="jdbc:mysql://dimdim-mysql:3306/dimdim?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=America/Sao_Paulo" \
  -e SPRING_DATASOURCE_USERNAME=dimdim \
  -e SPRING_DATASOURCE_PASSWORD="$APP_DB_PASSWORD" \
  rm562259-api-java:v1

curl http://localhost:8080/api/transacoes
```

Limpeza do ambiente local:

```bash
docker rm -f dimdim-api dimdim-mysql
docker network rm dimdim-net
```

> O teste local serve apenas para validar as imagens antes do push. A entrega é a solução em nuvem.

---

## Limpeza

```bash
cd scripts
./99_cleanup.sh     # pede confirmação: digite SIM
```

Apaga o Grupo de Recursos inteiro: ACR, os dois ACIs, a Conta de Armazenamento e os dados.
