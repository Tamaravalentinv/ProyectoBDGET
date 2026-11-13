# BDGET

API REST de estudiantes construida con Spring Boot, JPA y Oracle. La preparación EP3 utiliza Amazon ECS con AWS Fargate, sin Kubernetes, y mantiene las rutas y contratos existentes bajo `/students`.

La implementación, arquitectura, runbook, matriz IE1–IE6 y espacios de evidencia están en [docs/EP3/README.md](docs/EP3/README.md).

## Requisitos locales

- Java 17 LTS.
- Maven Wrapper incluido.
- Docker y Docker Compose para validar la imagen y el entorno de simulación.
- AWS CLI v2 y PowerShell 7 únicamente para operar la infraestructura preparada.

## Ejecución y pruebas

```powershell
./mvnw.cmd -B -ntp clean verify
./mvnw.cmd spring-boot:run
```

La prueba local aislada no usa Oracle ni secretos:

```powershell
docker build --build-arg MAVEN_PROFILE=simulation -t bdget:evaluation .
$env:BDGET_IMAGE = 'bdget:evaluation'
docker compose -f docker-compose.evaluation.yml up -d --no-build --scale microservicio=2
curl.exe --fail http://127.0.0.1:18080/actuator/health/readiness
curl.exe --fail http://127.0.0.1:18080/students
docker compose -f docker-compose.evaluation.yml down --volumes --remove-orphans
```

## Configuración Oracle

En desarrollo, copia `.env.example` a `.env`, reemplaza exclusivamente los marcadores y conserva el Wallet fuera de Git. `.gitignore` y `.dockerignore` excluyen credenciales, wallets, llaves y almacenes de certificados.

En ECS, URL, usuario y contraseña se obtienen de un JSON en AWS Secrets Manager; el Wallet se monta de solo lectura desde un Access Point EFS con cifrado en tránsito. No se incluyen credenciales ni Wallet en la imagen.

## Observabilidad

Los endpoints expuestos son:

- `/actuator/health`, sin detalles internos.
- `/actuator/health/liveness`, para el health check del contenedor ECS.
- `/actuator/health/readiness`, para ALB y validación posterior al despliegue.
- `/actuator/info` y `/actuator/metrics`.

Los logs salen por stdout/stderr con timestamp, nivel y `correlationId`. El cliente puede enviar `X-Correlation-ID`; valores inseguros se sustituyen por un UUID.

## Pipeline EP3

```text
push / pull request / ejecución manual
  -> build + tests + JaCoCo (>= 80 %)
  -> Trivy: dependencias + secretos + configuración
  -> quality gate obligatorio
  -> Docker build + Trivy de imagen
  -> validación local de dos réplicas
  -> ECR (solo ejecución manual autorizada desde main)
  -> ECS Fargate (entorno production con aprobación)
  -> readiness + métricas CloudWatch
```

No se usan access keys permanentes. GitHub Actions solicita credenciales temporales mediante OIDC. Los jobs de publicación y despliegue quedan omitidos en pushes y pull requests normales.

## Política de calidad y seguridad

- Las pruebas y el `jacoco:check` bloquean el pipeline.
- El umbral por defecto es 80 % de líneas y se parametriza con `jacoco.minimum.line.coverage`.
- Secretos, vulnerabilidades CRITICAL y configuraciones HIGH/CRITICAL bloquean etapas posteriores.
- La imagen aprobada se etiqueta con el SHA y se despliega por digest.
- SonarQube Cloud es un control adicional cuando `SONAR_ENABLED=true`; no se declara ejecutado si no está configurado.
- Los reportes Surefire, JaCoCo y Trivy se conservan como artifacts.

El workflow manual `EP3 - Controlled blocked pipeline evidence` genera una entrada sintética y falla deliberadamente el gate. No agrega vulnerabilidades al repositorio.

## Endpoints de negocio conservados

| Método | Ruta | Acción |
| --- | --- | --- |
| GET | `/students` | Listar estudiantes |
| GET | `/students/{id}` | Consultar por ID |
| POST | `/students` | Crear estudiante |
| PUT | `/students/{id}` | Actualizar estudiante |
| DELETE | `/students/{id}` | Eliminar estudiante |

## Documentación

- [Guía EP3, matriz y runbook](docs/EP3/README.md)
- [Protección de ramas](docs/EP3/branch-protection.md)
- [Contribución](CONTRIBUTING.md)

## Declaración de uso de IA

El equipo debe completar la declaración y las reflexiones individuales en `docs/EP3/README.md` antes de entregar. No se atribuyen a la IA decisiones que no hayan sido revisadas por el equipo.
