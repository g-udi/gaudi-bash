#!/usr/bin/env bash
# shellcheck shell=bash

# @function     _gaudi-bash-submodules-update
# @description  Brings the git submodules gaudi-bash runs on to the commits pinned by the checked out version
#               The submodules that only the tests need (bats, under bin/bats-*) are not fetched: they are only
#               updated where they were fetched before (a development checkout)
#               Used by setup.sh and install.sh before composure is loaded, hence no function metadata here
# @param $1     (optional) The gaudi-bash directory (default: $GAUDI_BASH)
# @example      ❯ _gaudi-bash-submodules-update "$GAUDI_BASH"
function _gaudi-bash-submodules-update() {
	local directory="${1:-${GAUDI_BASH?}}" path
	local -a paths=()

	while read -r _ path; do
		[[ -z "$path" || "$path" == bin/bats-* ]] || paths+=("$path")
	done < <(git -C "$directory" config --file "$directory/.gitmodules" --get-regexp '^submodule\..*\.path$' 2> /dev/null)

	if [[ ${#paths[@]} -gt 0 ]]; then
		git -C "$directory" submodule update --init --recursive -- "${paths[@]}" || return 1
	fi

	# Without --init this only touches the submodules that were fetched before
	git -C "$directory" submodule update --recursive
}

# @function     _gaudi-bash-update-and-restart
# @description  Checks out the wanted version, brings the git submodules in line with it and restarts Bash
# @param $1     The tag or branch to check out
# @return       Does not return when it works (because of the restart!), fail status (1) otherwise
# @example      ❯ _gaudi-bash-update-and-restart v2.1.0
function _gaudi-bash-update-and-restart() {
	about 'Checks out the wanted version, updates the git submodules and restarts. Does not return (because of the restart!)'
	group 'gaudi-bash:core:updater'

	if ! git -C "${GAUDI_BASH?}" checkout "$1" &> /dev/null; then
		echo "Error updating gaudi-bash, please check if your gaudi-bash installation folder (${GAUDI_BASH}) is clean."
		return 1
	fi

	# Bring the components (git submodules) to the versions pinned by the version that was just checked out
	if ! _gaudi-bash-submodules-update "$GAUDI_BASH" &> /dev/null; then
		echo "gaudi-bash was updated but its components (git submodules) were not, please run: git -C '${GAUDI_BASH}' submodule update --init --recursive"
		return 1
	fi

	# Links made by older versions hold an absolute path, they are rewritten as relative ones
	_gaudi-bash-migrate-enabled-links > /dev/null

	echo "gaudi-bash successfully updated."
	_gaudi-bash-restart
}

# @function     _gaudi-bash-update
# @description  Updates gaudi-bash to the latest release (stable) or to the tip of the development branch (dev)
#               Works on the shallow clone the installer makes: the history is completed first, so that it can
#               tell an update from a step back
# @param $1     (optional) What kind of update to do (stable|dev)
# @example      ❯  _gaudi-bash-update
function _gaudi-bash-update() {
	about 'updates gaudi-bash'
	group 'gaudi-bash:core:updater'

	local silent word mode changes version target revision revert log_color answer
	local remote="${GAUDI_BASH_REMOTE:-origin}" branch="${GAUDI_BASH_DEVELOPMENT_BRANCH:-main}"
	local -a git=(git -C "${GAUDI_BASH?}")

	for word in "$@"; do
		if [[ "${word}" == "--silent" || "${word}" == "-s" ]]; then
			silent=true
		elif [[ -z "${mode:-}" ]]; then
			# The first word that is not a flag is the update mode
			mode="${word}"
		fi
	done

	if [[ -n "${mode:-}" && "${mode}" != "stable" && "${mode}" != "dev" ]]; then
		echo "Unknown update mode: ${mode}"
		echo "Usage: gbash update [stable|dev] [--silent]"
		return 1
	fi

	# Only changes to tracked files block an update: a submodule that is not at the pinned commit is brought back in line after the checkout
	changes=$("${git[@]}" status --porcelain --untracked-files=no --ignore-submodules=all) || return 1
	if [[ -n "$changes" ]]; then
		echo -e "Local changes detected in gaudi-bash directory. Clean '$GAUDI_BASH' directory to proceed.\n$changes"
		return 1
	fi

	# A shallow clone (what the installer makes) does not know how its commit relates to the others: get the history first
	if [[ "$("${git[@]}" rev-parse --is-shallow-repository 2> /dev/null)" == "true" ]]; then
		"${git[@]}" fetch --unshallow "$remote" &> /dev/null
	fi

	if ! "${git[@]}" fetch "$remote" --tags &> /dev/null; then
		echo "Unable to fetch from '$remote', can not check for gaudi-bash updates."
		return 1
	fi

	if [[ -z "${mode:-}" || "${mode}" == "stable" ]]; then
		version="stable"
		target=$("${git[@]}" describe --tags "$("${git[@]}" rev-list --tags --max-count=1 2> /dev/null)" 2> /dev/null)

		if [[ -z "$target" ]]; then
			echo "Can not find tags, so can not update to latest stable version..."
			return 1
		fi
	else
		version="dev"
		target="${remote}/${branch}"

		# A clone of a release tag does not track the development branch, it is fetched by name
		if ! "${git[@]}" fetch "$remote" "+refs/heads/${branch}:refs/remotes/${remote}/${branch}" &> /dev/null; then
			echo "Unable to fetch the '$branch' branch from '$remote', can not check for gaudi-bash updates."
			return 1
		fi
	fi

	# Which way the target lies: ahead of this version (an update), behind it (a step back), or nowhere (the same commit)
	if [[ "$("${git[@]}" rev-parse HEAD)" == "$("${git[@]}" rev-parse "${target}^{commit}" 2> /dev/null)" ]]; then
		revision=""
	elif "${git[@]}" merge-base --is-ancestor "$target" HEAD 2> /dev/null; then
		# This version already holds the target: only the stable mode offers to go back to the release
		revision=""
		if [[ "${version}" == "stable" ]]; then
			revision="${target}..HEAD"
			revert=true
		fi
	else
		revision="HEAD..${target}"
	fi

	if [[ -z "$revision" ]]; then
		if [[ "${version}" == "stable" ]]; then
			echo "You're on the latest stable version. If you want to check out the latest 'dev' version, please run \"gbash update dev\""
		else
			echo "gaudi-bash is up to date, nothing to do!"
		fi
		return 0
	fi

	if [[ -n "${revert:-}" ]]; then
		echo "Your version is a more recent development version ($("${git[@]}" log -1 --format=%h HEAD))"
		echo "You can continue in order to revert and update to the latest stable version"
		echo ""
		log_color="%Cred"
	fi

	"${git[@]}" log --no-merges --format="${log_color:-}%h: %s (%an)" "${revision}"
	echo ""

	if [[ -n "${silent:-}" ]]; then
		echo "Updating to ${target}($("${git[@]}" log -1 --format=%h "${target}"))..."
		_gaudi-bash-update-and-restart "$target"
		return
	fi

	read -r -e -n 1 -p "Would you like to update to ${target}($("${git[@]}" log -1 --format=%h "${target}"))? [Y/n] " answer
	case "$answer" in
		[yY] | "")
			_gaudi-bash-update-and-restart "$target"
			;;
		[nN])
			echo "Not updating…"
			;;
		*)
			echo -e "${YELLOW}Please choose y or n.${NC}"
			return 1
			;;
	esac
}
