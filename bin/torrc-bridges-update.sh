#!/usr/bin/env bash
export ALL_PROXY="socks5://127.0.0.1:9051"
wget "https://raw.githubusercontent.com/scriptzteam/Tor-Bridges-Collector/refs/heads/main/bridges-obfs4" -O "$HOME_WORKSPACE/share/tor-bridges.txt"
