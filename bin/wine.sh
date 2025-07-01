#!/usr/bin/env bash

PACKAGES=(
	# Set wine "windows" to 10
	#"win10"
	# A lot of fonts for at least russian support
	"allfonts"
	# Something for Warcraft 3
	"lavfilters"
	# Windows Media Player 11
	"wmp11"
	# DirectX
	"d3dcompiler_43" "d3dcompiler_47"
	"mfc80" "d3dx9" "d3dx9_43"
	# Redists
	"vcrun2005" "vcrun2008" "vcrun2010"
)
AUTOLAUNCH=""

winetricks_basetricks() {
	echo "Packages:" "${PACKAGES[@]}"
	echo "Installing some hardcoded (in this script) packages to $WINEPREFIX. . ."
	${WINETRICKS_CMD} -q "${PACKAGES[@]}"
}

autolaunch_prepare() {
	local dir=""
	case "$1" in
		"steam")
			dir="$WINEPREFIX/drive_c/Program Files (x86)/Steam"
			AUTOLAUNCH=("Steam.exe" "-no-cef-sandbox")
			;;
		*)
			echo "No autolaunch for $1"
			exit 1
			;;
	esac
	if ! cd "$dir" &> /dev/null
	then
		echo "Could not cd into $dir"
		exit 1
	fi
}

runwine_native() {
	# Because this script have same name as wine, using other wine's utility for path finding
	WINEPATH="$(dirname "$(which wineserver)")"

	local wrappers="gamemoderun"

	TRICKSPATH="$(which winetricks)"

	# Setting up wine locations
	export WINE="$WINEPATH/wine"
	export WINE64="$WINEPATH/wine64"
	export WINESERVER="$WINEPATH/wineserver"
	export WINETRICKS_CMD="$TRICKSPATH"

	# If Wine build is fully 64-bit, set the WINE variable to WINE64
	[ ! -f "$WINE" ] && [ -f "$WINE64" ] \
		&& export WINE="$WINE64"

	local runwine="$wrappers $WINE"

	case "$1" in
		"winetricks")
			$WINETRICKS_CMD "${@:2}"
			;;
		"basetricks")
			winetricks_basetricks
			;;
		"wineserver")
			$WINESERVER "${@:2}"
			;;
		"auto")
			autolaunch_prepare "${@:2}"
			$runwine "${AUTOLAUNCH[@]}" "${@:3}"
			;;
		*)
			$runwine "$@"
			;;
	esac
}

runwine_umu() {

	export WINESERVER="umu-run wineserver"
	export WINETRICKS_CMD="umu-run winetricks"

	local runwine="umu-run"

	case "$1" in
		"winetricks")
			${WINETRICKS_CMD} "${@:2}"
			;;
		"basetricks")
			winetricks_basetricks
			;;
		"wineserver")
			${WINESERVER} "${@:2}"
			;;
		"auto")
			autolaunch_prepare "${@:2}"
			$runwine "${AUTOLAUNCH[@]}" "${@:3}"
			;;
		*)
			$runwine "$@"
			;;
	esac
}

# Change system language to russian (for gayming)
[ -z "$WINESH_KEEP_LANG" ] && export LANG=ru_RU.UTF-8

export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"

export WINEPREFIX="${WINEPREFIX:-$HOME/.wine}"

DLLOVERRIDES=(
	"winemenubuilder.exe="

	"d3dcompiler_43"
	"d3dcompiler_47"
	"d3d10core.dll"
	"d3d11.dll"
	"d3d8.dll"
	"d3d9.dll"
	"dinput8.dll"
	"dxgi.dll"
	# Last entry contains load order which applies to all previous dlls that not have it
	"dstorage.dll=n,b"
)

prevhadorder=1
for override in "${DLLOVERRIDES[@]}"; do
	osymbol=""
	if [ "$WINEDLLOVERRIDES" != "" ]; then
		osymbol=";"
		if [ -z "$prevhadorder" ]; then
			osymbol=","
		fi
	fi
	override="$osymbol$override"
	export WINEDLLOVERRIDES="$WINEDLLOVERRIDES$override"
	# If override contains equal sign that means it have load order
	[[ $override == *"="* ]] && prevhadorder=1 || prevhadorder=""
done

# Enable AMD FidelityFX Super Resolution (FSR)
export WINE_FULLSCREEN_FSR=1
export WINE_FULLSCREEN_FSR_STRENGTH=2

# Nvidia variables
export __GL_SHADER_DISK_CACHE_SKIP_CLEANUP=1
export __GL_SHADER_DISK_CACHE_PATH="${XDG_CACHE_HOME}"

# DXVK variables
export DXVK_LOG_PATH="${XDG_CACHE_HOME}/dxvk"
export DXVK_STATE_CACHE_PATH="${XDG_CACHE_HOME}/dxvk"
export DXVK_LOG_LEVEL=${DXVK_LOG_LEVEL:-none}
export DXVK_HUD="${DXVK_HUD:-0}"
export DXVK_ASYNC=1
#export DXVK_STATE_CACHE=0
#export DXVK_FRAME_RATE=60

# VKD3D variables
export VKD3D_DEBUG=none
export VKD3D_SHADER_DEBUG=none

# Wine-Staging variables
export STAGING_SHARED_MEMORY=1
#export STAGING_WRITECOPY=1

export ULIMIT_SIZE=1000000

# Finally, sending arguments from this script to preffered runwine_* function
runwine_umu "$@"

# Removing possible created shit in applications menu
rm -f ~/.local/share/mime/packages/x-wine*
rm -f ~/.local/share/applications/wine-extension*
rm -f ~/.local/share/applications/wine-protocol*
rm -f ~/.local/share/icons/hicolor/*/*/application-x-wine-extension*
rm -f ~/.local/share/mime/application/x-wine-extension*
