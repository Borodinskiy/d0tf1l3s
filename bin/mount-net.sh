#!/usr/bin/env bash
if [ -z "$2" ]; then
	echo "Please specify auth username and network path and mount path as extra argument"
	exit 1
fi
NET_USERNAME="$1"
NET_PATH="$2"
MOUNT_PATH="${3:-/run/media/$USER/$2}"

echo sudo mkdir -p "$MOUNT_PATH"
echo sudo mount --types=cifs --options=gid="$GID",uid="$UID",username="$NET_USERNAME" "//$NET_PATH" "$MOUNT_PATH"
