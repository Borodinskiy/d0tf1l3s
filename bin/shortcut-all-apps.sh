#!/usr/bin/env bash

# Fixes for some operations with "*" operand (like /directory/*.exe)
shopt -s nullglob
# Look for unbound variables
set -u

TMP="$(mktemp -d)"
XDG_DATA_HOME="${XDG_DATA_HOME:-${HOME:?}/.local/share}"
DESKTOPDIR="$XDG_DATA_HOME/applications"
ICONDIR="$XDG_DATA_HOME/icons"
# Manage shortcuts for programs located in root directories
ALLOW_ROOT=0

# Default name for script inside program directory that runs it
RUNSCRIPT="run.sh"

# Array of root directories where program categories located
ROOTS=(
	"$HOME/programs"
	"$HOME/programs/win"
	"$HOME/myfiles/programs"
	"/portablehub/Programs"
	"/gamehub/programs"
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
			echo "	--clean\t\tfirstly remove all previously created [$RUNSCRIPT]* shortcuts"
			echo "	--allow-root\t\tmanage shortcuts for programs located in root directories"
			exit 0
			;;
		"--clean") rm -f "$DESKTOPDIR/[$RUNSCRIPT] "* ;;
		"--allow-root") ALLOW_ROOT=1; echo "TODO"; exit ;;
	esac
}

# Function for desktop file creation
# TODO: can we make arguments by --flag? So we don't need to remember sequense
create_desktop() {
	name="$1"
	directory="$2"
	executable="$3"
	category="$4"

	cd "$directory" || exit 1

	# Name and temporary location of desktop file
	filename="[$executable] $name.desktop"

	# Getting right category name for desktop file from directory name
	case "$category" in
		"games" | "game") category="Game" ;;
		"utility" | "util") category="Utility" ;;
		"dev") category="Development" ;;
	esac

	# First have the greatest priority
	# [ -f "" ] && action - small version of if then
	icon="application-x-executable"
	for ext in "svg" "png" "ico"; do
		[ -f "$name.$ext" ] && icon="$name.$ext" && break
		[ -f "icon.$ext" ] && icon="icon.$ext" && break
	done

	install -m600 "/dev/null" "$TMP/$filename"

	# Check for premade desktop file inside directory and replace some of it's parameters
	local have_desktops=0
	for file in *.desktop; do
		# Changed if we ever entered this for loop
		have_desktops=1

		desktopfile="$(realpath "$file")"
		install --compare -m600 "$desktopfile" "$TMP/$filename"
		sed -i \
			-e "/^Exec=/s|=.*$|=\"$directory/$executable\" %u|" \
			-e "/^TryExec=/s|=.*$|=$directory/$executable|" \
			-e "/^Icon=/s|=.*$|=$directory/$icon|" \
			-e "/^Path=/s|=.*$|=$directory|" \
			"$TMP/$filename"
		if [ -z "$(grep 'Path=' "$TMP/$filename")"]; then
			echo "Path=$directory" >> "$TMP/$filename"
		fi
		install --compare -m644 "$TMP/$filename" "$DESKTOPDIR/[$executable] $(basename "$file")"
		rm "$TMP/$filename"
	done
	if [ "$have_desktops" == 0 ]; then
		# Creating file with filename and contents of basic desktop file
		cat << EOF > "$TMP/$filename"
[Desktop Entry]
Type=Application
Categories=$category
Name=$name
Icon=$directory/$icon
Path=$directory
Exec="$directory/$executable" %u
Terminal=false
StartupNotify=true
Actions=DeleteShortcut
[Desktop Action DeleteShortcut]
Name=Remove this shortcut
Name[ru_RU]=Удалить этот ярлык
Icon=edit-clear-all-symbolic
Exec=rm -f "$DESKTOPDIR/$filename"
EOF
		install --compare -m644 "$TMP/$filename" "$DESKTOPDIR/$filename"
		rm -f "$TMP/$filename"
	fi

	# Finally printing what we used for desktop file
	echo " ] $name: $executable & $icon"
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
		install --compare -m600 "$desktopfile" "/tmp/desktopfile.desktop"
		sed -i \
			-e "/^Exec=/s|=.*$|=\"$app\" %u|" \
			-e "/^TryExec=/s|=.*$|=$app|" \
			"/tmp/desktopfile.desktop"
		install --compare -m644 "/tmp/desktopfile.desktop" "$DESKTOPDIR/$(basename "$file")"
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

			if [ -f "$path/$RUNSCRIPT" ]; then
				printf "  \`- ["
				create_desktop \
					"$name" \
					"$path" \
					"$RUNSCRIPT" \
					"$category"
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

rm -r "$TMP"
