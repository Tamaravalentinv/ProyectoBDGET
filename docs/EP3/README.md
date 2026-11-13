# EP3 — ECS Fargate, observabilidad, seguridad y CI/CD

Este documento describe lo preparado en el repositorio. No afirma que AWS, ECS, CloudWatch, Oracle o GitHub Actions hayan sido ejecutados: esas evidencias deben obtenerse en las cuentas autorizadas.

## 1. Arquitectura objetivo

```text
GitHub Actions --OIDC--> IAM deployment role
       |                     |
       |                     +--> ECR (image SHA -> digest)
       |                     +--> ECS control plane
       |                     +--> CloudWatch metrics/dashboard
       v
tests + JaCoCo + Trivy
                             Internet / red institucional
                                         |
                                      HTTPS ALB
                                         |
                              private subnets / awsvpc
                                  ECS Fargate service
                                  (minimum 2 tasks)
                                    |           |
                           CloudWatch Logs    EFS Access Point
                                    |         (Wallet, read-only,
                                    |          TLS in transit)
                                    +-----> Oracle Database
                                           through approved private
                                           route, VPN/NAT or endpoint
```

Componentes:

| Componente | Responsabilidad |
| --- | --- |
| ECR privado | Conserva imágenes; CI publica un tag SHA y resuelve el digest inmutable. |
| ECS/Fargate | Ejecuta tareas sin administrar instancias EC2. `awsvpc` asigna una interfaz de red por tarea. |
| ALB/Target Group | Distribuye tráfico, termina HTTPS y consulta `/actuator/health/readiness`. Su ARN es opcional en el script, pero se recomienda para disponibilidad. |
| Secrets Manager | JSON con claves `url`, `username` y `password`; ECS las inyecta sin guardarlas en Git. |
| EFS Access Point | Entrega el Wallet a `/app/wallet` de solo lectura y con TLS. No se crea automáticamente. |
| CloudWatch Logs | Recibe stdout/stderr mediante `awslogs`, con retención configurada al crearse por script. |
| CloudWatch Metrics/Dashboard | CPU/memoria nativas más disponibilidad, tareas, errores, duración, cobertura y estado CI personalizados. |
| IAM/OIDC | Credenciales efímeras de GitHub y roles de ejecución/tarea separados. |

## 2. Flujo CI/CD y bloqueos

`.github/workflows/main.yml` implementa dependencias con `needs`:

1. `build_test`: compila, prueba y ejecuta JaCoCo.
2. `security_scan`: audita dependencias Maven, secretos e IaC/Dockerfile.
3. `quality_gate`: solo existe si los controles anteriores aprobaron.
4. `docker_build`: construye y bloquea vulnerabilidades CRITICAL de imagen.
5. `compose_validation`: construye una imagen H2 separada y conserva la prueba funcional local con dos réplicas; esa imagen nunca se publica en ECR.
6. `publish_ecr`: únicamente `workflow_dispatch`, `deploy_aws=true`, rama `main` y aprobación `production`.
7. `deploy_ecs`: registra una revisión y espera estabilidad del servicio.
8. `post_deploy`: comprueba readiness y publica observaciones reales.

No hay `continue-on-error` en controles obligatorios. Pull requests, forks y pushes ordinarios nunca obtienen permisos OIDC de despliegue. La publicación usa exactamente el tar de la imagen Oracle analizada y el despliegue recibe su digest. La simulación H2 es independiente y no puede avanzar a ECR.

La demostración controlada `.github/workflows/quality-gate-demo.yml` crea un conteo crítico sintético, lo conserva como artifact y falla. El job dependiente queda `skipped`; no se incorpora una vulnerabilidad real.

## 3. Observabilidad y origen de métricas

Actuator expone solamente `health`, `info` y `metrics`. Los detalles de salud no son públicos. Liveness verifica que el proceso pueda continuar; readiness incluye los indicadores de disponibilidad, incluida la base de datos cuando corresponde.

Como endurecimiento compatible, los errores conservan su código y estructura JSON, pero los mensajes de excepciones internas ya no se devuelven ni se escriben en logs; se usa un mensaje genérico y el `correlationId` para investigación. Esto evita filtrar cadenas JDBC, credenciales o datos internos.

| Panel/métrica | Namespace y origen | Momento de publicación |
| --- | --- | --- |
| CPU/Memory | `AWS/ECS`, generado por ECS | Continuo cuando existe el servicio. |
| `ApplicationErrorCount` | `BDGET/DevOps`, filtro `level=ERROR` sobre logs | CloudWatch Logs lo calcula desde eventos reales. |
| `Availability` | `BDGET/DevOps`, comparación real running/desired | `Get-EcsStatus.ps1 -PublishMetrics`. |
| `RunningTaskCount` | `BDGET/DevOps`, `DescribeServices` | Mismo comando anterior. |
| `DeploymentDuration` | `BDGET/DevOps`, diferencia UTC medida por el script | Tras `services-stable`. |
| `JacocoLineCoverage` | `BDGET/DevOps`, counters LINE del XML JaCoCo | Post-deploy, desde el artifact real. |
| `CiValidationSuccess` | `BDGET/DevOps`, valor 1 solo tras controles y post-deploy | Post-deploy exitoso. |

Todas las métricas personalizadas usan dimensiones `Application=bdget`, `Environment` y `Service`. No se incluyen valores simulados en el dashboard. La ausencia de puntos significa que la operación real aún no fue ejecutada.

Publicación, una vez autorizada y autenticada:

```powershell
./infra/cloudwatch/scripts/Publish-LogMetricFilter.ps1 -Region <region> -LogGroup <log-group> -Service <service>
./infra/cloudwatch/scripts/Publish-Dashboard.ps1 -Region <region> -DashboardName <name> -Cluster <cluster> -Service <service> -LogGroup <log-group>
```

## 4. Preparación de AWS

El proyecto no supone que existan recursos. Antes de desplegar, el equipo debe crear o seleccionar conscientemente:

1. Cuenta y región AWS.
2. VPC, al menos dos subnets privadas en AZ distintas, rutas y Security Groups.
3. Conectividad permitida hacia Oracle; nunca abrir el listener Oracle a `0.0.0.0/0`.
4. ECR, clúster ECS, log group y opcionalmente ALB HTTPS/Target Group IP.
5. Roles ECS de ejecución y tarea, rol GitHub OIDC y proveedor OIDC.
6. Secret de Oracle y EFS/Access Point con Wallet únicamente legible.
7. Entorno GitHub `production` con reviewers requeridos.

Las plantillas IAM contienen marcadores en mayúsculas. Deben renderizarse con ARNs reales y revisarse antes de aplicarlas. El rol de tarea solo requiere lectura del Access Point; el rol de ejecución obtiene imagen, logs y secret. El rol GitHub puede publicar ECR, registrar/actualizar ECS, pasar solo ambos roles y escribir el namespace de métricas.

### Variables y secretos requeridos en GitHub

| Tipo | Nombre | Contenido esperado |
| --- | --- | --- |
| Variable | `AWS_DEPLOY_ROLE_ARN` | Rol IAM confiable por OIDC para el environment `production`. |
| Variable | `AWS_REGION`, `AWS_ACCOUNT_ID` | Región elegida e ID real de 12 dígitos. |
| Variable | `ECR_REPOSITORY` | Repositorio privado precreado. |
| Variable | `ECS_CLUSTER`, `ECS_SERVICE`, `ECS_TASK_FAMILY` | Nombres reales de ECS. |
| Variable | `ECS_EXECUTION_ROLE_ARN`, `ECS_TASK_ROLE_ARN` | Roles separados de ejecución y aplicación. |
| Variable | `ECS_SUBNET_IDS`, `ECS_SECURITY_GROUP_IDS` | IDs separados por coma, sin espacios. |
| Variable | `CLOUDWATCH_LOG_GROUP` | Log group autorizado. |
| Variable | `ORACLE_WALLET_EFS_ID`, `ORACLE_WALLET_EFS_ACCESS_POINT_ID` | EFS y Access Point del Wallet. |
| Variable | `ALB_TARGET_GROUP_ARN`, `SERVICE_BASE_URL` | Target Group tipo IP y URL HTTPS de validación. |
| Variable | `CORS_ALLOWED_ORIGINS` | Origen HTTPS permitido; no usar `*` en producción. |
| Variables opcionales | `SONAR_ENABLED`, `SONAR_PROJECT_KEY`, `SONAR_ORGANIZATION` | Activación y claves no secretas de SonarQube Cloud. |
| Secret | `ORACLE_SECRET_ARN` | ARN del secret JSON; sus valores nunca se copian a GitHub. |
| Secret opcional | `SONAR_TOKEN` | Token de alcance mínimo, solo si Sonar está habilitado. |

AWS Secrets Manager debe contener las claves JSON `url`, `username` y `password`. No se deben crear secrets separados con esos nombres en GitHub.

### Oracle y Wallet

- Guardar `url`, `username` y `password` como JSON en Secrets Manager y restringir su resource policy.
- Copiar el Wallet a EFS fuera del repositorio, limitar el Access Point a un UID/GID dedicado y habilitar cifrado en reposo y tránsito.
- Autorizar NFS 2049 desde el Security Group de tareas al de EFS, no desde Internet.
- Configurar `TNS_ADMIN=/app/wallet` dentro de la URL o propiedades Oracle existentes.
- Usar rutas privadas/VPN/peering cuando sea viable; si se requiere NAT, revisar costo y egress.
- Probar Oracle desde una tarea controlada antes de aumentar réplicas y respetar el máximo de sesiones Hikari/Oracle.

## 5. Procedimiento PowerShell/AWS CLI

Los siguientes comandos son ejemplos parametrizados; reemplazar marcadores, no pegarlos como valores reales.

```powershell
./infra/ecs/scripts/Test-Prerequisites.ps1 -Region <region> -ExpectedAccountId <12-digits> -RequireDocker

./infra/ecs/scripts/Publish-EcrImage.ps1 `
  -Region <region> -AccountId <12-digits> -Repository <repo> `
  -ImageTag <git-sha>

./infra/ecs/scripts/Deploy-EcsService.ps1 `
  -Region <region> -Cluster <cluster> -Service <service> -TaskFamily <family> `
  -ImageDigestUri <account.dkr.ecr.region.amazonaws.com/repo@sha256:digest> `
  -ExecutionRoleArn <execution-role-arn> -TaskRoleArn <task-role-arn> `
  -OracleSecretArn <secret-arn> -LogGroup <log-group> `
  -SubnetIds <subnet-a>,<subnet-b> -SecurityGroupIds <sg-id> `
  -EfsFileSystemId <fs-id> -EfsAccessPointId <fsap-id> `
  -CorsAllowedOrigins <https://frontend.example> `
  -TargetGroupArn <target-group-arn>
```

`Publish-EcrImage.ps1` no crea ECR salvo que se agregue explícitamente `-CreateRepository`. `Deploy-EcsService.ps1` no crea clúster, red, roles, ALB ni EFS. Puede crear el log group solo con `-CreateLogGroup`. Ambos admiten `-WhatIf` para revisar acciones.

Verificación y logs:

```powershell
./infra/ecs/scripts/Get-EcsStatus.ps1 -Region <region> -Cluster <cluster> -Service <service>
./infra/ecs/scripts/Get-CloudWatchLogs.ps1 -Region <region> -LogGroup <log-group> -Since 30m
aws ecs describe-services --region <region> --cluster <cluster> --services <service>
aws cloudwatch get-dashboard --region <region> --dashboard-name <dashboard>
```

Rollback revisado:

```powershell
./infra/ecs/scripts/Rollback-EcsService.ps1 -WhatIf -Region <region> -Cluster <cluster> -Service <service>
./infra/ecs/scripts/Rollback-EcsService.ps1 -Region <region> -Cluster <cluster> -Service <service> -TaskDefinitionArn <known-good-arn>
```

El circuit breaker está habilitado con rollback automático. El comando manual exige confirmar la revisión conocida; nunca debe elegirse una revisión solo por antigüedad sin revisar imagen, variables y secretos.

## 6. Security Groups y ALB

- ALB: ingreso 443 únicamente desde los consumidores autorizados; salida al puerto del contenedor.
- Tareas: ingreso 8080 únicamente desde el SG del ALB; salida mínima hacia Oracle, EFS, DNS y endpoints/NAT requeridos.
- EFS: ingreso 2049 únicamente desde el SG de tareas.
- Target Group: tipo `ip`, protocolo HTTP interno, path `/actuator/health/readiness`, matcher 200.
- Listener: certificado ACM y redirección 80→443 si se expone 80.

## 7. Política de calidad y branch protection

El gate mínimo es 80 % de líneas y se cambia explícitamente con `-Djacoco.minimum.line.coverage=<ratio>`. Se bloquean secretos, CRITICAL en dependencias/imagen y HIGH/CRITICAL en configuración. Hallazgos HIGH de dependencias se reportan para priorización, pero la política exigida bloquea CRITICAL.

Configurar protección siguiendo [branch-protection.md](branch-protection.md). Los checks requeridos deben usar sus nombres visibles reales después de la primera ejecución. No se afirma cumplimiento de una certificación; estos controles apoyan mínimo privilegio, trazabilidad, revisión y gestión de vulnerabilidades.

## 8. Matriz IE1–IE6

| Indicador | Implementación | Evidencia que debe capturarse |
| --- | --- | --- |
| IE1 Observabilidad | Actuator, probes, Micrometer, correlación, stdout y handler saneado. | Respuestas health/info/metrics, logs con correlation ID, alarma/panel con datos reales. |
| IE2 ECS Fargate | Docker multi-stage/no-root, Task Definition, ECR/digest, `awsvpc`, scripts create/update/wait/status/log/rollback. | Revisión ECS, tareas RUNNING, target healthy y digest coincidente. |
| IE3 Dashboard | Template CloudWatch, filtro de errores y scripts de métricas reales. | Dashboard con período real y origen de cada punto. |
| IE4 Documentación | Este runbook, README, arquitectura, riesgos, comandos, decisiones e IA. | Documento revisado por el equipo y capturas referenciadas. |
| IE5 Seguridad | Trivy, Dependabot, JaCoCo/Sonar opcional, OIDC, IAM templates, Secrets Manager/EFS. | Artifacts, findings resueltos/aceptados y configuración GitHub/AWS. |
| IE6 Bloqueo | `needs`, gates sin tolerancia, manual main-only, environment approval y demo controlada. | Run exitoso y run esperado fallido mostrando jobs posteriores skipped. |

## 9. Evidencias reales pendientes

Crear `docs/EP3/evidence/` solo para capturas sin secretos y registrar:

| Evidencia | Enlace/captura | Fecha | Responsable | Observaciones |
| --- | --- | --- | --- | --- |
| Maven + JaCoCo | Pendiente | Pendiente | Pendiente | Incluir porcentaje real. |
| Pipeline exitoso | Pendiente | Pendiente | Pendiente | Asociar SHA y run ID. |
| Pipeline bloqueado | Pendiente | Pendiente | Pendiente | Confirmar downstream skipped. |
| ECR digest | Pendiente | Pendiente | Pendiente | Ocultar ID si política académica lo exige. |
| ECS estable/ALB healthy | Pendiente | Pendiente | Pendiente | Sin URLs internas sensibles. |
| Logs y dashboard | Pendiente | Pendiente | Pendiente | Seleccionar período con datos reales. |
| Rollback | Pendiente | Pendiente | Pendiente | Usar ambiente autorizado. |

## 10. Costos, riesgos y limitaciones

- Fargate cobra por vCPU/memoria mientras las tareas están aprovisionadas; dos tareas mejoran disponibilidad y duplican cómputo.
- ALB tiene costo horario y por capacidad; NAT Gateway suele ser un costo relevante. Evaluar VPC endpoints para ECR, Logs, Secrets y S3.
- CloudWatch cobra ingestión/retención de logs, métricas personalizadas y dashboards. La retención propuesta es 30 días.
- EFS cobra almacenamiento y acceso; mantener solo archivos Wallet necesarios.
- Secrets Manager cobra por secret y llamadas.
- La configuración no ha sido probada contra la cuenta AWS ni Oracle reales.
- La imagen base está fijada por digest, pero debe renovarse con Dependabot y volver a escanearse.
- `/actuator/metrics` no contiene secretos por diseño, aunque conviene restringir Actuator al ALB/red interna en producción.

## 11. Decisiones, conclusiones y reflexiones

Completar por el equipo:

| Tema | Decisión y justificación humana |
| --- | --- |
| Región y topología de red | Pendiente. |
| Dimensionamiento CPU/memoria/réplicas | Pendiente. |
| Estrategia Oracle privada | Pendiente. |
| ALB público o interno | Pendiente. |
| Umbrales y excepciones de seguridad | Pendiente; toda excepción debe tener dueño y vencimiento. |
| Conclusión del equipo | Pendiente. |

Reflexiones individuales:

- Integrante 1: pendiente.
- Integrante 2: pendiente.
- Integrante 3: pendiente, si corresponde.

### Declaración de uso de IA

| Campo | Declaración del equipo |
| --- | --- |
| Herramienta y versión | Pendiente. |
| Actividades asistidas | Pendiente. |
| Verificación humana | Pendiente. |
| Cambios aceptados, corregidos o descartados | Pendiente. |
| Limitaciones observadas | Pendiente. |
