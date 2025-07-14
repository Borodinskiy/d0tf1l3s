#!/usr/bin/env bash

SCRIPT_HOME="$(dirname "$0")"
[ "$HOME_WORKSPACE" ] && SCRIPT_HOME="$HOME_WORKSPACE/config/sing-box"

CONFIG="/tmp/singbox-$USER.json"

cd "$SCRIPT_HOME" || exit 1

install -m 700 "/dev/null" "$CONFIG"

# what is that
awk '
	BEGIN {
		while ((getline line < "processes.json") > 0) {
				processes_content = (processes_content ? processes_content "\n" : "") line
		}
		close("processes.json")
		
		while ((getline line < "domains.json") > 0) {
				domains_content = (domains_content ? domains_content "\n" : "") line
		}
		close("domains.json")
		
		while ((getline line < "proxy.json") > 0) {
				proxy_content = (proxy_content ? proxy_content "\n" : "") line
		}
		close("proxy.json")
	}
	{
		gsub(/"<PROXY_PROCESSES>"/, processes_content)
		gsub(/"<PROXY_DOMAINS>"/, domains_content)
		gsub(/"<PROXY_OUTBOUND>"/, proxy_content)
		print
	}
' "config.json" > "$CONFIG"

sudo sing-box run --config "$CONFIG"
