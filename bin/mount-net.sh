#!/usr/bin/env bash
if [ -z "$2" ]; then
	name="$(basename "$0")"
	echo "Usage: $name LOGIN NET_PATH [MOUNT_PATH]"
	echo "Example: $name abobach 127.0.0.1/public /mnt/public"
	exit 1
fi
NET_USERNAME="$1"
NET_PATH="$2"
MOUNT_PATH="${3:-/run/media/$USER/$2}"

sudo mkdir -p "$MOUNT_PATH"
sudo mount --types=cifs --options=gid="$GID",uid="$UID",username="$NET_USERNAME" "//$NET_PATH" "$MOUNT_PATH"
