
# Etapa 1: Compilar el microservicio
FROM maven:3.9-eclipse-temurin-17 AS build

WORKDIR /app

# Descargar dependencias
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copiar el codigo fuente y compilar
COPY src ./src
RUN mvn clean package -DskipTests -B

# Etapa 2: Ejecutar el microservicio
FROM eclipse-temurin:17-jre-alpine

# Actualizar paquetes del sistema para aplicar parches de seguridad
RUN apk upgrade --no-cache

WORKDIR /app

# Copiar el JAR generado
COPY --from=build /app/target/*.jar /app/app.jar

# Puerto del microservicio
EXPOSE 8080

# Iniciar la aplicacion
ENTRYPOINT ["java", "-jar", "/app/app.jar"]
