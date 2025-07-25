#!/usr/bin/env bash

if [ -z "$1" ]; then
	echo "Specify OS ($(basename "$0") linux/android/windows)"
	exit 1
fi

replace_in_file() {
	install -m 700 "/dev/null" "$CONFIG.tmp"
	sed -e "s/$1/$2/" "$CONFIG" > "$CONFIG.tmp"
	mv "$CONFIG.tmp" "$CONFIG"
}

if [ -z "$HOME_WORKSPACE" ]; then
	SCRIPT_HOME="$(dirname "$0")"
else
	SCRIPT_HOME="$HOME_WORKSPACE/config/sing-box"
fi

[ -z "$CONFIG" ] && case "$1" in
	"windows" | "android")
		CONFIG="${HOME_MYFILES:-$HOME}/sing-box.json"
		;;
	"linux")
		CONFIG="/tmp/sing-box-$USER.json"
		;;
esac

cd "$SCRIPT_HOME" || exit 1
install -m 700 "/dev/null" "$CONFIG" || exit 1

awk '
	function readfile(file, content, line) {
		while ((getline line < file) > 0) {
			content = (content ? content "\n" : "") line
		}
		close(file)
		return content
	}
	BEGIN {
		outbound_remote = readfile("proxy.json")
	}
	{
		gsub(/"<OUTBOUND_REMOTE>"/, outbound_remote)
		print
	}
' "config.jsonc" > "$CONFIG"

case "$1" in
	"linux")
		replace_in_file "\"auto_redirect\": false" "\"auto_redirect\": true"
		;;
esac

echo "Saved $1 configuration to $CONFIG"

if [ -f "$(which sing-box)" ] && [ -f "$(which sudo)" ]; then
	echo "Found sudo and sing-box, autostarting. . ."
	sudo sing-box run --config "$CONFIG"
fi
