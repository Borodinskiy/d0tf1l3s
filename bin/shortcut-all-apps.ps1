# Automatic shortcut creation for programs in categorized directory format.

# If you already have file with shortcuts, provide it by -fromFile "abc.txt" argument
param (
	[string]$fromFile = ""
)

# Where resulting shortcuts target paths will be saved
$saveFileName = "shortcuts.txt"

# TODO Custom rules for executables
$appRules = @(
	  @("syncthing.exe", "arguments", "--no-console --no-browser")
	, @("repkg.exe" , "skipShortcut")
	, @("unis000.exe", "skipExe")
	, @("unis001.exe", "skipExe")
	, @("unis002.exe", "skipExe")
	, @("unis003.exe", "skipExe")
	, @("unis004.exe", "skipExe")
	, @("unis005.exe", "skipExe")
	, @("unis006.exe", "skipExe")
	, @("unis007.exe", "skipExe")
	, @("BmLauncher.exe", "skipExe")
)

# Root directories, where programs located
$appsRoots = "C:\Programs", "D:\programs", "G:\programs", "P:"

# This is just for easier program grouping. Script searches data only in this dirs
$appsCategories = "emulators", "games", "multimedia", "util", "util-system"

# Subdirs in program's directory folder. Some apps store it's executables here
$binDirs = "", "bin", "bin\x64", "bin\64bit", "bin\x86", "bin\32bit", "bin\x32", "system", "Binaries"

# Array where all resulting shortcuts will go
$shortcutTargets = @()

function Check-AppRule {
param(
		[string]$exe
	)

	$counter = 0
	Write-Output $appRules
	for ($counter -lt $appRules.count) {
		$appRule = $appRules[$counter]
		Write-Output $appRule
		if ($appRule[0] -ne $exe) {
			switch ($appRule[1]) {
				"skipExe" { return $false }
			}
		}
		$counter++
	}
	return $true
}

# C# Shit for removing last n lines in terminal
function Remove-LastLines {
param(
		[int]$count
	)

	for ($i = 0; $i -lt $count; $i++) {
		$cursorTop = [System.Console]::CursorTop
		if ($cursorTop -gt 0) {
			[System.Console]::SetCursorPosition(0, $cursorTop - 1)
			[System.Console]::Write(' ' * [System.Console]::WindowWidth)
			[System.Console]::SetCursorPosition(0, $cursorTop - 1)
		}
	}
}

# If -fromFile argument provided, cleaning array with categories, so foreach blok below won't start
if ($fromFile -ne "") {
	$appsRoots = @()
	$shortcutTargets = Get-Content -Path $fromFile
}

foreach ($appsRoot in $appsRoots) {
	# For each directory in appsCategories list
	foreach ($appsDir in $appsCategories) {
		# Checking directory existance
		if (-not (Test-Path -Path "$appsRoot\$appsDir" -PathType Container)) {
			continue
		}

		# For each directory in category's directory (:
		Get-ChildItem -Path "$appsRoot\$appsDir" | ForEach-Object {
			# Program's root directory
			$path = "$appsRoot\$appsDir\$_"

			# Checking that path exacly a directory
			if (-not (Test-Path -Path $path -PathType Container)) {
				Write-Output "$path not a directory"
				continue
			}

			# Empty array for possible multiple executables in program directory
			$exe = @()
			# For enumerating items in $binDirs array
			$counter = 0
			# Subdir with program's executables
			$binDir = ""

			while ($counter -lt $binDirs.Count) {
				$binDir = $binDirs[$counter]
				if (Test-Path -Path "$path\$binDir" -PathType Container) {
					$exe = Get-ChildItem -Path "$path\$binDir" -Filter "*.exe"
					$exe = $exe | Where-Object { Check-AppRule "$_" }
					if ($binDir -ne "") {
						$exe = $exe.ForEach({ Join-Path -Path "$binDir" -ChildPath "$_" })
					}
				}
				$counter++
			}

			switch ($exe.Count) {
				# If no exe ):
				0 {
					Write-Output "- $path. No executables in: $binDirs"
				}
				1 {}
				# Should be chosen if directory have multiple executables
				Default {
					Write-Output "Found in ${path}:"
					$counter = 1
					$exe | ForEach-Object {
						Write-Output "$counter. $_"
						$counter++
					}
					# Should be printed last
					Write-Output "0. No shortcut"

					$choise = 0
					do {
						$choise = Read-Host "Select exe"
						$choise = [int]$choise
					} while (($choise -lt 0) -and ($choise -gt $exe.Count))
					$count = $exe.Count + 3
					Remove-LastLines -count $count
					if (($choise -eq 0) -or ($choise -eq "")) {
						Write-Output "- $path"
						$exe = @()
					}
					else {
						$exe = $exe[$choise - 1]
					}
				}
			}

			if ($exe.Count -ne 0) {
				Write-Output "+ $path\$exe"
				$shortcutTargets += "$path\$exe"
			}
		}
	}
}

Write-Output "Resulting shortcuts:"
$shortcutTargets | ForEach-Object { Write-Output "$_" }

if ($fromFile -eq "") {
	Write-Output "Saving into ./$saveFileName. . ."
	$shortcutTargets | Out-File -FilePath "$saveFileName"
}

$shell = New-Object -ComObject WScript.Shell
foreach ($target in $shortcutTargets) {
	$fileDir  = Split-Path -Path $target -Parent
	$fileName = Split-Path -Path $target -Leaf
	# Changing .exe to .lnk by sigma method (regular expressions)
	$shortcutName = $fileName -replace "\.[^.]+$", ".lnk"

	$shortcut = $shell.CreateShortcut("$env:USERPROFILE\Desktop\$shortcutName")
	$shortcut.TargetPath = $target
	$shortcut.WorkingDirectory = $fileDir
	$shortcut.Save()
}
