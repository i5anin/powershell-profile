Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$PSStyle.FileInfo.Directory = $PSStyle.Foreground.BrightBlue

function prompt {
    $path = $(Get-Location)
    "$($PSStyle.Foreground.BrightGreen)PS$($PSStyle.Reset) $($PSStyle.Foreground.BrightCyan)$path$($PSStyle.Reset)> "
}

Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -HistoryNoDuplicates
Set-PSReadLineOption -BellStyle None

Set-Alias ll Get-ChildItem
Set-Alias la "Get-ChildItem -Force"
