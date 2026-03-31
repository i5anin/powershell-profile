function prompt {
    $reset = $PSStyle.Reset
    $darkGray = $PSStyle.Foreground.BrightBlack
    $cyan = $PSStyle.Foreground.BrightCyan
    $yellow = $PSStyle.Foreground.BrightYellow
    $green = $PSStyle.Foreground.BrightGreen
    $blue = $PSStyle.Foreground.BrightBlue
    $magenta = $PSStyle.Foreground.BrightMagenta
    $red = $PSStyle.Foreground.BrightRed

    $icon = "•"
    $iconColor = Get-WindowsIconColorCode
    $userName = [Environment]::UserName
    $computerName = $env:COMPUTERNAME
    $currentPath = (Get-Location).Path
    $gitPromptData = Get-GitPromptData

    $topLine = ""
    $topLine += "${darkGray}┌──(${reset}"
    $topLine += "${cyan}${userName}${reset}"
    $topLine += "${iconColor}${icon}${reset}"
    $topLine += "${cyan}${computerName}${reset}"
    $topLine += "${darkGray})-[${reset}"
    $topLine += "${yellow}${currentPath}${reset}"
    $topLine += "${darkGray}]${reset}"

    if ($gitPromptData) {
        $topLine += "${darkGray}-[${reset}"
        $topLine += "${green}$($gitPromptData.BranchName)${reset}"

        if ($gitPromptData.AheadCount -gt 0) {
            $topLine += "${blue}↑$($gitPromptData.AheadCount)${reset}"
        }

        if ($gitPromptData.BehindCount -gt 0) {
            $topLine += "${magenta}↓$($gitPromptData.BehindCount)${reset}"
        }

        if ($gitPromptData.HasStaged) {
            $topLine += "${green}+${reset}"
        }

        if ($gitPromptData.HasUnstaged) {
            $topLine += "${yellow}!${reset}"
        }

        if ($gitPromptData.HasUntracked) {
            $topLine += "${red}?${reset}"
        }

        $topLine += "${darkGray}]${reset}"
    }

    $bottomLine = "${darkGray}└─`$ ${reset}"

    return "$topLine`n$bottomLine"
}