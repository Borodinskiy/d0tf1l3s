#!/usr/bin/env bash

# Fixes for some operations with "*" operand (like /directory/*.exe)
shopt -s nullglob
# Look for unbound variables
set -u

DESKTOPDIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"
ICONDIR="${XDG_DATA_HOME:-$HOME/.local/share}/icons"

# Name for script that runs program
RUNSCRIPT="run.sh"

# Array of root directories where program categories located
ROOTS=(
	"$HOME/programs"
	"$HOME/programs/win"
	"$HOME/myfiles/programs"
	"/portablehub/Programs"
	"/gamehub/Programs"
	"/run/media/$USER/drive_d/programs"
	"/run/media/$USER/drive_g/programs"
	"/run/media/$USER/drive_p"
)

# Subdirectories in roots with programs
CATEGORIES=(
	"Development" "dev"
	"Game" "games" "game"
	"Utility" "utility" "util"
)

# Subdirectories in roots with appimages
APPIMAGES=(
	"appimage"
)

# Check user's input
check_arguments() {
	case "$1" in
		"--help" | "-h")
			echo "Usage: $0"
			echo "	--clean	firstly remove all previously created [$RUNSCRIPT]* shortcuts"
			exit 0
			;;
		"--clean") rm -f "$DESKTOPDIR/[$RUNSCRIPT] "* ;;
	esac
}

# Function for desktop file creation
# TODO: can we make arguments by --flag? So we don't need to remember sequense
create_desktop() {
	name="$1"
	directory="$2"
	executable="$3"
	category="$4"

	# If no success when do a cd to directory, then exit with error
	cd "$directory" || exit 1

	# Location of desktop file
	filename="[$executable] $name.desktop"
	tempdir="/tmp"

	# Changing some categories to desktop file format
	case "$category" in
		"games" | "game") category="Game" ;;
		"utility" | "util") category="Utility" ;;
		"dev") category="Development" ;;
	esac

	# Last have the greatest priority
	# [ -f "" ] && action - small version of if then
	icon="application-x-executable"
	for ext in "ico" "png" "svg"; do
		[ -f "icon.$ext" ] && icon="icon.$ext"
		[ -f "$name.$ext" ] && icon="$name.$ext"
	done

	# Creating file with filename and contents of basic desktop file
	cat << EOF > "$tempdir/$filename"
[Desktop Entry]
Type=Application
Categories=$category
Name=$name
Icon=$directory/$icon
Path=$directory
Exec="$directory/$executable"
Terminal=false
StartupNotify=true
Actions=DeleteShortcut
[Desktop Action DeleteShortcut]
Name=Remove this shortcut
Name[ru_RU]=Удалить этот ярлык
Icon=edit-clear-all-symbolic
Exec=rm -f "$DESKTOPDIR/$filename"
EOF

	printf " ] "
	install --compare -m755 "$tempdir/$filename" "$DESKTOPDIR/$filename"
	rm -f "$tempdir/$filename"

	# Finally printing what we used for desktop file
	echo "$name: $executable & $icon"
}

integrate_appimage() {
	# Appimage executable
	app="$(realpath $1)"
	# Mounting appimage in background and saving mount path
	read -r mount_path < <($app --appimage-mount)
	# For future background process termination
	app_pid=$!

	# Copy desktop files and replace Exec= line with path to appimage
	find "$mount_path" -maxdepth 1 -name "*.desktop" \
		| while read -r file
	do
		desktopfile="$(realpath "$file")"
		install --compare -m700 "$desktopfile" "/tmp/desktopfile.desktop"
		sed -ie "/^Exec=/s|=.*$|=$app %u|" "/tmp/desktopfile.desktop"
		install --compare -m755 "/tmp/desktopfile.desktop" "$DESKTOPDIR/$(basename "$file")"
		rm "/tmp/desktopfile.desktop"
	done

	# Find icon (svg have priority)
	# TODO: search for other formats and fix priotity picking logic
	find "$mount_path" -maxdepth 1 -name "*.svg" -or -name "*.png" \
		| sort --reverse | while read -r file
	do
		install --compare -m 644 "$(realpath "$file")" "$ICONDIR/"
		break
	done

	# Terminating background process
	kill -SIGINT "$app_pid"
	wait "$app_pid"
}

[ -v 1 ] && check_arguments "$@"

for root in "${ROOTS[@]}"; do
	# Skip directory if couldn't cd in it
	cd "$root" &> /dev/null || continue
	echo "$root:"

	for category in "${CATEGORIES[@]}"; do
		cd "$root/$category" &> /dev/null || continue
		echo "\`- $category:"

		for path in "$root/$category"/*; do
			[ -f "$path" ] && continue
			name="$(basename "$path")"
			printf "  \`- ["

			if [ -f "$path/$RUNSCRIPT" ]; then
				create_desktop \
					"$name" \
					"$path" \
					"$RUNSCRIPT" \
					"$category"
			else
				echo "!] $name: no $RUNSCRIPT"
			fi
		done
	done

	for category in "${APPIMAGES[@]}"; do
		cd "$root/$category" &> /dev/null || continue
		echo "\`- $category:"
		for appimage in "$root/$category"/*; do
			echo "  \`- [ ] $(basename "$appimage")"
			integrate_appimage $appimage
		done
	done
done
