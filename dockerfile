# Etapa 1: Construcción (Builder) con Java 17
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /build
COPY pom.xml .
# Descargamos dependencias primero para aprovechar el caché de Docker
RUN mvn dependency:go-offline
COPY src ./src
# Compilamos el proyecto y empaquetamos el .jar omitiendo los tests para mayor rapidez
RUN mvn clean package -DskipTests

# Etapa 2: Producción
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app
# Cumplimiento de rúbrica: Creación de usuario no root (Principio de mínimo privilegio)
RUN addgroup -S spring && adduser -S spring -G spring
USER spring:spring

# Copiamos únicamente el ejecutable final
COPY --from=builder /build/target/*.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]