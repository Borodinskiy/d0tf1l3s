#!/usr/bin/env bash

SCRIPT_HOME="$(dirname "$0")"
[ "$HOME_WORKSPACE" ] && SCRIPT_HOME="$HOME_WORKSPACE/config/sing-box"

CONFIG="/tmp/singbox-$USER.conf"

cd "$SCRIPT_HOME" || exit 1

install -m 700 "config.json" "$CONFIG"

sed \
	-e '/\"<PROXY_PROCESSES>\"/{' -e 'r processes.json' -e 'd; }' \
	-e '/\"<PROXY_DOMAINS>\"/{' -e 'r domains.json' -e 'd; }' \
	-e '/\"<PROXY_OUTBOUND>\"/{' -e 'r proxy.json' -e 'd; }' \
	"$SCRIPT_HOME/config.json" > "$CONFIG"

sudo sing-box run --config "$CONFIG"
