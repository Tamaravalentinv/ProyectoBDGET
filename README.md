# BDGET

## Descripción del proyecto

BDGET es un microservicio REST para la gestión de estudiantes. Expone operaciones CRUD bajo `/students` y organiza el código en las capas de controlador, servicio, repositorio y entidad.

## Tecnologías utilizadas

- Java 17
- Spring Boot 4.0.9
- Spring Web, Spring Data JPA y Spring Validation
- Oracle Database con JDBC
- Maven y Maven Wrapper
- JUnit 5, Mockito, MockMvc y JaCoCo
- Docker y Docker Compose
- GitHub Actions

## Estrategia de ramificación

El repositorio usa GitFlow. Las ramas permanentes son `main` y `develop`; las ramas de trabajo siguen los prefijos `feature/` y `hotfix/`.

| Rama o patrón | Uso en este repositorio |
| --- | --- |
| `main` | Código estable, preparado para una entrega o despliegue. |
| `develop` | Integración de cambios terminados antes de llegar a `main`. |
| `feature/<nombre>` | Trabajo temporal de una funcionalidad o mejora, creado desde `develop`. Ejemplos: `feature/automatizacion-ci`, `feature/documentacion-devops`. |
| `hotfix/<nombre>` | Corrección urgente creada desde `main`. Ejemplo: `hotfix/configuracion`. |

### Otros modelos de ramificación

- **GitHub Flow:** mantiene una rama principal y ramas cortas que se integran mediante Pull Request. Es útil para despliegues frecuentes y simples.
- **Trunk-Based Development:** integra cambios muy pequeños y frecuentes directamente o casi directamente al tronco. Requiere automatización y pruebas rápidas y confiables.
- **GitFlow:** separa claramente el desarrollo, las funcionalidades y las correcciones urgentes. En este repositorio se aplica mediante las ramas descritas arriba.


## Flujo de trabajo Git

```text
main
  ↑
develop
  ↑
feature/nombre
```

1. Crear una rama `feature/<nombre>` desde `develop`.
2. Realizar un cambio acotado y comprobarlo localmente.
3. Preparar los archivos con `git add`.
4. Registrar el cambio con `git commit`.
5. Publicar la rama con `git push`.
6. Abrir un Pull Request desde la feature hacia `develop`.
7. Revisar los cambios y el resultado del workflow.
8. Hacer merge una vez aprobada la revisión.

Para un hotfix, la rama se crea desde `main`; tras corregir y revisar, se integra en `main` y también en `develop`.

### Comandos de referencia

| Comando | Función en el flujo colaborativo |
| --- | --- |
| `git clone <url>` | Crea una copia local del repositorio remoto. |
| `git branch` | Lista o crea ramas locales. |
| `git checkout <rama>` | Cambia de rama; se conserva por compatibilidad con flujos existentes. |
| `git switch <rama>` | Cambia de rama con la sintaxis actual. |
| `git pull origin <rama>` | Actualiza la rama local desde GitHub antes de trabajar. |
| `git add <archivo>` | Prepara cambios para el siguiente commit. |
| `git commit -m "tipo: descripción"` | Registra un cambio pequeño y descriptivo. |
| `git push origin <rama>` | Publica la rama o sus commits en GitHub. |
| `git merge <rama>` | Integra una rama después de su revisión y aprobación. |

Ejemplo de una feature:

```bash
git clone https://github.com/Tamaravalentinv/ProyectoBDGET.git
git switch develop
git pull origin develop
git switch -c feature/documentacion-devops
git add README.md CONTRIBUTING.md
git commit -m "docs: documenta flujo GitFlow"
git push -u origin feature/documentacion-devops
```

## Convenciones de ramas

- Usar nombres en minúsculas y palabras separadas por guiones.
- Crear `feature/<nombre>` desde `develop`, por ejemplo `feature/automatizacion-ci`.
- Crear `hotfix/<nombre>` desde `main`, por ejemplo `hotfix/configuracion`.
- No trabajar directamente sobre `main`.
- Eliminar ramas remotas solo después de que su Pull Request haya sido integrado.

## Convenciones de commits

Se usa Conventional Commits para cambios actuales y futuros:

| Prefijo | Uso | Ejemplo en BDGET |
| --- | --- | --- |
| `feat:` | Nueva funcionalidad | `feat: agrega búsqueda de estudiantes` |
| `fix:` | Corrección de error | `fix: corrige configuración del wallet Oracle` |
| `docs:` | Documentación | `docs: documenta flujo GitFlow` |
| `refactor:` | Mejora interna sin cambiar comportamiento | `refactor: simplifica servicio de estudiantes` |
| `test:` | Pruebas | `test: agrega caso de actualización de estudiante` |
| `chore:` | Mantenimiento | `chore: actualiza configuración de Maven` |

## Pull Requests y revisión de código

- `feature/*` se revisa e integra hacia `develop`.
- `develop` se revisa e integra hacia `main` cuando corresponde publicar una versión estable.
- `hotfix/*` se revisa e integra hacia `main`; la misma corrección debe llegar también a `develop`.

Antes de un merge se revisan la descripción, los archivos modificados, los commits, el workflow de GitHub Actions y cualquier efecto sobre la configuración. Ningún Pull Request sustituye la revisión humana.

## Trazabilidad de cambios

```text
issue o tarea
      ↓
rama feature/hotfix
      ↓
commits convencionales
      ↓
push a GitHub
      ↓
Pull Request y revisión
      ↓
merge a develop
      ↓
Pull Request de develop a main
```

## Buenas prácticas del repositorio

- Crear ramas con los prefijos y nombres acordados.
- Mantener commits pequeños, descriptivos y con la convención definida.
- No subir secretos, archivos `.env` ni wallets de Oracle.
- Respetar la estructura actual: `src/main` para la aplicación, `src/test` para pruebas, `.github/workflows` para automatización y archivos Docker en la raíz.
- Mantener cada cambio relacionado con una tarea o issue identificable.
- Abrir Pull Requests antes de integrar cambios y revisar el diff antes del merge.
- Evitar trabajo directo en `main`.
- Actualizar README, CONTRIBUTING o la configuración cuando el cambio lo requiera.
- Resolver conflictos y actualizar la rama con su destino antes de solicitar la revisión final.

## Estructura del repositorio

- `.github/workflows/` - Configuración de GitHub Actions para CI/CD.
- `src/main/java/com/example/bdget/` - Código fuente de la aplicación:
  - `controller/` - Controladores REST.
  - `service/` - Lógica de negocio.
  - `repository/` - Acceso a datos (JPA).
  - `model/` - Entidades del dominio.
  - `exception/` - Manejo de excepciones.
- `src/test/` - Pruebas unitarias e integración (JUnit 5, Mockito, MockMvc).
- `Dockerfile` - Definición de imagen Docker para la aplicación.
- `docker-compose.yml` - Orquestación local con Docker Compose.
- `pom.xml` - Configuración de dependencias y plugins Maven.
- `mvnw` / `mvnw.cmd` - Maven Wrapper para garantizar consistencia de versión.

## Integración Continua (CI) y Entrega Continua (CD)

GitHub Actions automatiza el pipeline CI/CD del proyecto.

### GitHub Actions Workflow

El workflow se encuentra en `.github/workflows/main.yml` y se ejecuta en tres escenarios:

**1. En eventos `push` hacia `develop` o `main`:**
- Ejecuta pruebas, cobertura, SonarQube Cloud cuando esta habilitado y controles Trivy.
- Construye una unica imagen de simulacion identificada por el SHA.
- Publica la imagen en Docker Hub solamente en pushes a `develop` y si las validaciones anteriores aprueban.
- Despliega exactamente el mismo artefacto mediante Docker Compose y verifica dos replicas.

**2. En eventos `pull_request` hacia `develop` o `main`:**
- Ejecuta pruebas, cobertura, seguridad y despliegue simulado.
- No publica imagenes en Docker Hub.
- No expone secretos a pull requests procedentes de forks.

**3. Ejecucion manual `workflow_dispatch`:**
- Permite validar pruebas, seguridad y despliegue sin publicar una imagen externa.

### Configuración de Secrets

GitHub Secrets configura credenciales de forma segura:

| Secret | Propósito |
| --- | --- |
| `DOCKERHUB_USERNAME` | Nombre de usuario de Docker Hub. |
| `DOCKERHUB_TOKEN` | Token de autenticación de Docker Hub (nunca se expone en logs). |
| `SONAR_TOKEN` | Token del proyecto en SonarQube Cloud; solo se usa al habilitar el analisis. |

**Importante:** Los secrets se configuran en Settings > Secrets and variables > Actions del repositorio. Nunca se incluyen en el código ni en el README.

Las variables de repositorio para SonarQube Cloud son `SONAR_ENABLED`, `SONAR_PROJECT_KEY` y `SONAR_ORGANIZATION`. La variable opcional `DOCKERHUB_REPOSITORY` permite reemplazar el nombre predeterminado `proyectobdget-simulation`.

## Configuración local

1. Copia `.env.example` como `.env` y completa las credenciales de Oracle.
2. Mantén el wallet de Oracle en `Wallet_N72BZHZWYZGTE7OH/`; este directorio no se versiona por seguridad.
3. Ejecuta el proyecto con Maven o Docker Compose.

```bash
./mvnw -B -ntp clean verify
./mvnw spring-boot:run
# o
docker compose up --build
```

## Cumplimiento de los indicadores

| Indicador | Implementacion principal |
| --- | --- |
| IE1 - Contenedores | Dockerfile multietapa Java 17, runtime JRE, usuario `10001:10001`, contexto protegido por `.dockerignore` y construccion reproducible del JAR. |
| IE2 - Pruebas | 30 pruebas JUnit/Mockito/MockMvc, contexto aislado con H2, reportes Surefire y JaCoCo, y gate minimo de 80% de cobertura de lineas. |
| IE3 - Seguridad | Dependabot semanal para Maven y Actions, Trivy para secretos/configuracion/imagenes y SonarQube Cloud con Quality Gate al habilitar sus credenciales. |
| IE4 - CI/CD | Prueba, analisis, construccion unica, publicacion condicional por SHA, despliegue simulado, verificacion HTTP y trazabilidad. |
| IE5 - Orquestacion | Docker Compose con dos replicas, Nginx, redes separadas, healthchecks, recursos, reinicio y prueba de recuperacion. |

### Activacion de SonarQube Cloud

La integracion queda preparada, pero requiere crear o importar externamente el proyecto en SonarQube Cloud. No hay tokens ni identificadores ficticios en el repositorio.

1. Crea o importa el repositorio en SonarQube Cloud y desactiva el analisis automatico si se utilizara el analisis Maven del workflow.
2. En GitHub, crea el secret `SONAR_TOKEN` con un token limitado al proyecto.
3. Crea las variables `SONAR_PROJECT_KEY` y `SONAR_ORGANIZATION` con los identificadores entregados por SonarQube Cloud.
4. Crea `SONAR_ENABLED` con valor `true` solamente cuando los tres valores anteriores esten configurados.
5. Ejecuta el workflow y conserva la URL/estado del Quality Gate como evidencia.

Mientras `SONAR_ENABLED` no sea `true`, el workflow registra que la activacion esta pendiente y continua con Maven y Trivy. Una vez habilitado, una configuracion incompleta o un Quality Gate rechazado bloquean las etapas posteriores.

## Pipeline CI/CD verificable

El workflow `.github/workflows/main.yml` implementa las siguientes etapas:

```text
commit o pull request
        |
        v
pruebas Maven + JaCoCo
        |
        v
SonarQube Cloud + Quality Gate
(cuando SONAR_ENABLED=true)
        |
        v
construccion unica de la imagen con perfil simulation
        |
        v
Trivy + quality gate
        |
        +--------------------------+
        |                          |
        v                          v
publicacion por SHA          artifact Docker validado
(solo push a develop)              |
                                   v
                          despliegue Docker Compose
                                   |
                                   v
                         healthcheck + GET /students
                                   |
                                   v
                          limpieza del entorno
```

### Etapas del pipeline

1. `test` usa Java 17 y ejecuta `./mvnw -B -ntp clean verify`. Los 30 tests deben aprobar, JaCoCo exige al menos 80% de lineas cubiertas y se publican los reportes Surefire y JaCoCo.
2. Cuando `SONAR_ENABLED=true`, el mismo job usa Java 21 exclusivamente para SonarScanner, envia el reporte JaCoCo a SonarQube Cloud y espera hasta cinco minutos el Quality Gate. Un gate rechazado hace fallar el pipeline. Si la integracion aun no esta activada, el resumen indica expresamente que esta pendiente; no se declara un analisis ficticio. Los pull requests desde forks no reciben el token.
3. `security` construye una sola imagen de evaluacion, etiquetada localmente como `bdget-simulation:<commit-sha>`, utilizando el perfil Maven `simulation`. Trivy analiza secretos, configuracion, la imagen de la aplicacion y la imagen Nginx fijada por digest. El quality gate bloquea secretos, vulnerabilidades criticas y configuraciones altas o criticas.
4. La imagen aprobada se exporta como artifact temporal. Los jobs posteriores cargan ese mismo archivo; no reconstruyen la aplicacion.
5. `publish` se ejecuta solamente en un `push` a `develop`. Publica `<DOCKERHUB_USERNAME>/<DOCKERHUB_REPOSITORY>:<commit-sha>` y registra su digest. El repositorio predeterminado es `proyectobdget-simulation`; no se publican imagenes desde pull requests.
6. `deploy` carga el artifact validado y levanta dos replicas de la aplicacion con `docker-compose.evaluation.yml`. Espera que las replicas y el proxy esten `healthy`, comprueba el balanceo, ejecuta `GET /students`, valida la recuperacion automatica de una replica y finalmente elimina los recursos temporales.

La imagen publicada contiene el perfil de simulacion con H2 y sirve como evidencia academica reproducible. No se presenta como una imagen de produccion Oracle y no contiene Wallet ni credenciales.

### Trazabilidad

Cada ejecucion relaciona:

- el SHA completo del commit (`github.sha`);
- la etiqueta inmutable de la imagen;
- el identificador de ejecucion (`github.run_id`);
- los artifacts de pruebas, cobertura y Trivy;
- el digest devuelto por Docker Hub cuando existe publicacion;
- el estado del contenedor y el resultado de la comprobacion HTTP.

El resumen de GitHub Actions registra la imagen publicada y el despliegue simulado. Debido a que seguridad, publicacion y despliegue utilizan el mismo `docker save`, el artefacto desplegado es el mismo que fue analizado.

## Entorno de despliegue simulado

El archivo `docker-compose.evaluation.yml` ejecuta dos replicas del microservicio con el perfil Spring `simulation`. Este perfil deshabilita Spring Cloud Config y sustituye Oracle por H2 en memoria. Nginx actua como punto de entrada y balanceador, por lo que las replicas no publican puertos en el host. El entorno no requiere Wallet, `.env`, usuario, password ni acceso a Oracle Cloud.

Para ejecutarlo localmente:

```bash
docker build --build-arg MAVEN_PROFILE=simulation -t bdget:evaluation .
docker compose -f docker-compose.evaluation.yml config
docker compose -f docker-compose.evaluation.yml up -d --no-build --scale microservicio=2
docker compose -f docker-compose.evaluation.yml ps
curl --fail http://127.0.0.1:18080/students
docker compose -f docker-compose.evaluation.yml down --volumes --remove-orphans
```

La respuesta inicial esperada de `GET /students` es un arreglo JSON vacio (`[]`). Solamente el proxy se publica en `127.0.0.1:18080`, evitando el puerto 8080 usado por el Compose de produccion. Los healthchecks consultan el endpoint real `/students`; no sustituyen la aplicacion por una respuesta simulada.

### Diferencias con produccion

| Aspecto | Simulacion CI/CD | Produccion |
| --- | --- | --- |
| Perfil Spring | `simulation` | perfil predeterminado |
| Base de datos | H2 en memoria | Oracle |
| Credenciales | no utiliza | variables de entorno protegidas |
| Wallet | no utiliza | montaje externo de solo lectura |
| Persistencia | H2 independiente y efimero en cada replica | Oracle persistente y compartido |
| Punto de entrada | Nginx en `127.0.0.1:18080` | microservicio en `8080` |

Este despliegue demuestra que el artefacto inicia y responde dentro de un entorno aislado, pero no reemplaza una prueba de conectividad con Oracle Wallet ni un despliegue cloud permanente. El runner es efimero y se limpia al finalizar. Las vulnerabilidades altas informadas por Trivy y la validacion real con Oracle se mantienen como limitaciones conocidas.

## Orquestacion con Docker Compose

La estrategia de IE5 utiliza Docker Compose en un unico host. El archivo principal mantiene la ejecucion con Oracle y Wallet; el archivo de evaluacion aisla la demostracion reproducible con H2.

### Servicios, redes y almacenamiento

| Configuracion | Servicio | Responsabilidad | Redes | Almacenamiento |
| --- | --- | --- | --- | --- |
| Produccion | `microservicio` | API Spring Boot conectada a Oracle | `bdget` | Wallet externo montado en `/app/wallet:ro`; los datos permanecen en Oracle |
| Evaluacion | `microservicio` (2 replicas) | API Spring Boot con perfil `simulation` | `backend`, marcada como interna | H2 en memoria, sin volumen y sin datos compartidos entre replicas |
| Evaluacion | `proxy` | Punto de entrada y balanceo HTTP | `frontend` y `backend` | Configuracion Nginx montada como solo lectura |

La red interna `backend` permite que el proxy alcance las replicas por el nombre de servicio sin exponerlas al host. La red `frontend` conecta el proxy con el puerto local. La red de produccion no es interna porque la aplicacion necesita alcanzar Oracle Cloud.

### Salud, reinicio y apagado

- El microservicio consulta `GET /students` desde el propio contenedor. El proxy consulta la misma ruta a traves del balanceador.
- `restart: unless-stopped` recupera procesos o contenedores que finalizan inesperadamente, pero respeta una detencion administrativa.
- `stop_grace_period: 25s` permite el apagado gradual de Spring Boot, cuyo timeout es de 20 segundos. Nginx dispone de 10 segundos.
- Cada replica tiene limite de 512 MiB, 1 CPU y 200 procesos. El proxy tiene 64 MiB, 0,25 CPU y 50 procesos.
- El contenedor de la aplicacion conserva el usuario no privilegiado `10001:10001`. El proxy usa `101:101`, filesystem de solo lectura y un `/tmp` efimero de 16 MiB.

En produccion, cada replica abre como maximo 10 conexiones Hikari. Antes de aumentar replicas contra Oracle se debe comprobar el limite de sesiones de la base de datos y la conectividad del Wallet.

### Escalado y verificacion

```bash
docker compose -f docker-compose.evaluation.yml up -d --no-build --scale microservicio=2
docker compose -f docker-compose.evaluation.yml ps
docker compose -f docker-compose.evaluation.yml ps -q microservicio
curl --fail http://127.0.0.1:18080/students
docker compose -f docker-compose.evaluation.yml logs --no-color proxy
```

El comando `ps -q microservicio` debe devolver dos identificadores. Varias solicitudes HTTP deben mostrar dos direcciones `upstream` en los logs del proxy. Nginx resuelve dinamicamente las replicas registradas por Docker y ofrece un unico punto de acceso.

Cada replica usa una base H2 diferente. Esta prueba demuestra escalado de computo, balanceo y disponibilidad HTTP, pero no consistencia de datos distribuida. Las operaciones de escritura no deben usarse para demostrar datos compartidos en este entorno.

### Prueba de recuperacion

Para una prueba local controlada, identifica una replica y finalizala de manera abrupta:

```bash
docker compose -f docker-compose.evaluation.yml ps -q microservicio
docker exec <id-de-una-replica> sh -c 'kill -TERM 1'
docker inspect --format='{{.RestartCount}} {{.State.Health.Status}}' <id-de-una-replica>
curl --fail http://127.0.0.1:18080/students
docker compose -f docker-compose.evaluation.yml down --volumes --remove-orphans
```

El pipeline automatiza esta comprobacion terminando el proceso Java con `SIGTERM`: verifica que el contador de reinicios aumente, que la replica vuelva a `healthy` y que la API responda durante y despues de la recuperacion. Una orden administrativa como `docker stop`, `docker kill` o `docker compose stop` no activa la politica de reinicio; Docker respeta esa detencion intencional.

Docker Compose recupera un contenedor en el mismo motor Docker y el healthcheck detecta si responde. No recupera un host completo, no redistribuye cargas entre nodos y no reemplaza un orquestador multinodo. La disponibilidad del proxy sigue siendo un punto unico de fallo en esta demostracion academica.

El `docker-compose.yml` de produccion conserva la publicacion directa `8080:8080`, por lo que esta definido para una sola instancia y `--scale microservicio=2` produciria un conflicto de puerto. El escalado queda validado exclusivamente en el entorno de evaluacion. Para trasladarlo a produccion se debe aplicar el mismo patron de punto de entrada, mantener el Wallet de solo lectura y dimensionar previamente las sesiones Oracle/Hikari; este cambio requiere validacion contra la infraestructura real.

## Declaracion de uso de herramientas de IA

El equipo debe completar esta seccion antes de la entrega, sin incluir secretos ni datos personales innecesarios:

| Campo | Declaracion del equipo |
| --- | --- |
| Herramienta utilizada | Pendiente de completar por el equipo. |
| Actividades asistidas | Pendiente de completar por el equipo. |
| Verificacion humana realizada | Pendiente de completar por el equipo. |
| Cambios aceptados, ajustados o descartados | Pendiente de completar por el equipo. |
| Reflexion individual | Cada integrante debe redactar la propia si la evaluacion lo exige. |
