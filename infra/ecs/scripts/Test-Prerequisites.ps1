[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $Region,
    [string] $ExpectedAccountId,
    [switch] $RequireDocker
)

$ErrorActionPreference = 'Stop'

foreach ($commandName in @('aws')) {
    if (-not (Get-Command $commandName -ErrorAction SilentlyContinue)) {
        throw "Required command '$commandName' is not available in PATH."
    }
}

if ($RequireDocker -and -not (Get-Command docker -ErrorAction SilentlyContinue)) {
    throw "Docker is required for image build and publication."
}

$identity = aws sts get-caller-identity --region $Region --output json | ConvertFrom-Json
if (-not $identity.Account) {
    throw 'AWS caller identity could not be determined.'
}
if ($ExpectedAccountId -and $identity.Account -ne $ExpectedAccountId) {
    throw "Authenticated AWS account '$($identity.Account)' differs from expected account '$ExpectedAccountId'."
}

if ($RequireDocker) {
    docker version | Out-Null
}

[pscustomobject]@{
    Account = $identity.Account
    Arn = $identity.Arn
    Region = $Region
    DockerChecked = [bool] $RequireDocker
}
