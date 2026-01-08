**Назначение:**

* `profile/` — ваш PowerShell профиль
* `terminal/` — настройки Windows Terminal
* `scripts/` — автоматизация (установка/обновление)
* `fonts/` — если используете Nerd Font (часто нужно для иконок)

---

# Стандартный PowerShell профиль (настройки консоли)

## Файл профиля

Имя файла **должно быть именно таким**:

✅ `Microsoft.PowerShell_profile.ps1`

### Минимальный “стандартный профиль” 2025 (без мусора)

```powershell
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
```

**Что это даёт:**

* строгий режим (ловит ошибки)
* безопасное поведение (`Stop`)
* современный PSReadLine
* аккуратный prompt
* стандартные alias

---

# Куда положить файл профиля (важно)

В PowerShell есть несколько “профилей”, но стандартный для пользователя (самый нужный):

✅ **Путь для PowerShell 7+ (pwsh):**

```text
%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

✅ Пример (реальный):

```text
C:\Users\<USER>\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

---

## Проверить путь в PowerShell

В консоли выполните:

```powershell
$PROFILE
```

И получите точный путь, куда PowerShell ожидает файл профиля.

---

## Если папки нет — создать

```powershell
New-Item -ItemType Directory -Force -Path (Split-Path $PROFILE)
New-Item -ItemType File -Force -Path $PROFILE
```

---

# Как обновить PowerShell до 7+ (Windows)

## Вариант A (рекомендованный): через WinGet

Откройте **Windows Terminal / PowerShell** от обычного пользователя:

```powershell
winget install --id Microsoft.PowerShell --source winget
```

Если уже установлен:

```powershell
winget upgrade --id Microsoft.PowerShell
```

---

## Вариант B: через Microsoft Store

* Открыть Microsoft Store
* Найти **PowerShell**
* Установить / Обновить

---

## Проверка версии

```powershell
$PSVersionTable.PSVersion
```

Нужно увидеть **Major >= 7**.

---

# 6) Как сделать так, чтобы профиль работал в PowerShell 7+

## 1) Откройте PowerShell 7 (pwsh)

Команда запуска:

```powershell
pwsh
```

## 2) Проверьте профиль:

```powershell
Test-Path $PROFILE
```

Если `False` — значит файл не там.

## 3) Создайте и откройте:

```powershell
New-Item -ItemType File -Force -Path $PROFILE
notepad $PROFILE
```

Вставьте содержимое профиля → сохраните.

---

# 7) Где лежат настройки Windows Terminal

Если вы настраиваете внешний вид терминала (шрифты, цветовые схемы):

✅ Настройки Windows Terminal лежат тут:

```text
%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

---

# 8) Итог: краткий чеклист

✅ Git repo name: `powershell-profile`
✅ PowerShell 7 установить: `winget install --id Microsoft.PowerShell`
✅ Профиль положить сюда:

```text
%USERPROFILE%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1
```

✅ Проверить путь:

```powershell
$PROFILE
```

---

Если хочешь — я могу:

1. Сгенерировать **идеальный `README.md`** под этот репозиторий (с установкой одной командой)
2. Сделать `scripts/install.ps1`, который **сам скопирует профиль в нужное место**, поставит PSReadLine/модули и проверит зависимости.
