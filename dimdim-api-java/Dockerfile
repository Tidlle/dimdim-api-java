# ============================================================
# Dockerfile da API Java (DimDim)
# Multi-stage: compila com Maven e roda apenas o JRE.
# REQUISITO DO CHECKPOINT: o container NAO roda como root.
# ============================================================

# ---------- Estagio 1: build ----------
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /build

# Cache de dependencias: copia o pom primeiro
COPY pom.xml .
RUN mvn -B -q dependency:go-offline

COPY src ./src
RUN mvn -B -q clean package -DskipTests


# ---------- Estagio 2: runtime ----------
FROM eclipse-temurin:17-jre-jammy

# Cria um usuario sem privilegios administrativos
RUN groupadd -g 10001 appgroup \
 && useradd -u 10001 -g appgroup -m -s /bin/bash appuser

WORKDIR /app

COPY --from=build /build/target/*.jar /app/app.jar
RUN chown -R appuser:appgroup /app

# A partir daqui, tudo roda como appuser (uid 10001), nunca root
USER 10001:10001

# Porta acima de 1024: usuario sem privilegio nao pode abrir porta baixa
EXPOSE 8080

ENTRYPOINT ["java", "-XX:MaxRAMPercentage=75.0", "-jar", "/app/app.jar"]
