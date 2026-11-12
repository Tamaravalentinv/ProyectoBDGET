[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $Region,
    [Parameter(Mandatory)] [string] $LogGroup,
    [ValidatePattern('^\d+[smhdw]$')] [string] $Since = '1h',
    [string] $FilterPattern,
    [switch] $Follow
)

$ErrorActionPreference = 'Stop'
$arguments = @('logs', 'tail', $LogGroup, '--region', $Region, '--since', $Since, '--format', 'short')
if ($FilterPattern) { $arguments += @('--filter-pattern', $FilterPattern) }
if ($Follow) { $arguments += '--follow' }
aws @arguments
if ($LASTEXITCODE -ne 0) { throw 'CloudWatch Logs query failed.' }
