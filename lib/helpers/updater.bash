#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2181

_gaudi-bash-update-usage() {
	printf "%s\n" "Usage: gaudi-bash update [stable|dev|all] [--silent|-s]"
}

_gaudi-bash-update-sync-submodules() {
	git submodule sync --recursive \
		&& git submodule update --init --recursive
}

# @function     _gaudi-bash_update_and_restart
# @description  Checks out the wanted version, pops directory and restart
# @param $1     (optional) Which branch to checkout to
# @param $2     (optional) Which type of version we are using
# @example      ❯ _gaudi-bash_update_and_restarts
function _gaudi-bash_update_and_restart() {
	about 'Checks out the wanted version, pops directory and restart. Does not return (because of the restart!)'
	group 'gaudi-bash:core:updater'

	local target="$1"
	local mode="$2"

	git checkout "$target" &> /dev/null
	if [[ $? -eq 0 ]]; then
		if [[ "$mode" == "all" ]] && ! _gaudi-bash-update-sync-submodules; then
			echo "Error updating gaudi-bash components, please check the components submodules."
			return 1
		fi

		echo "gaudi-bash successfully updated."
		popd &> /dev/null || return
		_gaudi-bash-restart
	else
		echo "Error updating gaudi-bash, please check if your gaudi-bash installation folder (${GAUDI_BASH}) is clean."
		return 1
	fi
}

# @function      _gaudi-bash-update
# @description  Updates gaudi-bash
# @param $1     (optional) What kind of update to do (stable|dev)
# @example      ❯  _gaudi-bash-update
function _gaudi-bash-update() {
	about 'updates gaudi-bash'
	group 'gaudi-bash:core:updater'

	local silent word DIFF version TARGET revision status revert log_color RESP mode update_label
	local -a modes=()
	for word in "$@"; do
		case "${word}" in
			"--silent" | "-s")
				silent=true
				;;
			"stable" | "dev" | "all")
				modes+=("${word}")
				;;
			*)
				_gaudi-bash-update-usage
				return 1
				;;
		esac
	done

	if [[ ${#modes[@]} -gt 1 ]]; then
		_gaudi-bash-update-usage
		return 1
	fi

	mode="${modes[0]:-stable}"

	pushd "${GAUDI_BASH?}" > /dev/null || return

	DIFF=$(git diff --name-status)
	if [[ -n "$DIFF" ]]; then
		echo -e "Local changes detected in gaudi-bash directory. Clean '$GAUDI_BASH' directory to proceed.\n$DIFF"
		popd > /dev/null || return
		return 1
	fi

	if [[ -z "$GAUDI_BASH_REMOTE" ]]; then
		GAUDI_BASH_REMOTE="origin"
	fi

	git fetch "$GAUDI_BASH_REMOTE" --tags &> /dev/null

	if [[ -z "$GAUDI_BASH_DEVELOPMENT_BRANCH" ]]; then
		GAUDI_BASH_DEVELOPMENT_BRANCH="master"
	fi

	case "$mode" in
		stable | all)
			version="stable"
			TARGET=$(git describe --tags "$(git rev-list --tags --max-count=1)" 2> /dev/null)

			if [[ -z "$TARGET" ]]; then
				echo "Can not find tags, so can not update to latest stable version..."
				popd > /dev/null || return
				return 1
			fi
			;;
		dev)
			version="dev"
			TARGET="${GAUDI_BASH_REMOTE}/${GAUDI_BASH_DEVELOPMENT_BRANCH}"
			;;
	esac

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

		update_label="update to ${TARGET}($(git log -1 --format=%h "${TARGET}"))"
		[[ "$mode" == "all" ]] && update_label="${update_label} and sync components"

		if [[ -n "${silent}" ]]; then
			echo "Updating to ${update_label#update to }..."
			_gaudi-bash_update_and_restart "$TARGET" "$mode"
			return $?
		else
			read -r -e -n 1 -p "Would you like to ${update_label}? [Y/n] " RESP
			case "$RESP" in
				[yY] | "")
					_gaudi-bash_update_and_restart "$TARGET" "$mode"
					return $?
					;;
				[nN])
					echo "Not updating…"
					;;
				*)
					echo "Please choose y or n."
					popd > /dev/null || return
					return 1
					;;
			esac
		fi
	else
		if [[ "$mode" == "all" ]]; then
			local submodules_before submodules_after

			submodules_before="$(git submodule status --recursive 2> /dev/null || true)"
			if ! _gaudi-bash-update-sync-submodules; then
				echo "Error updating gaudi-bash components, please check the components submodules."
				popd > /dev/null || return
				return 1
			fi

			submodules_after="$(git submodule status --recursive 2> /dev/null || true)"
			if [[ "$submodules_before" != "$submodules_after" ]]; then
				echo "gaudi-bash components successfully updated."
				popd > /dev/null || return
				_gaudi-bash-restart
				return $?
			fi

			echo "gaudi-bash is up to date, nothing to do!"
		elif [[ "${version}" == "stable" ]]; then
			echo "You're on the latest stable version. If you want to check out the latest 'dev' version, please run \"gaudi-bash update dev\""
		else
			echo "gaudi-bash is up to date, nothing to do!"
		fi
	fi
	popd > /dev/null || return
}
