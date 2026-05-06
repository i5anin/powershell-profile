# PowerShell Profile (Windows / PowerShell 7+)

Этот репозиторий содержит профиль PowerShell (`Microsoft.PowerShell_profile.ps1`) и связанные настройки для удобной работы в терминале.

---

## 0. Установка / обновление PowerShell 7+

Официальная инструкция Microsoft Learn:
- [Установка PowerShell на Windows (актуальная версия)](https://learn.microsoft.com/ru-ru/powershell/scripting/install/install-powershell-on-windows?view=powershell-7.5)

Последний релиз PowerShell (GitHub Releases):
- [PowerShell — Releases (Latest)](https://github.com/PowerShell/PowerShell/releases/latest)

Список всех релизов (если нужно выбрать конкретную версию вручную):
- [PowerShell — Releases](https://github.com/PowerShell/PowerShell/releases)


## 1. Где находится профиль PowerShell 7+

PowerShell сам показывает **ожидаемый путь** к профилю:

```powershell
$PROFILE
```

Обычно для `PowerShell` 7+ это:
```powershell
%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

Папка профиля:
```powershell
%USERPROFILE%\Documents\PowerShell
```

Разблокировать профиль
```powershell
Unblock-File -Path $PROFILE
```

Отключить обновления
```powershell
[System.Environment]::SetEnvironmentVariable('POWERSHELL_UPDATECHECK', 'Off', 'Machine')
```

Последний релиз PowerShell (GitHub Releases):
- [PowerShell — Releases (Latest)](https://github.com/PowerShell/PowerShell/releases/latest)

