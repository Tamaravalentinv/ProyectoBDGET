[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)] [string] $Region,
    [Parameter(Mandatory)] [string] $LogGroup,
    [Parameter(Mandatory)] [string] $Service,
    [string] $EnvironmentName = 'production',
    [string] $Namespace = 'BDGET/DevOps',
    [string] $FilterName = 'bdget-application-errors'
)

$ErrorActionPreference = 'Stop'
$transform = "metricName=ApplicationErrorCount,metricNamespace=$Namespace,metricValue=1,defaultValue=0,unit=Count,dimensions={Application=bdget,Environment=$EnvironmentName,Service=$Service}"
if ($PSCmdlet.ShouldProcess($LogGroup, "Create or update metric filter '$FilterName'")) {
    aws logs put-metric-filter --log-group-name $LogGroup --filter-name $FilterName --filter-pattern '"level=ERROR"' --metric-transformations $transform --region $Region
    if ($LASTEXITCODE -ne 0) { throw 'CloudWatch Logs metric filter publication failed.' }
}
