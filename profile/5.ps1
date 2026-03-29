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

function prompt {
    $icon = " ⊞ "
    $userName = [Environment]::UserName
    $computerName = $env:COMPUTERNAME
    $currentPath = (Get-Location).Path
    $gitPromptData = Get-GitPromptData

    Write-Host "┌──(" -NoNewline -ForegroundColor DarkGray
    Write-Host $userName -NoNewline -ForegroundColor Cyan
    Write-Host $icon -NoNewline -ForegroundColor Cyan
    Write-Host $computerName -NoNewline -ForegroundColor Cyan
    Write-Host ")-[" -NoNewline -ForegroundColor DarkGray
    Write-Host $currentPath -NoNewline -ForegroundColor Yellow
    Write-Host "]" -NoNewline -ForegroundColor DarkGray

    if ($gitPromptData) {
        Write-Host "-[" -NoNewline -ForegroundColor DarkGray
        Write-Host $gitPromptData.BranchName -NoNewline -ForegroundColor Green

        if ($gitPromptData.AheadCount -gt 0) {
            Write-Host " ↑$($gitPromptData.AheadCount)" -NoNewline -ForegroundColor Blue
        }

        if ($gitPromptData.BehindCount -gt 0) {
            Write-Host " ↓$($gitPromptData.BehindCount)" -NoNewline -ForegroundColor Magenta
        }

        if ($gitPromptData.HasStaged) {
            Write-Host " +" -NoNewline -ForegroundColor Green
        }

        if ($gitPromptData.HasUnstaged) {
            Write-Host " !" -NoNewline -ForegroundColor Yellow
        }

        if ($gitPromptData.HasUntracked) {
            Write-Host " ?" -NoNewline -ForegroundColor Red
        }

        Write-Host "]" -NoNewline -ForegroundColor DarkGray
    }

    Write-Host ""
    Write-Host "└─$ " -NoNewline -ForegroundColor DarkGray

    return " "
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