[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)] [string] $Region,
    [Parameter(Mandatory)] [string] $DashboardName,
    [Parameter(Mandatory)] [string] $Cluster,
    [Parameter(Mandatory)] [string] $Service,
    [Parameter(Mandatory)] [string] $LogGroup,
    [string] $EnvironmentName = 'production'
)

$ErrorActionPreference = 'Stop'
$cloudWatchRoot = Split-Path -Parent $PSScriptRoot
$body = Get-Content (Join-Path $cloudWatchRoot 'dashboard.template.json') -Raw
$body = $body.Replace('AWS_REGION', $Region).Replace('ECS_CLUSTER', $Cluster).Replace('ECS_SERVICE', $Service).Replace('LOG_GROUP_NAME', $LogGroup).Replace('APP_ENVIRONMENT', $EnvironmentName)
$body | ConvertFrom-Json | Out-Null

if ($PSCmdlet.ShouldProcess($DashboardName, 'Publish CloudWatch dashboard')) {
    $targetDirectory = Join-Path (Split-Path -Parent (Split-Path -Parent $cloudWatchRoot)) 'target/cloudwatch'
    New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
    $renderedPath = Join-Path $targetDirectory 'dashboard.rendered.json'
    Set-Content -Path $renderedPath -Value $body -Encoding utf8
    aws cloudwatch put-dashboard --dashboard-name $DashboardName --dashboard-body "file://$($renderedPath.Replace('\','/'))" --region $Region
    if ($LASTEXITCODE -ne 0) { throw 'CloudWatch dashboard publication failed.' }
    $renderedPath
}
