#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2120

GAUDI_BASH="$HOME/.gaudi_bash"

__update_existing_install() {
	git -C "$GAUDI_BASH" pull --ff-only --recurse-submodules &&
		git -C "$GAUDI_BASH" submodule sync --recursive &&
		git -C "$GAUDI_BASH" submodule update --init --recursive
}

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

	# shellcheck disable=SC1091
	source "$GAUDI_BASH/setup.sh" "$@"
}

if [[ -d "$GAUDI_BASH" ]]; then
	echo "You already have gaudi-bash installed.."
	unset REPLY
	while ! [[ $REPLY =~ ^[yY]$ ]] && ! [[ $REPLY =~ ^[nN]$ ]]; do
		printf "Do you want to set up a fresh installation of gaudi-bash? [Yy/nN] "
		read -r REPLY
		if [[ $REPLY =~ ^[yY]$ ]]; then
			rm -rf "$GAUDI_BASH"
			__install "$@"
		else
			echo ""
			printf "\n%s\n" "Running a gaudi-bash update to pull latest changes ..."
			if ! __update_existing_install; then
				printf "%s\n" "Error: failed to update the existing gaudi-bash installation" >&2
				exit 1
			fi
		fi
	done
else
	__install "$@"
fi
