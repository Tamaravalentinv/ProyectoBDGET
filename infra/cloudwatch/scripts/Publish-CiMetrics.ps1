[CmdletBinding(SupportsShouldProcess)]
param(
    [Parameter(Mandatory)] [string] $Region,
    [Parameter(Mandatory)] [string] $JacocoXmlPath,
    [Parameter(Mandatory)] [ValidateSet(0, 1)] [int] $CiValidationSuccess,
    [Parameter(Mandatory)] [string] $Service,
    [string] $EnvironmentName = 'production',
    [string] $Namespace = 'BDGET/DevOps'
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $JacocoXmlPath -PathType Leaf)) { throw "JaCoCo XML not found: $JacocoXmlPath" }
[xml] $report = Get-Content -LiteralPath $JacocoXmlPath -Raw
$lineCounter = $report.report.counter | Where-Object { $_.type -eq 'LINE' } | Select-Object -First 1
if (-not $lineCounter) { throw 'JaCoCo XML does not contain a report-level LINE counter.' }
$covered = [double] $lineCounter.covered
$total = $covered + [double] $lineCounter.missed
if ($total -le 0) { throw 'JaCoCo line counter is empty.' }
$coveragePercent = [Math]::Round(($covered / $total) * 100, 4)
$dimensions = "Dimensions=[{Name=Application,Value=bdget},{Name=Environment,Value=$EnvironmentName},{Name=Service,Value=$Service}]"

if ($PSCmdlet.ShouldProcess($Namespace, 'Publish real CI and JaCoCo metrics')) {
    aws cloudwatch put-metric-data --namespace $Namespace --region $Region --metric-data "MetricName=JacocoLineCoverage,$dimensions,Value=$coveragePercent,Unit=Percent" "MetricName=CiValidationSuccess,$dimensions,Value=$CiValidationSuccess,Unit=Count"
    if ($LASTEXITCODE -ne 0) { throw 'CloudWatch CI metric publication failed.' }
}

[pscustomobject]@{ JacocoLineCoverage = $coveragePercent; CiValidationSuccess = $CiValidationSuccess }
