# BDGET

## Descripción del proyecto

BDGET es un microservicio REST para la gestión de estudiantes. Expone operaciones CRUD bajo `/students` y organiza el código en las capas de controlador, servicio, repositorio y entidad.

## Tecnologías utilizadas

- Java 17
- Spring Boot 3.3.7
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
| `feature/<nombre>` | Trabajo temporal de una funcionalidad o mejora, creado desde `develop`. Ejemplos: `feature/gestion-estudiantes`, `feature/documentacion-devops`. |
| `hotfix/<nombre>` | Corrección urgente creada desde `main`. Ejemplo: `hotfix/configuracion-oracle`. |

### Otros modelos de ramificación

- **GitHub Flow:** mantiene una rama principal y ramas cortas que se integran mediante Pull Request. Es útil para despliegues frecuentes y simples.
- **Trunk-Based Development:** integra cambios muy pequeños y frecuentes directamente o casi directamente al tronco. Requiere automatización y pruebas rápidas y confiables.
- **GitFlow:** separa claramente el desarrollo, las funcionalidades y las correcciones urgentes. En este repositorio se aplica mediante las ramas descritas arriba.

> **[COMPLETAR POR EL EQUIPO: Justificación personal de la elección de GitFlow]**

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
git clone https://github.com/Tamaravalentinv/IngenieriaDevops.git
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
- Crear `hotfix/<nombre>` desde `main`, por ejemplo `hotfix/configuracion-oracle`.
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

## Configuración local

1. Copia `.env.example` como `.env` y completa las credenciales de Oracle.
2. Mantén el wallet de Oracle en `Wallet_N72BZHZWYZGTE7OH/`; este directorio no se versiona por seguridad.
3. Ejecuta el proyecto con Maven o Docker Compose.

```bash
./mvnw spring-boot:run
# o
docker compose up --build
```
