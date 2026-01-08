function prompt {
    $path = Get-Location

    # Однократный выбор цвета при запуске PowerShell
    if (-not $global:PromptColor) {
        $colors = @("Cyan", "Magenta", "Green", "Yellow", "Blue")
        $global:PromptColor = Get-Random -InputObject $colors
    }

    # Добавить ПУСТУЮ строку перед каждой новой командой
    Write-Host ""

    # Цветная точка
    Write-Host "●" -ForegroundColor $global:PromptColor -NoNewline

    # Git-ветка (если в репозитории)
    if (git rev-parse --is-inside-work-tree 2>$null) {
        try {
            $branchName = git rev-parse --abbrev-ref HEAD 2>$null
            if ($branchName) {
                Write-Host " [$branchName]" -ForegroundColor Yellow -NoNewline
            }
        } catch { }
    }

    # Путь и стрелка
    return " $path> "
}