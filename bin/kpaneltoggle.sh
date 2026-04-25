#!/usr/bin/env bash

dbus-send \
	--session --dest=org.kde.plasmashell \
	--type=method_call /PlasmaShell org.kde.PlasmaShell.evaluateScript \
	"string:
	let panel = panelById(2);
    panel.hiding === \"autohide\" ? panel.hiding = \"alwaysvisible\" : panel.hiding = \"autohide\";
    "
