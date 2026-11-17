# Índice de evidencias — EP3 ProyectoBDGET

## Alcance

Esta carpeta contiene una selección de reportes generados durante las validaciones de la Evaluación Parcial 3.

Los archivos corresponden a ejecuciones reales de GitHub Actions y permiten verificar resultados de cobertura y seguridad.

## Evidencias

| Archivo | Ejecución | Descripción |
| --- | --- | --- |
| jacoco.xml | 44177535702 | Reporte XML de cobertura JaCoCo. |
| trivy-dependencies-before.json | 44177535702 | Análisis anterior: 2 vulnerabilidades HIGH. |
| trivy-dependencies-after.json | 44181598986 | Análisis posterior: 0 vulnerabilidades reportadas. |
| trivy-config.json | 44181598986 | Análisis de configuración mediante Trivy. |
| trivy-image.json | 44177535702 | Análisis de seguridad de la imagen Docker. |

## Resultado principal

La comparación de los reportes de dependencias demuestra que los dos hallazgos HIGH presentes en la ejecución anterior dejaron de aparecer después de actualizar Apache HttpCore a la versión 5.4.3.

## Ejecuciones relacionadas

- Validación anterior: https://github.com/Tamaravalentinv/ProyectoBDGET/actions/runs/44177535702
- Validación posterior: https://github.com/Tamaravalentinv/ProyectoBDGET/actions/runs/44181598986
- Pipeline final: https://github.com/Tamaravalentinv/ProyectoBDGET/actions/runs/44182852819
- Pull Request de corrección: https://github.com/Tamaravalentinv/ProyectoBDGET/pull/31

## Limitaciones

Estos reportes respaldan controles de integración continua, pruebas y seguridad. No acreditan por sí solos un despliegue productivo completo en AWS con Oracle, EFS, Secrets Manager y ALB.

La revisión automatizada de posibles credenciales no sustituye una inspección completa antes de publicar los archivos.
