<#
.SYNOPSIS
    Builds the Windows installer from an existing `flutter build windows --release` output.

.PARAMETER Version
    Version embedded in the installer and its file name (e.g. 1.0.0).

.NOTES
    Run from the repository root. The installer is written to the repository root as
    gift-card-front-<Version>-windows-x64-setup.exe.
    Inno Setup is used if installed, otherwise installed with Chocolatey (present on GitHub runners).
#>
param(
    [Parameter(Mandatory = $true)]
    [string] $Version,

    # Pinned so a new Inno Setup release cannot change the build output unnoticed.
    # Only used when Inno Setup has to be installed (it is not on a developer machine or runner by default).
    [string] $InnoSetupVersion = '6.7.3'
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Find-Iscc {
    $command = Get-Command iscc -ErrorAction SilentlyContinue
    if ($command) { return $command.Source }

    $candidates = @(
        "${env:ProgramFiles(x86)}\Inno Setup 6\ISCC.exe",
        "${env:ProgramFiles}\Inno Setup 6\ISCC.exe",
        "${env:LOCALAPPDATA}\Programs\Inno Setup 6\ISCC.exe"
    )
    return $candidates | Where-Object { Test-Path $_ } | Select-Object -First 1
}

$iscc = Find-Iscc
if (-not $iscc) {
    choco install innosetup --version $InnoSetupVersion --no-progress -y
    if ($LASTEXITCODE -ne 0) {
        throw "Chocolatey could not install Inno Setup $InnoSetupVersion (exit code $LASTEXITCODE)."
    }
    $iscc = Find-Iscc
}
if (-not $iscc) {
    throw 'Inno Setup (ISCC.exe) not found and could not be installed.'
}

& $iscc "/DAppVersion=$Version" installer/windows/setup.iss
if ($LASTEXITCODE -ne 0) {
    throw "Inno Setup failed with exit code $LASTEXITCODE"
}

# Same location as the other OS packages, so every artifact has the same flat layout.
Move-Item -Force "dist/gift-card-front-$Version-windows-x64-setup.exe" .
