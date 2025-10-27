#!/usr/bin/env bash
# If variable already defined than using it instead of this script location
# Useful for termux environment

# Where user store its documents, saves, etc.
# By default its user's $HOME directory
# To change value this variables should be defined before calling this script
HOME_MYFILES="${HOME_MYFILES:-$HOME}"
# Used for bookmarks and scripts
HOME_WORKSPACE="${HOME_WORKSPACE:-$(realpath "$(dirname "$0")")}"

XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

link() {
	in="$1"
	out="$2"

	unlink "$out" &> /dev/null
	if [ -d "$out" ] || [ -f "$out" ]; then
		echo "Error: $out is not a link. Manually backup this dir/file or delete it"
		return
	fi

	# For situations, when links nvim/init.lua instead of full nvim directory
	targetdir="$(dirname "$out")"
	[ ! -d "$targetdir" ] && mkdir -p "$targetdir"
	ln -s "$in" "$out"
}

shell_source() {
	in="$1"
	out="$2"

	if [ ! -f "$out" ] || [ "$(grep "source \"$in\"" < "$out")" == "" ]; then
		echo "source \"$in\"" >> "$out"
	fi
}

shell_var() {
	in="$1"
	out="$2"

	if [ ! -f "$out" ] || [ "$(grep "export $in" < "$out")" == "" ]; then
		echo "export $in" >> "$out"
	fi
}

echo "HOME_WORKSPACE is $HOME_WORKSPACE"

LINK_CONFIGS=(
	"nvim/init.lua"

	"qutebrowser/bookmarks"
	"qutebrowser/config.py"
	"qutebrowser/greasemonkey"
	"qutebrowser/quickmarks"

	"niri"
	"kanshi"

	"sway"
	"swaylock"
	"waybar"
	"wofi"

	"MangoHud"
	"gamemode.ini"

	"foot"
	"kitty"
	"yazi"

	"xdg-desktop-portal"
	"chromium-flags.conf"
	"code-flags.conf"
)

LINK_DATAS=(
	"color-schemes/MinecraftNet.colors"
)

LINK_SYSTEMDS=(
	"user/niri-exit.service"
	"user/kanshi.service"
	"user/swayidle.service"
)

SHELL_SOURCES_HOME=(
	"profile"
	"bashrc"
)

SHELL_VARS=(
	"HOME_MYFILES=\"$HOME_MYFILES\""
	"HOME_WORKSPACE=\"$HOME_WORKSPACE\""
)

for file in "${LINK_CONFIGS[@]}"; do
	link "$HOME_WORKSPACE/config/$file" "$XDG_CONFIG_HOME/$file"
done

for file in "${LINK_DATAS[@]}"; do
	link "$HOME_WORKSPACE/config/$file" "$XDG_DATA_HOME/$file"
done

for file in "${LINK_SYSTEMDS[@]}"; do
	link "$HOME_WORKSPACE/config/systemd/$file" "$XDG_CONFIG_HOME/systemd/$file"
done

for var in "${SHELL_VARS[@]}"; do
	shell_var "$var" "$HOME/.profile"
	shell_var "$var" "$HOME/.bash_profile"
done

for file in "${SHELL_SOURCES_HOME[@]}"; do
	shell_source "$HOME_WORKSPACE/config/$file" "$HOME/.$file"
	shell_source "$HOME/.$file" "$HOME/.bash_profile"
done
