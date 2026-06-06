#!/usr/bin/env bash
case "$1" in
	"--random")
		swaybg -i "$(find "$HOME/wallpapers" -type f | sort -R | head -n 1)"
		;;
	"--single")
		swaybg -i "$HOME_MYFILES/sync/multimedia/wallpapers/sigmo/b-832.jpg"
		;;
esac
