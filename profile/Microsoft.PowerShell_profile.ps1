Import-Module PSReadLine

Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

Set-PSReadLineOption -Colors @{
    Command   = '#61afef'
    Parameter = '#98c379'
    String    = '#e5c07b'
    Operator  = '#c678dd'
    Variable  = '#d19a66'
    Number    = '#d19a66'
    Type      = '#56b6c2'
    Comment   = '#5c6370'
    Keyword   = '#c678dd'
    Error     = '#e06c75'
}

function Get-GitPromptData {
    try {
        if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
            return $null
        }

        git rev-parse --is-inside-work-tree 2>$null | Out-Null
        if ($LASTEXITCODE -ne 0) {
            return $null
        }

        $branchName = git branch --show-current 2>$null

        if (-not $branchName) {
            $commitHash = git rev-parse --short HEAD 2>$null
            if ($commitHash) {
                $branchName = "detached:$($commitHash.Trim())"
            }
            else {
                $branchName = "detached"
            }
        }
        else {
            $branchName = $branchName.Trim()
        }

        $statusLines = @(git status --porcelain 2>$null)
        $branchLine = git status --branch --porcelain 2>$null | Select-Object -First 1

        $hasStaged = $false
        $hasUnstaged = $false
        $hasUntracked = $false
        $aheadCount = 0
        $behindCount = 0

        foreach ($statusLine in $statusLines) {
            if ($statusLine.StartsWith('??')) {
                $hasUntracked = $true
                continue
            }

            if ($statusLine.Length -lt 2) {
                continue
            }

            if ($statusLine[0] -ne ' ') {
                $hasStaged = $true
            }

            if ($statusLine[1] -ne ' ') {
                $hasUnstaged = $true
            }
        }

        if ($branchLine -match 'ahead (\d+)') {
            $aheadCount = [int]$matches[1]
        }

        if ($branchLine -match 'behind (\d+)') {
            $behindCount = [int]$matches[1]
        }

        return [pscustomobject]@{
            BranchName   = $branchName
            HasStaged    = $hasStaged
            HasUnstaged  = $hasUnstaged
            HasUntracked = $hasUntracked
            AheadCount   = $aheadCount
            BehindCount  = $behindCount
        }
    }
    catch {
        return $null
    }
}

function Get-WindowsIconColorCode {
    $colors = @(
        $PSStyle.Foreground.FromRgb('#98c379')
        $PSStyle.Foreground.FromRgb('#e06c75')
        $PSStyle.Foreground.FromRgb('#61afef')
        $PSStyle.Foreground.FromRgb('#e5c07b')
    )

    if ($null -eq $script:WindowsIconColorIndex) {
        $script:WindowsIconColorIndex = 0
    }

    $color = $colors[$script:WindowsIconColorIndex]
    $script:WindowsIconColorIndex++

    if ($script:WindowsIconColorIndex -ge $colors.Count) {
        $script:WindowsIconColorIndex = 0
    }

    return $color
}

function prompt {
    $reset = $PSStyle.Reset
    $darkGray = $PSStyle.Foreground.BrightBlack
    $cyan = $PSStyle.Foreground.BrightCyan
    $yellow = $PSStyle.Foreground.BrightYellow
    $green = $PSStyle.Foreground.BrightGreen
    $blue = $PSStyle.Foreground.BrightBlue
    $magenta = $PSStyle.Foreground.BrightMagenta
    $red = $PSStyle.Foreground.BrightRed

    $icon = "⊞"
    $iconColor = Get-WindowsIconColorCode
    $userName = [Environment]::UserName
    $computerName = $env:COMPUTERNAME
    $currentPath = (Get-Location).Path
    $gitPromptData = Get-GitPromptData

    $topLine = ""
    $topLine += "${darkGray}┌──(${reset}"
    $topLine += "${cyan}${userName}${reset}"
    $topLine += " "
    $topLine += "${iconColor}${icon}${reset}"
    $topLine += " "
    $topLine += "${cyan}${computerName}${reset}"
    $topLine += "${darkGray})-[${reset}"
    $topLine += "${yellow}${currentPath}${reset}"
    $topLine += "${darkGray}]${reset}"

    if ($gitPromptData) {
        $topLine += "${darkGray}-[${reset}"
        $topLine += "${green}$($gitPromptData.BranchName)${reset}"

        if ($gitPromptData.AheadCount -gt 0) {
            $topLine += "${blue} ↑$($gitPromptData.AheadCount)${reset}"
        }

        if ($gitPromptData.BehindCount -gt 0) {
            $topLine += "${magenta} ↓$($gitPromptData.BehindCount)${reset}"
        }

        if ($gitPromptData.HasStaged) {
            $topLine += "${green} +${reset}"
        }

        if ($gitPromptData.HasUnstaged) {
            $topLine += "${yellow} !${reset}"
        }

        if ($gitPromptData.HasUntracked) {
            $topLine += "${red} ?${reset}"
        }

        $topLine += "${darkGray}]${reset}"
    }

    $bottomLine = "${darkGray}└─`$ ${reset}"

    return "$topLine`n$bottomLine"
}

function ll {
    Get-ChildItem -Force
}

function la {
    Get-ChildItem -Force
}

function grep($pattern, $path = ".") {
    Get-ChildItem -Path $path -Recurse -File | Select-String -Pattern $pattern
}

function .. {
    Set-Location ..
}

function ... {
Set-Location ../..
}