
# Etapa 1: Compilar el microservicio
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

# Descargar dependencias y aprovechar la cache
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copiar el codigo fuente y compilar
COPY src ./src
RUN mvn clean package -DskipTests -B

# Etapa 2: Ejecutar el microservicio
FROM eclipse-temurin:17-jre

WORKDIR /app

# Copiar el JAR generado
COPY --from=build /app/target/*.jar /app/app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "/app/app.jar"]
