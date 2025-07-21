#!/usr/bin/env bash

handle_specific_settings() {
	case "$1" in
		"windows")
			auto_route="true"
			auto_redirect="false"
			;;
		"android")
			auto_route="false"
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

SCRIPT_HOME="$(dirname "$0")"
[ "$HOME_WORKSPACE" ] && SCRIPT_HOME="$HOME_WORKSPACE/config/sing-box"

if { [ "$1" == "android" ] || [ "$1" == "windows" ]; } && [ "$CONFIG" == "" ]; then
	CONFIG="${HOME_MYFILES:-$HOME}/sing-box.json"
else
	CONFIG="${CONFIG:-/tmp/sing-box-$USER.json}"
fi

cd "$SCRIPT_HOME" || exit 1

install -m 700 "/dev/null" "$CONFIG"

awk '
	function readfile(file, content, line) {
		content = ""
		while ((getline line < file) > 0) {
			content = (content ? content "\n" : "") line
		}
		close(file)
		return content
	}
	BEGIN {
		processes_proxy  = readfile("processes.json")
		android_packages = readfile("android-packages.json")
		domains_proxy    = readfile("domains-proxy.json")
		domains_direct   = readfile("domains-direct.json")
		outbound_proxy   = readfile("proxy.json")
	}
	{
		gsub(/"<PROCESSES_PROXY>"/, processes_proxy)
		gsub(/"<ANDROID_PACKAGES>"/, android_packages)
		gsub(/"<DOMAINS_PROXY>"/, domains_proxy)
		gsub(/"<DOMAINS_DIRECT>"/, domains_direct)
		gsub(/"<OUTBOUND_PROXY>"/, outbound_proxy)
		print
	}
' "config.json" > "$CONFIG"

if [ "$1" == "android" ] || [ "$1" == "windows" ]; then
	handle_specific_settings "$1"
	echo "Saved $1 configuration to $CONFIG"
else
	[ "$1" != "" ] && echo "Unknown system \"$1\""
	sudo sing-box run --config "$CONFIG"
fi
