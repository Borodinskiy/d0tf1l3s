#!/usr/bin/env bash

handle_specific_settings() {
	case "$1" in
		"windows")
			auto_route="true"
			auto_redirect="false"
			;;
		"android")
			auto_route="true, \"mtu\": 1500"
			auto_redirect="false"
			;;
	esac
	install -m 700 "/dev/null" "$CONFIG.tmp"
	sed \
		-e "s/\"auto_route\": true/\"auto_route\": $auto_route/" \
		-e "s/\"auto_redirect\": true/\"auto_redirect\": $auto_redirect/" \
		"$CONFIG" > "$CONFIG.tmp"
	mv "$CONFIG.tmp" "$CONFIG"
}

if [ -z "$HOME_WORKSPACE" ]; then
	SCRIPT_HOME="$(dirname "$0")"
else
	SCRIPT_HOME="$HOME_WORKSPACE/config/sing-box"
fi

if [ -z "$CONFIG" ] && { [ "$1" == "android" ] || [ "$1" == "windows" ]; }; then
	CONFIG="${HOME_MYFILES:-$HOME}/sing-box.json"
else
	CONFIG="${CONFIG:-/tmp/sing-box-$USER.json}"
fi

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
		outbound_proxy = readfile("proxy.json")
	}
	{
		gsub(/"<OUTBOUND_PROXY>"/, outbound_proxy)
		print
	}
' "config.jsonc" > "$CONFIG"

if [ "$1" == "android" ] || [ "$1" == "windows" ]; then
	handle_specific_settings "$1"
	echo "Saved $1 configuration to $CONFIG"
else
	[ ! -z "$1" ] && echo "Unknown system \"$1\""
	sudo sing-box run --config "$CONFIG"
fi
