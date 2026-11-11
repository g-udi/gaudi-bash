#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2181

# @function     _gaudi-bash_update_and_restart
# @description  Checks out the wanted version, pops directory and restart
# @param $1     (optional) Which branch to checkout to
# @param $2     (optional) Which type of version we are using
# @example      ❯ _gaudi-bash_update_and_restarts
function _gaudi-bash_update_and_restart() {
	about 'Checks out the wanted version, pops directory and restart. Does not return (because of the restart!)'
	group 'gaudi-bash:core:updater'

	if ! git checkout "$1" &> /dev/null; then
		echo "Error updating gaudi-bash, please check if your gaudi-bash installation folder (${GAUDI_BASH}) is clean."
		return 1
	fi

	# Bring the components (git submodules) to the versions pinned by the version that was just checked out
	if ! git submodule update --init --recursive &> /dev/null; then
		echo "gaudi-bash was updated but its components (git submodules) were not, please run: git -C '${GAUDI_BASH}' submodule update --init --recursive"
		return 1
	fi

	echo "gaudi-bash successfully updated."
	popd &> /dev/null || return
	_gaudi-bash-restart
}

# @function      _gaudi-bash-update
# @description  Updates gaudi-bash
# @param $1     (optional) What kind of update to do (stable|dev)
# @example      ❯  _gaudi-bash-update
function _gaudi-bash-update() {
	about 'updates gaudi-bash'
	group 'gaudi-bash:core:updater'

	local silent word mode DIFF version TARGET revision status revert log_color RESP
	local result=0
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

	pushd "${GAUDI_BASH?}" > /dev/null || return

	# Only changes to tracked files block an update: a submodule that is not at the pinned commit is brought back in line after the checkout
	DIFF=$(git status --porcelain --untracked-files=no --ignore-submodules=all)
	if [[ -n "$DIFF" ]]; then
		echo -e "Local changes detected in gaudi-bash directory. Clean '$GAUDI_BASH' directory to proceed.\n$DIFF"
		popd > /dev/null || return
		return 1
	fi

	if [[ -z "$GAUDI_BASH_REMOTE" ]]; then
		GAUDI_BASH_REMOTE="origin"
	fi

	if ! git fetch "$GAUDI_BASH_REMOTE" --tags &> /dev/null; then
		echo "Unable to fetch from '$GAUDI_BASH_REMOTE', can not check for gaudi-bash updates."
		popd > /dev/null || return
		return 1
	fi

	if [[ -z "$GAUDI_BASH_DEVELOPMENT_BRANCH" ]]; then
		GAUDI_BASH_DEVELOPMENT_BRANCH="main"
	fi

	if [[ -z "${mode:-}" || "${mode}" == "stable" ]]; then
		version="stable"
		TARGET=$(git describe --tags "$(git rev-list --tags --max-count=1)" 2> /dev/null)

		if [[ -z "$TARGET" ]]; then
			echo "Can not find tags, so can not update to latest stable version..."
			popd > /dev/null || return
			return
		fi
	else
		version="dev"
		TARGET="${GAUDI_BASH_REMOTE}/${GAUDI_BASH_DEVELOPMENT_BRANCH}"
	fi

	revision="HEAD..${TARGET}"
	status="$(git rev-list "${revision}" 2> /dev/null)"

	if [[ -z "${status}" && "${version}" == "stable" ]]; then
		revision="${TARGET}..HEAD"
		status="$(git rev-list "${revision}" 2> /dev/null)"
		revert=true
	fi

	if [[ -n "${status}" ]]; then
		if [[ -n "${revert}" ]]; then
			echo "Your version is a more recent development version ($(git log -1 --format=%h HEAD))"
			echo "You can continue in order to revert and update to the latest stable version"
			echo ""
			log_color="%Cred"
		fi

		git log --no-merges --format="${log_color}%h: %s (%an)" "${revision}"
		echo ""

		if [[ -n "${silent}" ]]; then
			echo "Updating to ${TARGET}($(git log -1 --format=%h "${TARGET}"))..."
			_gaudi-bash_update_and_restart "$TARGET" "$version" || result=1
		else
			read -r -e -n 1 -p "Would you like to update to ${TARGET}($(git log -1 --format=%h "${TARGET}"))? [Y/n] " RESP
			case "$RESP" in
				[yY] | "")
					_gaudi-bash_update_and_restart "$TARGET" "$version" || result=1
					;;
				[nN])
					echo "Not updating…"
					;;
				*)
					echo -e "${YELLOW}Please choose y or n.${NC}"
					;;
			esac
		fi
	else
		if [[ "${version}" == "stable" ]]; then
			echo "You're on the latest stable version. If you want to check out the latest 'dev' version, please run \"gbash update dev\""
		else
			echo "gaudi-bash is up to date, nothing to do!"
		fi
	fi
	popd > /dev/null || return
	return "$result"
}
