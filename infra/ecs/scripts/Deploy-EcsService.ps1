[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)] [string] $Region,
    [Parameter(Mandatory)] [string] $Cluster,
    [Parameter(Mandatory)] [string] $Service,
    [Parameter(Mandatory)] [string] $TaskFamily,
    [Parameter(Mandatory)] [string] $ImageDigestUri,
    [Parameter(Mandatory)] [string] $ExecutionRoleArn,
    [Parameter(Mandatory)] [string] $TaskRoleArn,
    [Parameter(Mandatory)] [string] $OracleSecretArn,
    [Parameter(Mandatory)] [string] $LogGroup,
    [Parameter(Mandatory)] [string[]] $SubnetIds,
    [Parameter(Mandatory)] [string[]] $SecurityGroupIds,
    [Parameter(Mandatory)] [string] $EfsFileSystemId,
    [Parameter(Mandatory)] [string] $EfsAccessPointId,
    [Parameter(Mandatory)] [string] $CorsAllowedOrigins,
    [ValidateSet('256','512','1024','2048','4096','8192','16384')] [string] $Cpu = '512',
    [ValidateRange(512, 122880)] [int] $Memory = 1024,
    [ValidateRange(1, 100)] [int] $DesiredCount = 2,
    [ValidateRange(1, 65535)] [int] $ContainerPort = 8080,
    [ValidateSet('ENABLED','DISABLED')] [string] $AssignPublicIp = 'DISABLED',
    [string] $EnvironmentName = 'production',
    [string] $TargetGroupArn,
    [string] $MetricNamespace = 'BDGET/DevOps',
    [switch] $CreateLogGroup
)

$ErrorActionPreference = 'Stop'
$startedAt = [DateTimeOffset]::UtcNow
$scriptRoot = Split-Path -Parent $PSScriptRoot
$targetDirectory = Join-Path (Split-Path -Parent (Split-Path -Parent $scriptRoot)) 'target/deployment'
New-Item -ItemType Directory -Path $targetDirectory -Force | Out-Null
$taskOutput = Join-Path $targetDirectory 'task-definition.rendered.json'
$serviceOutput = Join-Path $targetDirectory 'service.rendered.json'

if ($ImageDigestUri -notmatch '@sha256:[0-9a-f]{64}$') {
    throw 'ImageDigestUri must be immutable and end with @sha256:<64 hexadecimal characters>.'
}

$clusterStatus = aws ecs describe-clusters --clusters $Cluster --region $Region --query 'clusters[0].status' --output text
if ($LASTEXITCODE -ne 0 -or $clusterStatus -ne 'ACTIVE') {
    throw "ECS cluster '$Cluster' does not exist or is not ACTIVE. Provision it explicitly before deployment."
}

aws logs describe-log-groups --log-group-name-prefix $LogGroup --region $Region --query "logGroups[?logGroupName=='$LogGroup'].logGroupName" --output text | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'CloudWatch Logs lookup failed.' }
$matchingLogGroup = aws logs describe-log-groups --log-group-name-prefix $LogGroup --region $Region --query "logGroups[?logGroupName=='$LogGroup'].logGroupName | [0]" --output text
if ($matchingLogGroup -ne $LogGroup) {
    if (-not $CreateLogGroup) { throw "Log group '$LogGroup' is missing. Re-run with -CreateLogGroup after authorization." }
    if ($PSCmdlet.ShouldProcess($LogGroup, 'Create CloudWatch Logs log group')) {
        aws logs create-log-group --log-group-name $LogGroup --region $Region
        if ($LASTEXITCODE -ne 0) { throw 'Log group creation failed.' }
        aws logs put-retention-policy --log-group-name $LogGroup --retention-in-days 30 --region $Region
        if ($LASTEXITCODE -ne 0) { throw 'Log retention configuration failed.' }
    }
}

$task = Get-Content (Join-Path $scriptRoot 'task-definition.template.json') -Raw | ConvertFrom-Json
$task.family = $TaskFamily
$task.taskRoleArn = $TaskRoleArn
$task.executionRoleArn = $ExecutionRoleArn
$task.cpu = $Cpu
$task.memory = [string] $Memory
$container = $task.containerDefinitions[0]
$container.image = $ImageDigestUri
$container.portMappings[0].containerPort = $ContainerPort
$container.portMappings[0].hostPort = $ContainerPort
$container.environment[0].value = $EnvironmentName
$container.environment[2].value = $CorsAllowedOrigins
$container.secrets[0].valueFrom = "${OracleSecretArn}:url::"
$container.secrets[1].valueFrom = "${OracleSecretArn}:username::"
$container.secrets[2].valueFrom = "${OracleSecretArn}:password::"
$container.healthCheck.command[1] = "curl --fail --silent --show-error http://localhost:$ContainerPort/actuator/health/liveness || exit 1"
$container.logConfiguration.options.'awslogs-group' = $LogGroup
$container.logConfiguration.options.'awslogs-region' = $Region
$task.volumes[0].efsVolumeConfiguration.fileSystemId = $EfsFileSystemId
$task.volumes[0].efsVolumeConfiguration.authorizationConfig.accessPointId = $EfsAccessPointId
$task | ConvertTo-Json -Depth 20 | Set-Content -Path $taskOutput -Encoding utf8

if (-not $PSCmdlet.ShouldProcess($TaskFamily, 'Register ECS task definition and update service')) { return }
$taskDefinitionArn = aws ecs register-task-definition --cli-input-json "file://$($taskOutput.Replace('\','/'))" --region $Region --query 'taskDefinition.taskDefinitionArn' --output text
if ($LASTEXITCODE -ne 0 -or $taskDefinitionArn -notmatch '^arn:') { throw 'Task definition registration failed.' }

$serviceDefinition = Get-Content (Join-Path $scriptRoot 'service.template.json') -Raw | ConvertFrom-Json
$serviceDefinition.cluster = $Cluster
$serviceDefinition.serviceName = $Service
$serviceDefinition.taskDefinition = $taskDefinitionArn
$serviceDefinition.desiredCount = $DesiredCount
$serviceDefinition.networkConfiguration.awsvpcConfiguration.subnets = @($SubnetIds)
$serviceDefinition.networkConfiguration.awsvpcConfiguration.securityGroups = @($SecurityGroupIds)
$serviceDefinition.networkConfiguration.awsvpcConfiguration.assignPublicIp = $AssignPublicIp
if ($TargetGroupArn) {
    $serviceDefinition | Add-Member -NotePropertyName loadBalancers -NotePropertyValue @(
        [pscustomobject]@{ targetGroupArn = $TargetGroupArn; containerName = 'bdget'; containerPort = $ContainerPort }
    )
}
$serviceDefinition | ConvertTo-Json -Depth 20 | Set-Content -Path $serviceOutput -Encoding utf8

$serviceStatus = aws ecs describe-services --cluster $Cluster --services $Service --region $Region --query 'services[0].status' --output text
if ($LASTEXITCODE -ne 0) { throw 'ECS service lookup failed.' }
if ($serviceStatus -eq 'ACTIVE') {
    $updateArguments = @('ecs', 'update-service', '--cluster', $Cluster, '--service', $Service, '--task-definition', $taskDefinitionArn, '--desired-count', $DesiredCount, '--force-new-deployment', '--region', $Region)
    if ($TargetGroupArn) {
        $updateArguments += @('--load-balancers', "targetGroupArn=$TargetGroupArn,containerName=bdget,containerPort=$ContainerPort")
    }
    aws @updateArguments | Out-Null
} else {
    aws ecs create-service --cli-input-json "file://$($serviceOutput.Replace('\','/'))" --region $Region | Out-Null
}
if ($LASTEXITCODE -ne 0) { throw 'ECS service create/update failed.' }

aws ecs wait services-stable --cluster $Cluster --services $Service --region $Region
if ($LASTEXITCODE -ne 0) { throw 'ECS service did not become stable. The deployment circuit breaker may roll it back.' }

$durationSeconds = ([DateTimeOffset]::UtcNow - $startedAt).TotalSeconds
aws cloudwatch put-metric-data --namespace $MetricNamespace --region $Region --metric-data "MetricName=DeploymentDuration,Dimensions=[{Name=Application,Value=bdget},{Name=Environment,Value=$EnvironmentName},{Name=Service,Value=$Service}],Value=$durationSeconds,Unit=Seconds" | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Deployment succeeded, but publishing its duration metric failed.' }

[pscustomobject]@{
    TaskDefinitionArn = $taskDefinitionArn
    Service = $Service
    DurationSeconds = [Math]::Round($durationSeconds, 3)
    RenderedTaskDefinition = $taskOutput
    RenderedService = $serviceOutput
}
