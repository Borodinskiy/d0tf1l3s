#!/usr/bin/env bash
if systemctl --quiet --user is-active wireproxy; then
	proxy-ns "$@"
else
	"$@"
fi
