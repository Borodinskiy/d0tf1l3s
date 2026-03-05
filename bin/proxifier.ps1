param(
	[string]$routingType = "remote"
)


if ("$env:HOME_WORKSPACE" -eq "") {
	Write-Output "No HOME_WORKSPACE variable is set"
	exit 1
}

$configDir = "$env:HOME_WORKSPACE\config\sing-box"
$etcDir = "$env:LOCALAPPDATA\sing-box"

Write-Output "Found dir $configDir"
Write-Output "Copying config to $etcDir"

switch ("$routingType") {
	"remote" {
		$etcConfigs = @(
			  "config.json"
			, "outbound-direct.json"
			, "outbound-remote.json"
			, "tun-windows.json"
		)
	}
}

cd "$configDir"

if (Test-Path -Path "$etcDir" -PathType Container) {
	Get-ChildItem "$etcDir" -File | Remove-Item
} else {
	mkdir "$etcDir"
}

cp $etcConfigs "$etcDir"