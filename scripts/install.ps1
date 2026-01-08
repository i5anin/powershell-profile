Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-RepoRootPath {
    $scriptDir = Split-Path -Parent $PSCommandPath
    return (Resolve-Path (Join-Path $scriptDir "..")).Path
}

function Get-SourceProfilePath {
    $repoRoot = Resolve-RepoRootPath
    $sourcePath = Join-Path $repoRoot "profile\Microsoft.PowerShell_profile.ps1"
    if (-not (Test-Path $sourcePath)) {
        throw "Source profile file not found: $sourcePath"
    }
    return $sourcePath
}

function Ensure-DirectoryExists([string]$path) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Force -Path $path | Out-Null
    }
}

function Backup-ExistingProfile([string]$profilePath) {
    if (-not (Test-Path $profilePath)) {
        return $null
    }

    $timestamp = Get-Date -Format "yyyyMMdd-HHmmss"
    $backupPath = "$profilePath.bak.$timestamp"
    Copy-Item -Path $profilePath -Destination $backupPath -Force
    return $backupPath
}

function Install-Profile {
    $sourceProfile = Get-SourceProfilePath
    $targetProfile = $PROFILE
    $targetDir = Split-Path -Parent $targetProfile

    Ensure-DirectoryExists $targetDir

    $backup = Backup-ExistingProfile $targetProfile

    Copy-Item -Path $sourceProfile -Destination $targetProfile -Force

    . $targetProfile

    [pscustomobject]@{
        SourceProfile = $sourceProfile
        TargetProfile = $targetProfile
        TargetFolder  = $targetDir
        BackupCreated = $backup
        ProfileExists = (Test-Path $targetProfile)
        PowerShellExe = (Get-Command pwsh).Source
        PowerShellVer = $PSVersionTable.PSVersion.ToString()
    }
}

$result = Install-Profile
$result | Format-List
