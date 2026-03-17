#!/usr/bin/env bash

ROUTING_TYPE="${ROUTING_TYPE:-remote}"

if [ -z "$HOME_WORKSPACE" ]; then
	CONFIG_DIR="$(dirname "$0")"
else
	CONFIG_DIR="$HOME_WORKSPACE/config/sing-box"
fi

ETC_DIR="/etc/sing-box"

cd "$CONFIG_DIR" || exit 1
echo "Copying config to $ETC_DIR. . ."

sudo rm -f "$ETC_DIR"/*
sudo mkdir -p "$ETC_DIR"

case "$ROUTING_TYPE" in
	"amnezia")
		ETC_CONFIGS=(
			"config.json"
			"outbound-direct.json"
			"outbound-awg.json"
			"proxy-server.json"
			"tun-linux.json"
		)
		;;
	"remote")
		ETC_CONFIGS=(
			"config.json"
			"outbound-direct.json"
			"outbound-remote.json"
			"tun-linux.json"
		)
		;;
esac

sudo cp "${ETC_CONFIGS[@]}" "$ETC_DIR"

if [ -f "$(which sing-box)" ]; then
	echo "Found sing-box, checking configuration. . ."
	if ! sing-box check --config-directory "$ETC_DIR"; then
		echo "Found errors, aborting."
		exit 1
	fi
else
	echo "No sing-box binary found in PATH."
	exit 1
fi

if systemctl is-active sing-box -q; then
	echo "Restarting sing-box.service. . ."
	sudo systemctl restart sing-box
fi

echo "Done"
