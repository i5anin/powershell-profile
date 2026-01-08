function Get-GitBranchName {
    try {
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
            return $null
        }

        if (-not (git rev-parse --is-inside-work-tree 2>$null)) {
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
    $user = $env:USERNAME
    $computer = $env:COMPUTERNAME
    $path = (Get-Location).Path
    $branch = Get-GitBranchName

    $accent = Get-PromptAccentColor
    $reset = $PSStyle.Reset

    $dot = "${accent}•${reset}"
    $identity = "$($PSStyle.Foreground.BrightGreen)$user$reset@$($PSStyle.Foreground.BrightGreen)$computer$reset"
    $branchPart = if ($branch) { " $($PSStyle.Foreground.Yellow)[$branch]$reset" } else { "" }
    $pathPart = "$($PSStyle.Foreground.BrightCyan)$path$reset"

    "$dot $identity$branchPart $pathPart> "
}

