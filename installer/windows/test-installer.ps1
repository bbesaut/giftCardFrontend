<#
.SYNOPSIS
    Smoke test of the Windows installer: silent install, checks, silent uninstall, checks.

.PARAMETER Version
    Version of the installer to test (the one passed to build-installer.ps1).

.NOTES
    Run from the repository root, after build-installer.ps1. Installs for the current user into
    a temporary folder, so it needs no admin rights and leaves nothing behind.
    Fails (non-zero exit) on the first broken expectation.
#>
param(
    [Parameter(Mandatory = $true)]
    [string] $Version
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$setup = "gift-card-front-$Version-windows-x64-setup.exe"
if (-not (Test-Path $setup)) {
    throw "Installer not found: $setup"
}

# Single source of truth for the application id: the installer script itself.
$appIdMatch = Select-String -Path installer/windows/setup.iss -Pattern '^AppId=\{\{([0-9A-Fa-f-]+)\}'
if (-not $appIdMatch) {
    throw 'AppId not found in installer/windows/setup.iss'
}
$appId = $appIdMatch.Matches[0].Groups[1].Value

function Assert-That([bool] $Condition, [string] $Message) {
    if (-not $Condition) { throw "Installer check failed: $Message" }
    Write-Host "ok: $Message"
}

function Get-UninstallEntry {
    # Inno Setup names the key "{AppId}_is1".
    Get-ChildItem 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall' |
        Where-Object { $_.PSChildName -like "*$appId*" }
}

$installDir = Join-Path ([IO.Path]::GetTempPath()) "gcf-installer-test-$([guid]::NewGuid())"
$silent = @('/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART')

try {
    $install = Start-Process (Resolve-Path $setup) -Wait -PassThru `
        -ArgumentList ($silent + '/CURRENTUSER', "/DIR=`"$installDir`"")
    Assert-That ($install.ExitCode -eq 0) 'installer exits with code 0'
    Assert-That (Test-Path "$installDir\gift_card_front.exe") 'application executable is installed'
    Assert-That (Test-Path "$installDir\unins000.exe") 'uninstaller is installed'

    $entry = Get-UninstallEntry
    Assert-That ($null -ne $entry) 'uninstall entry is registered'
    $props = Get-ItemProperty $entry.PSPath
    Assert-That ($props.DisplayVersion -eq $Version) "registered version is $Version"

    $uninstall = Start-Process "$installDir\unins000.exe" -Wait -PassThru -ArgumentList $silent
    Assert-That ($uninstall.ExitCode -eq 0) 'uninstaller exits with code 0'
    Assert-That (-not (Test-Path "$installDir\gift_card_front.exe")) 'application executable is removed'
    Assert-That ($null -eq (Get-UninstallEntry)) 'uninstall entry is removed'
}
finally {
    # Never leave a registered test install behind if an assertion failed halfway.
    if ((Get-UninstallEntry) -and (Test-Path "$installDir\unins000.exe")) {
        Start-Process "$installDir\unins000.exe" -Wait -ArgumentList $silent
    }
    Remove-Item $installDir -Recurse -Force -ErrorAction SilentlyContinue
}
