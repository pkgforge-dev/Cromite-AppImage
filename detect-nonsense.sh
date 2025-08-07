#!/bin/sh

CACHEDIR="${XDG_CACHE_HOME:-$HOME/.cache}"

info_message="
Starting Ubuntu24.04 canonical decided that namespaces are not safe and is preventing us from using it to sandbox applications.

For more details see: https://github.com/Samueru-sama/fix-ubuntu-nonsense/blob/main/README.md#why

Namespaces are safe and a vital part of the security model of all web browsers, flatpak, electron apps, etc

To fix this issue I will need permission to disable the restriction, like all other linux distros do and several ubuntu forks had to undo.
"

how_to_undo="
If you wish to undo this change remove: '/etc/sysctl.d/20-fix-namespaces.conf',
then run 'sysctl -w kernel.apparmor_restrict_unprivileged_userns=1' or reboot.
"

warning_text="
WARNING: I'm not able to create a namespace and not sure what is preventing it.

We will continue without prompting but if something breaks you know why.
"

do_not_ask_again="Do you wish to not see this message again?"

_display_message() {
	if command -v zenity 1>/dev/null; then
		zenity --warning --text "$*"
	elif command -v kdialog 1>/dev/null; then
		kdialog --warningcontinuecancel "$*"
	fi
}

_false_positive_check(){
	FALSE_POSITIVE=0

	# Unlikely to be ubuntu or its spins if any of these conditions are true
	if ! command -v sysctl; then
		FALSE_POSITIVE=1
	elif ! command -v zenity && ! command -v kdialog; then
		FALSE_POSITIVE=1
	elif ! command -v unshare || ! command -v /bin/true; then
		FALSE_POSITIVE=1
	elif [ ! -d /etc/apparmor.d ] || [ ! -d /etc/sysctl.d ]; then
		FALSE_POSITIVE=1
	fi
	if [ "$FALSE_POSITIVE" = 1 ]; then
		>&2 echo "$warning_text"
		exit 0
	fi
}

_fix_mess() {
	if _display_message "$info_message"; then
		pkexec /bin/sh -c "
			echo 'kernel.apparmor_restrict_unprivileged_userns = 0' \
			  | tee /etc/sysctl.d/20-fix-namespaces.conf
			sysctl -w kernel.apparmor_restrict_unprivileged_userns=0
		"
		if [ -f /etc/sysctl.d/20-fix-namespaces.conf ]; then
			_display_message "$how_to_undo"
		fi
	elif _display_message "$do_not_ask_again"; then
		echo "delete me to enable again" > "$CACHEDIR"/.disable-namespace-check
	fi
}

if unshare --user -p /bin/true >/dev/null 2>&1; then
	exit 0
elif [ -f "$CACHEDIR"/.disable-namespace-check ] || [ -f /etc/sysctl.d/20-fix-namespaces.conf ]; then
	exit 0
else
	_false_positive_check 1>/dev/null
	_fix_mess
fi
