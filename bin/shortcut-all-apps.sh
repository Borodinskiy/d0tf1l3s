#!/usr/bin/env bash

# Fixes for some operations with "*" operand (like /directory/*.exe)
shopt -s nullglob

DESKTOPDIR="${XDG_DATA_HOME:-$HOME/.local/share}/applications"

# Name for script that runs program
RUNSCRIPT="run.sh"

# Array of root directories where program categories located
ROOTS=(
	"$HOME"
	"$HOME/programs"
	"/run/media/$USER/drive_d/programs"
	"/run/media/$USER/drive_g/programs"
	"/run/media/$USER/drive_p"
)

# Subdirectories in roots with programs
CATEGORIES=(
	"Game" "Utility"
	"games" "game"
	"utility" "util"
)

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
	esac

	# Last have the greatest priority
	# [ -f "" ] && action - small version of if then
	icon="application-x-executable"
	[ -f "icon.ico" ] && icon="icon.ico"
	[ -f "icon.png" ] && icon="icon.png"
	[ -f "$name.ico" ] && icon="$name.ico"
	[ -f "$name.png" ] && icon="$name.png"

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

	chmod +x "$tempdir/$filename"

	# Checking if previously created desktop file have differences with new one
	if [ -f "$DESKTOPDIR/$filename" ] &&
	[ \
		"$(sha256sum "$DESKTOPDIR/$filename" | awk '{print $1}')" == \
		"$(sha256sum "$tempdir/$filename"    | awk '{print $1}')" \
	]
	then
		# Old file simmiliar to new, removing new from tempdir
		printf "=] "
		rm -f "$tempdir/$filename"
	else
		# Replacing old file. Sleep check allows desktop environment to update application menus
		printf "+] "
		rm -f "$DESKTOPDIR/$filename"
		sleep 0.5s
		mv "$tempdir/$filename" "$DESKTOPDIR/$filename"
	fi

	# Finally printing what we used for desktop file
	echo "$name: $executable & $icon"
}

case "$1" in
	"--help" | "-h")
		echo "Usage: $0"
		echo "	--clean	firstly remove all previously created [$RUNSCRIPT]* shortcuts" \
		"$0" "$RUNSCRIPT"
		exit 0
		;;
	"--clean") rm -f "$DESKTOPDIR/[$RUNSCRIPT] "* ;;
esac

for root in "${ROOTS[@]}"; do
	# Skip directory if couldn't cd in it
	cd "$root" &> /dev/null || continue
	echo "$root:"

	for category in "${CATEGORIES[@]}"; do
		cd "$root/$category" &> /dev/null || continue
		echo "\`- $category:"

		for path in "$root/$category"/*; do
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
done
