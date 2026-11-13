[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $Region,
    [Parameter(Mandatory)] [string] $Cluster,
    [Parameter(Mandatory)] [string] $Service,
    [string] $EnvironmentName = 'production',
    [string] $MetricNamespace = 'BDGET/DevOps',
    [switch] $PublishMetrics
)

$ErrorActionPreference = 'Stop'
$serviceState = aws ecs describe-services --cluster $Cluster --services $Service --region $Region --output json | ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or -not $serviceState.services) { throw "ECS service '$Service' was not found." }
$serviceInfo = $serviceState.services[0]
$taskArns = @(aws ecs list-tasks --cluster $Cluster --service-name $Service --region $Region --query 'taskArns' --output text)

if ($PublishMetrics) {
    $available = if ($serviceInfo.runningCount -ge $serviceInfo.desiredCount -and $serviceInfo.desiredCount -gt 0) { 1 } else { 0 }
    $dimensions = "Dimensions=[{Name=Application,Value=bdget},{Name=Environment,Value=$EnvironmentName},{Name=Service,Value=$Service}]"
    aws cloudwatch put-metric-data --namespace $MetricNamespace --region $Region --metric-data "MetricName=Availability,$dimensions,Value=$available,Unit=Count" "MetricName=RunningTaskCount,$dimensions,Value=$($serviceInfo.runningCount),Unit=Count" | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Publishing ECS status metrics failed.' }
}

[pscustomobject]@{
    Cluster = $Cluster
    Service = $Service
    Status = $serviceInfo.status
    DesiredCount = $serviceInfo.desiredCount
    RunningCount = $serviceInfo.runningCount
    PendingCount = $serviceInfo.pendingCount
    TaskDefinition = $serviceInfo.taskDefinition
    Tasks = $taskArns
    LatestEvents = @($serviceInfo.events | Select-Object -First 10)
}
