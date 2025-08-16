#!/usr/bin/env bash

TORRC="$HOME_WORKSPACE/share/torrc"
INPUTFILE="$HOME_WORKSPACE/share/tor-bridges.txt"

cp "$TORRC-begin" "$TORRC"

shuf -n 2 "$INPUTFILE" | while read -r bridge; do
	echo "Bridge $bridge" >> "$TORRC"
done
