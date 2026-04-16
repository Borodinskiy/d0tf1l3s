# Firejail profile for deltachat
# Description: A private email chat
# Persistent local customizations
include deltachat.local
# Persistent global definitions
include globals.local

noblacklist ${HOME}/.config/DeltaChat
noblacklist ${HOME}/.config/deltachat-flags.conf

mkdir ${HOME}/.config/DeltaChat
whitelist ${HOME}/.config/DeltaChat
whitelist ${HOME}/.config/deltachat-flags.conf

# allow D-Bus notifications
dbus-user filter
dbus-user.talk org.freedesktop.Notifications
dbus-user.talk org.kde.StatusNotifierWatcher
dbus-user.talk org.gnome.Mutter.IdleMonitor
dbus-user.talk org.freedesktop.ScreenSaver
ignore dbus-user none

join-or-start deltachat

# Redirect
include electron-common.profile
include net-direct.profile
