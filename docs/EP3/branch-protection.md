# Protección de ramas

Aplicar después de una primera ejecución exitosa, porque GitHub requiere nombres de checks existentes.

Para `main` y, si el equipo lo usa como integración, `develop`:

- exigir pull request con al menos una aprobación;
- invalidar aprobaciones al agregar commits;
- exigir resolución de conversaciones;
- impedir bypass salvo cuenta de emergencia auditada;
- exigir rama actualizada antes del merge;
- exigir los checks `Build, tests and JaCoCo`, `Dependency, secret and configuration scans`, `Mandatory quality gate`, `Docker build and image security gate` y `Local availability validation`;
- bloquear force-push y eliminación;
- configurar `production` con reviewers y limitarlo a `main`.

La configuración se realiza desde Settings > Branches/Rulesets y Settings > Environments. No se automatiza desde CI porque modificar reglas del propio repositorio requiere privilegios administrativos y es un cambio de gobierno externo.

Existe un payload revisable en `.github/branch-protection.json`. Un administrador autenticado puede previsualizar y aplicar conscientemente:

```powershell
./.github/scripts/Set-BranchProtection.ps1 -WhatIf -Repository <owner/repository> -Branch main
./.github/scripts/Set-BranchProtection.ps1 -Repository <owner/repository> -Branch main
```
