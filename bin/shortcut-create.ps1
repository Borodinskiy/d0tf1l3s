# Указывается как аргумент к скрипту, т. е. -appsDir "D:\programs"
param (
	[string]$appsDir,
	[string]$appName,
	[string]$appExt = "exe",
	[string]$saveTo = "desktop"
)

# Определение пути до exe-файла
$targetPath = "$appsDir\$appName\$appName.$appExt"

# Определение пути для создания ярлыка на рабочем столе
$shortcutDir = ""

# -eq =
# -ne !=
# -lt <
# -le <=
# -gt >
# -ge >=

switch ($saveTo) {
	"start" {
		$shortcutDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
	}
	"commonStart" {
		$shortcutDir = "$env:ProgramData\Microsoft\Windows\Start Menu\Programs"
	}
	Default {
		$shortcutDir = "$env:USERPROFILE\Desktop"
		if ($saveTo -ne "desktop") {
			Write-Output "Неверное значение saveTo '$saveTo', допустимо:"
			Write-Output "	start"
			Write-Output "	commonStart"
			Write-Output "	desktop"
		}
	}
}

$shortcutPath = "$shortcutDir\$appName.lnk"

# Создание объекта Shell
$shell = New-Object -ComObject WScript.Shell

# Создание ярлыка
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $targetPath
$shortcut.Save()

Write-Output "Ярлык создан: $shortcutPath ==> $targetPath"
