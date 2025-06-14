$redistDir = "$PSScriptRoot\redist"
Get-ChildItem -Path $redistDir | ForEach-Object {
	$file = $_
	start "$redistDir\$file" "/install /quiet"
}
