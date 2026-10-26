# BDGET — Proyecto DevOps

## 1. Descripción del proyecto

BDGET es una aplicación REST desarrollada con Java 17 y Spring Boot 3.3.7 para gestionar estudiantes mediante operaciones CRUD.

El proyecto utiliza una arquitectura por capas: controlador, servicio, repositorio, entidad y DTO.

Además de sus funcionalidades, implementa prácticas DevOps mediante control de versiones, integración continua, pruebas automatizadas, análisis de calidad, análisis de vulnerabilidades y publicación de imágenes Docker.

## 2. Tecnologías utilizadas

| Tecnología | Función |
|---|---|
| Java 17 | Lenguaje de programación |
| Spring Boot 3.3.7 | Desarrollo de la API REST |
| Spring Data JPA | Persistencia de datos |
| Oracle Database | Base de datos utilizada en el entorno local |
| H2 | Base de datos para pruebas y ejecución Docker |
| Maven | Gestión de dependencias y compilación |
| JUnit 5, Mockito y MockMvc | Pruebas automatizadas |
| JaCoCo | Medición de cobertura |
| Git y GitHub | Control de versiones |
| GitHub Actions | Automatización CI/CD |
| SonarQube Cloud | Análisis estático y calidad de código |
| Trivy | Análisis de vulnerabilidades de imágenes Docker |
| Docker | Contenedorización de la aplicación |
| Docker Hub | Almacenamiento y distribución de imágenes |

## 3. Estrategia de ramificación: GitFlow

El repositorio utiliza GitFlow para organizar el desarrollo y mantener la estabilidad del código.

| Rama | Función |
|---|---|
| `main` | Código estable preparado para entregas |
| `develop` | Integración de funcionalidades terminadas |
| `feature/*` | Desarrollo de nuevas funcionalidades o mejoras |
| `hotfix/*` | Correcciones urgentes |

### Justificación de GitFlow

Se seleccionó GitFlow porque permite separar el desarrollo de las versiones estables, facilitando el trabajo colaborativo y la revisión de cambios.

Las funcionalidades se desarrollan en ramas independientes y se integran mediante Pull Requests. Antes de realizar el merge, se ejecutan pruebas automatizadas y controles de calidad mediante GitHub Actions.

Esto permite detectar errores antes de integrar modificaciones al proyecto.

### Flujo de trabajo

```text
feature/nombre
      |
      v
Pull Request
      |
      v
   develop
      |
      v
Pull Request
      |
      v
     main
```

Las ramas `hotfix/*` se crean desde `main` y sus correcciones deben incorporarse también a `develop`.

### Otros modelos de ramificación

**GitHub Flow:** utiliza una rama principal y ramas de corta duración que se integran mediante Pull Requests.

**Trunk-Based Development:** promueve integraciones pequeñas y frecuentes hacia una rama principal.

**GitFlow:** mantiene ramas diferenciadas para desarrollo, funcionalidades y correcciones urgentes.

Para BDGET se utiliza GitFlow por su organización y trazabilidad.

## 4. Convenciones de commits

Se utiliza Conventional Commits para mantener un historial comprensible.

| Prefijo | Uso |
|---|---|
| `feat:` | Nueva funcionalidad |
| `fix:` | Corrección de errores |
| `docs:` | Documentación |
| `test:` | Pruebas automatizadas |
| `refactor:` | Mejoras internas |
| `chore:` | Mantenimiento |
| `ci:` | Cambios en integración continua |

Ejemplo:

```bash
git commit -m "test: agrega pruebas unitarias para StudentDTO"
```

## 5. Flujo colaborativo

1. Actualizar la rama `develop`.
2. Crear una rama `feature/*`.
3. Implementar los cambios.
4. Ejecutar las pruebas locales.
5. Registrar los cambios mediante commits.
6. Publicar la rama en GitHub.
7. Crear un Pull Request hacia `develop`.
8. Revisar los resultados de GitHub Actions.
9. Realizar el merge cuando los controles correspondientes estén aprobados.

Ejemplo:

```bash
git clone https://github.com/Tamaravalentinv/ProyectoBDGET.git
cd ProyectoBDGET

git switch develop
git pull origin develop

git switch -c feature/nueva-funcionalidad
```

Para publicar cambios:

```bash
git add README.md
git commit -m "docs: actualiza documentacion DevOps"
git push -u origin feature/nueva-funcionalidad
```

No se deben incluir contraseñas, archivos `.env` ni wallets de Oracle en los commits.

## 6. Integración continua y entrega continua (CI/CD)

El proyecto utiliza GitHub Actions para automatizar procesos de compilación, pruebas, análisis y publicación.

Los workflows se encuentran en:

```text
.github/workflows/
```

### Etapas del pipeline

**1. Compilación y pruebas**

Maven compila el proyecto y ejecuta las pruebas automatizadas.

**2. Cobertura con JaCoCo**

JaCoCo genera un reporte para medir qué partes del código están cubiertas por pruebas.

**3. Análisis con SonarQube Cloud**

SonarQube analiza la calidad del código, identifica problemas y evalúa el cumplimiento del Quality Gate.

**4. Construcción de imagen Docker**

Se construye la imagen de la aplicación para verificar su empaquetado.

**5. Análisis de seguridad con Trivy**

Trivy examina la imagen Docker en busca de vulnerabilidades conocidas.

**6. Publicación en Docker Hub**

El pipeline publica la imagen Docker cuando se cumplen las condiciones configuradas para la rama `develop`.

### Flujo general

```text
Push / Pull Request
        |
        v
   GitHub Actions
        |
        v
   Maven + JUnit
        |
        v
      JaCoCo
        |
        v
 SonarQube Cloud
        |
        v
  Docker Build
        |
        v
      Trivy
        |
        v
 Docker Hub (push a develop)
```

La publicación en Docker Hub se realiza mediante el workflow configurado para la rama correspondiente; no se publica automáticamente desde todos los Pull Requests.

## 7. Pruebas automatizadas

El proyecto utiliza JUnit 5, Mockito y MockMvc para verificar el comportamiento de la aplicación.

Se incluyen pruebas de componentes de la API y del DTO de estudiantes.

Para ejecutar las pruebas localmente en Windows:

```powershell
.\mvnw.cmd clean verify '-Dtest=!BdgetApplicationTests'
```

El resultado esperado es:

```text
BUILD SUCCESS
```

## 8. Cobertura con JaCoCo

JaCoCo permite medir la cobertura alcanzada por las pruebas automatizadas.

Después de ejecutar Maven, el reporte HTML se puede consultar en:

```text
target/site/jacoco/index.html
```

SonarQube Cloud utiliza el reporte XML de JaCoCo para evaluar la cobertura del código nuevo.

Durante la integración de SonarQube, se agregaron pruebas para `StudentDTO` con el objetivo de cumplir la condición de cobertura exigida por el Quality Gate.

## 9. Análisis de calidad con SonarQube Cloud

SonarQube Cloud está integrado con GitHub Actions.

El análisis permite identificar problemas relacionados con:

- Calidad y mantenibilidad del código.
- Seguridad.
- Posibles errores.
- Cobertura de pruebas.
- Cumplimiento del Quality Gate.

Proyecto en SonarQube Cloud:

https://sonarcloud.io/dashboard?id=Tamaravalentinv_ProyectoBDGET

El análisis se ejecuta desde el pipeline utilizando el secreto `SONAR_TOKEN`, configurado en GitHub Actions.

El token no se almacena directamente en el repositorio.

## 10. Seguridad con Trivy

Trivy se utiliza para analizar vulnerabilidades conocidas en las imágenes Docker.

El workflow realiza un escaneo de vulnerabilidades de severidad alta y crítica.

Actualmente, el escaneo está configurado para informar los hallazgos sin bloquear automáticamente el pipeline por vulnerabilidades detectadas.

Esto permite revisar los resultados y planificar correcciones de seguridad.

## 11. Docker y Docker Hub

La aplicación se empaqueta como una imagen Docker.

Repositorio de Docker Hub:

https://hub.docker.com/r/tamaravegareyes/my-app

### Descargar la imagen

```powershell
docker pull tamaravegareyes/my-app:latest
```

### Ejecutar la aplicación

```powershell
docker run --name bdget-test -p 8080:8080 -e SPRING_PROFILES_ACTIVE=docker tamaravegareyes/my-app:latest
```

Este comando inicia la aplicación en el puerto 8080 utilizando el perfil Docker.

Para detener el contenedor:

```powershell
docker stop bdget-test
```

Para eliminarlo:

```powershell
docker rm bdget-test
```

## 12. API REST

La API permite gestionar estudiantes mediante el endpoint:

```text
http://localhost:8080/students
```

### Consultar estudiantes

```powershell
Invoke-RestMethod -Uri "http://localhost:8080/students" -Method Get
```

### Crear un estudiante

```powershell
Invoke-RestMethod -Uri "http://localhost:8080/students" `
    -Method Post `
    -ContentType "application/json" `
    -Body '{"name":"Tamara"}'
```

El DTO valida que el nombre no esté vacío, tenga entre 2 y 50 caracteres y contenga únicamente letras.

## 13. Configuración local

Para ejecutar el proyecto utilizando Oracle Database:

1. Crear el archivo `.env` a partir de `.env.example`.
2. Configurar las credenciales correspondientes.
3. Mantener el wallet Oracle en el directorio configurado para la aplicación.
4. No publicar credenciales ni archivos privados.

Para iniciar con Maven:

```powershell
.\mvnw.cmd spring-boot:run
```

También se dispone de configuración para ejecutar el proyecto mediante Docker.

## 14. Buenas prácticas

- Trabajar en ramas `feature/*` para nuevas funcionalidades.
- Utilizar Pull Requests para integrar cambios.
- Mantener commits descriptivos.
- Ejecutar pruebas antes del merge.
- Revisar los resultados de SonarQube y Trivy.
- No almacenar secretos en el código fuente.
- Mantener actualizada la documentación.
- Verificar el pipeline antes de integrar cambios.

## 15. Resultados de la implementación DevOps

En el proyecto se implementaron y comprobaron los siguientes procesos:

- Integración de cambios mediante GitFlow y Pull Requests.
- Ejecución automatizada de pruebas con GitHub Actions.
- Generación de cobertura mediante JaCoCo.
- Análisis de calidad mediante SonarQube Cloud.
- Análisis de vulnerabilidades mediante Trivy.
- Construcción y publicación de imágenes en Docker Hub.
- Descarga y ejecución de la aplicación desde Docker Hub.
- Pruebas de funcionamiento de la API REST en un contenedor Docker.

Estas herramientas permiten automatizar tareas repetitivas, mejorar la trazabilidad y facilitar la detección temprana de problemas.

## 16. Repositorio

Código fuente:

https://github.com/Tamaravalentinv/ProyectoBDGET