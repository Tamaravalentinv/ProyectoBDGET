BeforeAll {
    $script:targetScript = Join-Path $PSScriptRoot '../../../.github/scripts/Set-BranchProtection.ps1'
    $global:fakeGhExitCode = 0
    $global:ghCalls = 0

    function global:gh {
        $null = @($input)
        $global:ghCalls++
        Set-Variable -Name LASTEXITCODE -Scope 1 -Value $global:fakeGhExitCode
    }
}

AfterAll {
    Remove-Item Function:\gh -ErrorAction SilentlyContinue
    Remove-Variable fakeGhExitCode, ghCalls -Scope Global -ErrorAction SilentlyContinue
}

Describe 'Set-BranchProtection.ps1' {
    BeforeEach {
        $global:fakeGhExitCode = 0
        $global:ghCalls = 0
    }

    It 'validates the owner/repository format' {
        { & $script:targetScript -Repository 'invalid' } | Should -Throw
    }

    It 'validates the supported branch names' {
        { & $script:targetScript -Repository 'owner/repository' -Branch 'feature' } | Should -Throw
    }

    It 'fails clearly when GitHub CLI is unavailable' {
        Mock Get-Command { $null } -ParameterFilter { $Name -eq 'gh' }
        { & $script:targetScript -Repository 'owner/repository' } | Should -Throw 'GitHub CLI (gh) is required.'
    }

    It 'does not invoke GitHub CLI when WhatIf is active' {
        & $script:targetScript -Repository 'owner/repository' -Branch main -WhatIf
        $global:ghCalls | Should -Be 0
    }

    It 'applies the reviewed policy through GitHub CLI' {
        & $script:targetScript -Repository 'owner/repository' -Branch develop -Confirm:$false
        $global:ghCalls | Should -BeGreaterThan 0
    }

    It 'fails when GitHub CLI reports an error' {
        $global:fakeGhExitCode = 1
        { & $script:targetScript -Repository 'owner/repository' -Confirm:$false } | Should -Throw 'GitHub branch protection update failed.'
    }
}
