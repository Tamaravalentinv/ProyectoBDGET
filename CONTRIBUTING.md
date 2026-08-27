# Guía de contribución

## Antes de comenzar

Actualiza `develop` y crea una rama desde ella para una nueva funcionalidad:

```bash
git switch develop
git pull origin develop
git switch -c feature/nombre-del-cambio
```

Para una corrección urgente, parte desde `main` con `hotfix/nombre-del-arreglo`.

## Commits y Pull Requests

- Usa Conventional Commits, por ejemplo `docs: actualiza guía de contribución`.
- Mantén un cambio acotado por commit siempre que sea posible.
- Publica la rama y abre un Pull Request hacia `develop` para una feature o hacia `main` para un hotfix.
- Describe qué cambió, cómo se verificó y cualquier configuración requerida.
- Revisa el workflow, el diff y los comentarios antes de hacer merge.

## Buenas prácticas

- No subas secretos, `.env` ni wallets de base de datos.
- No trabajes directamente en `main`.
- Mantén las pruebas y documentación relacionadas actualizadas.
- Elimina la rama remota únicamente después de integrar el Pull Request.
