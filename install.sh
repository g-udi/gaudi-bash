#!/usr/bin/env bash
# shellcheck shell=bash

GAUDI_BASH="$HOME/.gaudi_bash"
GAUDI_BASH_REPOSITORY="https://github.com/g-udi/gaudi-bash.git"

# Prints the latest release of gaudi-bash (the highest version tag of the repository), nothing when there is none
__latest_release() {
	local tag
	tag=$(env git ls-remote --tags --refs --sort=-v:refname "$GAUDI_BASH_REPOSITORY" 'v*' 2> /dev/null | head -n 1)
	printf '%s' "${tag##*refs/tags/}"
}

__install() {
	# Keep the cloned files from being writable by the group or by others, whatever the umask of the user is
	# (e.g., "002"): these files are sourced by every new shell
	umask g-w,o-w

	# The latest release is installed, the same version `gbash update` moves to; the main branch only when
	# nothing was released yet
	local release
	local -a version=()
	release="$(__latest_release)"
	[[ -n "$release" ]] && version=(--branch "$release")

	# The git submodules are fetched by setup.sh, which leaves out the ones that only the tests need (bats)
	env git clone --depth=1 "${version[@]}" "$GAUDI_BASH_REPOSITORY" "$GAUDI_BASH" || {
		printf "%s\n" "Error: Cloning of gaudi into this machine failed :("
		exit 1
	}

	# A clone of a release tag only tracks that tag: the branches are tracked too, for `gbash update dev`
	env git -C "$GAUDI_BASH" remote set-branches origin '*'

	"$GAUDI_BASH/setup.sh" "$@"
}

# Updates an existing installation to the latest release (or to the main branch when there is no release yet).
# Uses fetch + checkout because `gbash update` leaves a detached HEAD, on which `git pull` fails.
# An installation that is already ahead of the latest release (the main branch) is never moved back.
__update() {
	local target

	# A shallow clone does not know how its commit relates to the release: get the history first
	if [[ "$(git -C "$GAUDI_BASH" rev-parse --is-shallow-repository 2> /dev/null)" == "true" ]]; then
		git -C "$GAUDI_BASH" fetch --unshallow origin 2> /dev/null
	fi

	git -C "$GAUDI_BASH" fetch origin --tags || return 1

	target=$(git -C "$GAUDI_BASH" describe --tags "$(git -C "$GAUDI_BASH" rev-list --tags --max-count=1 2> /dev/null)" 2> /dev/null)
	: "${target:=origin/main}"

	if git -C "$GAUDI_BASH" merge-base --is-ancestor "$target" HEAD 2> /dev/null; then
		printf "%s\n" "This installation already holds $target, the version is left as it is."
	else
		git -C "$GAUDI_BASH" checkout "$target" || return 1
	fi

	# The checked out version knows which git submodules it runs on, versions without that helper get them all
	if [[ -s "$GAUDI_BASH/lib/helpers/updater.bash" ]] && source "$GAUDI_BASH/lib/helpers/updater.bash" && declare -F _gaudi-bash-submodules-update > /dev/null; then
		_gaudi-bash-submodules-update "$GAUDI_BASH"
	else
		git -C "$GAUDI_BASH" submodule update --init --recursive
	fi
}

# Reads a single answer into REPLY, which is left empty when there is nothing to read (e.g., non-interactive run).
# When the installer itself is piped into bash, stdin is the script so the answer is read from the terminal.
__read_answer() {
	REPLY=""
	if [[ ! -t 0 && "$GAUDI_BASH_INSTALL_PIPED" == true ]]; then
		{ read -r REPLY < /dev/tty; } 2> /dev/null || true
	else
		read -r REPLY || true
	fi
}

# The script has no source file when it is read from stdin (curl ... | bash)
GAUDI_BASH_INSTALL_PIPED=false
[[ -z "${BASH_SOURCE[0]:-}" ]] && GAUDI_BASH_INSTALL_PIPED=true

if [[ -d "$GAUDI_BASH" ]]; then
	echo "You already have gaudi-bash installed.."
	printf "Do you want to set up a fresh installation of gaudi-bash? [Yy/nN] "
	__read_answer

	if [[ $REPLY =~ ^[yY]$ ]]; then
		rm -rf "$GAUDI_BASH"
		__install "$@"
	elif [[ $REPLY =~ ^[nN]$ ]]; then
		printf "\n%s\n" "Running a gaudi-bash update to get the latest changes ..."
		__update || {
			printf "%s\n" "Error: Updating gaudi-bash in $GAUDI_BASH failed :("
			exit 1
		}
	else
		printf "\n%s\n" "No valid answer (y or n) was given, leaving the existing installation untouched."
		exit 1
	fi
else
	__install "$@"
fi
