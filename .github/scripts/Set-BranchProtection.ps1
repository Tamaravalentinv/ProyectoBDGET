[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)] [ValidatePattern('^[^/]+/[^/]+$')] [string] $Repository,
    [ValidateSet('main', 'develop')] [string] $Branch = 'main'
)

$ErrorActionPreference = 'Stop'
if (-not (Get-Command gh -ErrorAction SilentlyContinue)) { throw 'GitHub CLI (gh) is required.' }
$configuration = Join-Path (Split-Path -Parent $PSScriptRoot) 'branch-protection.json'
if ($PSCmdlet.ShouldProcess("$Repository/$Branch", 'Apply GitHub branch protection')) {
    Get-Content -LiteralPath $configuration -Raw | gh api --method PUT -H 'Accept: application/vnd.github+json' "/repos/$Repository/branches/$Branch/protection" --input -
    if ($LASTEXITCODE -ne 0) { throw 'GitHub branch protection update failed.' }
}
