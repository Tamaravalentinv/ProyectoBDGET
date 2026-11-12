[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)] [string] $Region,
    [Parameter(Mandatory)] [string] $Cluster,
    [Parameter(Mandatory)] [string] $Service,
    [string] $TaskDefinitionArn
)

$ErrorActionPreference = 'Stop'
$serviceState = aws ecs describe-services --cluster $Cluster --services $Service --region $Region --output json | ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or -not $serviceState.services) { throw "ECS service '$Service' was not found." }
$currentTaskDefinition = $serviceState.services[0].taskDefinition

if (-not $TaskDefinitionArn) {
    $family = ($currentTaskDefinition -split '/')[-1] -replace ':\d+$', ''
    $revisions = @(aws ecs list-task-definitions --family-prefix $family --sort DESC --region $Region --query 'taskDefinitionArns' --output text) -split '\s+'
    $TaskDefinitionArn = $revisions | Where-Object { $_ -and $_ -ne $currentTaskDefinition } | Select-Object -First 1
}
if (-not $TaskDefinitionArn -or $TaskDefinitionArn -eq $currentTaskDefinition) {
    throw 'No prior task definition was found. Supply -TaskDefinitionArn explicitly after reviewing its configuration.'
}

if ($PSCmdlet.ShouldProcess($Service, "Roll back from '$currentTaskDefinition' to '$TaskDefinitionArn'")) {
    aws ecs update-service --cluster $Cluster --service $Service --task-definition $TaskDefinitionArn --force-new-deployment --region $Region | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Rollback update failed.' }
    aws ecs wait services-stable --cluster $Cluster --services $Service --region $Region
    if ($LASTEXITCODE -ne 0) { throw 'Rolled-back service did not become stable.' }
}

[pscustomobject]@{ Previous = $currentTaskDefinition; Active = $TaskDefinitionArn }
