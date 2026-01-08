Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($PSStyle) {
    $PSStyle.FileInfo.Directory = $PSStyle.Foreground.BrightBlue
}

Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -BellStyle None

Set-Alias ll Get-ChildItem
Set-Alias la "Get-ChildItem -Force"

function Get-GitBranchName {
    try {
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
            return $null
        }

        $isRepo = git rev-parse --is-inside-work-tree 2>$null
        if (-not $isRepo) {
            return $null
        }

        $branchName = git symbolic-ref --short HEAD 2>$null
        if ($branchName) {
            return $branchName.Trim()
        }

        $commitHash = git rev-parse --short HEAD 2>$null
        if ($commitHash) {
            return "detached:$($commitHash.Trim())"
        }

        return "detached"
    } catch {
        return $null
    }
}

function Get-PromptAccentColor {
    if (-not $script:PromptAccentColor) {
        $colors = @(
            $PSStyle.Foreground.BrightCyan,
            $PSStyle.Foreground.BrightMagenta,
            $PSStyle.Foreground.BrightGreen,
            $PSStyle.Foreground.BrightYellow,
            $PSStyle.Foreground.BrightBlue
        )
        $script:PromptAccentColor = Get-Random -InputObject $colors
    }
    return $script:PromptAccentColor
}

function prompt {
    $path = Get-Location
    $branch = Get-GitBranchName

    $accent = if ($PSStyle) { Get-PromptAccentColor } else { "" }
    $reset = if ($PSStyle) { $PSStyle.Reset } else { "" }

    $dot = if ($PSStyle) { "${accent}●${reset}" } else { "●" }
    $branchPart = if ($branch) { " $($PSStyle.Foreground.Yellow)[$branch]$reset" } else { "" }

    "`n$dot$branchPart $($PSStyle.Foreground.BrightCyan)$path$reset> "
}
