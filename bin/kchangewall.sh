#!/usr/bin/env bash

WALL_DESKTOP="$1"
WALL_LOCKSCREEN="${2:-$1}"

# Desktops
dbus-send \
	--session --dest=org.kde.plasmashell \
	--type=method_call /PlasmaShell org.kde.PlasmaShell.evaluateScript \
	"string:
	var Desktops = desktops();
	for (i=0;i<Desktops.length;i++) {
		d = Desktops[i];
		d.wallpaperPlugin = \"org.kde.image\";
		d.currentConfigGroup = Array(\"Wallpaper\",
		\"org.kde.image\",
		\"General\");
		d.writeConfig(\"Image\", \"file://$WALL_DESKTOP\");
	}"

# Lockscreen
sed -i \
	-e "/^Image=/s|=.*$|=$WALL_LOCKSCREEN|" \
	-e "/^PreviewImage=/s|=.*$|=$WALL_LOCKSCREEN|" \
	"$HOME/.config/kscreenlockerrc"

