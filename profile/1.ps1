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

function prompt {
    $userName = [Environment]::UserName
    $computerName = $env:COMPUTERNAME
    $currentPath = (Get-Location).Path

    Write-Host "┌──(" -NoNewline -ForegroundColor DarkGray
    Write-Host "$userName@$computerName" -NoNewline -ForegroundColor Cyan
    Write-Host ")-[" -NoNewline -ForegroundColor DarkGray
    Write-Host $currentPath -NoNewline -ForegroundColor Yellow
    Write-Host "]" -ForegroundColor DarkGray

    Write-Host "└─$ " -NoNewline -ForegroundColor DarkGray

    return ' '
}

function ll {
    Get-ChildItem -Force
}

function la {
    Get-ChildItem -Force
}

function grep($pattern, $path = '.') {
    Get-ChildItem -Path $path -Recurse -File | Select-String -Pattern $pattern
}

function .. {
    Set-Location ..
}

function ... {
    Set-Location ../..
}