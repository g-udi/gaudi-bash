#!/usr/bin/env bash
# shellcheck shell=bash

GAUDI_BASH="$HOME/.gaudi_bash"

__install() {
	# Prevent the cloned repository from having insecure permissions. Failing to do
	# so causes compinit() calls to fail with "command not found: compdef" errors
	# for users with insecure umasks (e.g., "002", allowing group writability). Note
	# that this will be ignored under Cygwin by default, as Windows ACLs take
	# precedence over umasks except for filesystems mounted with option "noacl".
	umask g-w,o-w

	env git clone --depth=1 --recurse-submodules https://github.com/g-udi/gaudi-bash.git "$GAUDI_BASH" || {
		printf "%s\n" "Error: Cloning of gaudi into this machine failed :("
		exit 1
	}

	bash "$GAUDI_BASH/setup.sh"
}

if [[ -d "$GAUDI_BASH" ]]; then
	echo "You already have gaudi-bash installed.."
	unset REPLY
	while ! [[ $REPLY =~ ^[yY]$ ]] && ! [[ $REPLY =~ ^[nN]$ ]]; do
		read -rp "Do you want to set up a fresh installation of gaudi-bash? [Yy/nN] " -n 1 < /dev/tty
		[[ -n $REPLY ]] && echo ""
	done
	if [[ $REPLY =~ ^[yY]$ ]]; then
		rm -rf "$GAUDI_BASH"
	else
		echo "Running a gaudi-bash update to pull latest changes ..."
		git -C "$GAUDI_BASH" pull
	fi
	__install
else
	__install
fi
