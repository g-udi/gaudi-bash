# #!/usr/bin/env bash
# shellcheck shell=bash

# function _bash-it-update-() {
# 	_about 'updates Bash-it'
# 	_param '1: What kind of update to do (stable|dev)'
# 	_group 'lib'

# 	local silent word DIFF version TARGET revision status revert log_color RESP
# 	for word in "$@"; do
# 		if [[ "${word}" == "--silent" || "${word}" == "-s" ]]; then
# 			silent=true
# 		fi
# 	done

# 	pushd "${BASH_IT?}" > /dev/null || return

# 	DIFF=$(git diff --name-status)
# 	if [[ -n "$DIFF" ]]; then
# 		echo -e "Local changes detected in bash-it directory. Clean '$BASH_IT' directory to proceed.\n$DIFF"
# 		popd > /dev/null || return
# 		return 1
# 	fi

# 	if [[ -z "$BASH_IT_REMOTE" ]]; then
# 		BASH_IT_REMOTE="origin"
# 	fi

# 	git fetch "$BASH_IT_REMOTE" --tags &> /dev/null

# 	if [[ -z "$BASH_IT_DEVELOPMENT_BRANCH" ]]; then
# 		BASH_IT_DEVELOPMENT_BRANCH="master"
# 	fi
# 	# Defaults to stable update
# 	if [[ -z "${1:-}" || "$1" == "stable" ]]; then
# 		version="stable"
# 		TARGET=$(git describe --tags "$(git rev-list --tags --max-count=1)" 2> /dev/null)

# 		if [[ -z "$TARGET" ]]; then
# 			echo "Can not find tags, so can not update to latest stable version..."
# 			popd > /dev/null || return
# 			return
# 		fi
# 	else
# 		version="dev"
# 		TARGET="${BASH_IT_REMOTE}/${BASH_IT_DEVELOPMENT_BRANCH}"
# 	fi

# 	revision="HEAD..${TARGET}"
# 	status="$(git rev-list "${revision}" 2> /dev/null)"

# 	if [[ -z "${status}" && "${version}" == "stable" ]]; then
# 		revision="${TARGET}..HEAD"
# 		status="$(git rev-list "${revision}" 2> /dev/null)"
# 		revert=true
# 	fi

# 	if [[ -n "${status}" ]]; then
# 		if [[ -n "${revert}" ]]; then
# 			echo "Your version is a more recent development version ($(git log -1 --format=%h HEAD))"
# 			echo "You can continue in order to revert and update to the latest stable version"
# 			echo ""
# 			log_color="%Cred"
# 		fi

# 		git log --no-merges --format="${log_color}%h: %s (%an)" "${revision}"
# 		echo ""

# 		if [[ -n "${silent}" ]]; then
# 			echo "Updating to ${TARGET}($(git log -1 --format=%h "${TARGET}"))..."
# 			_bash-it_update_migrate_and_restart "$TARGET" "$version"
# 		else
# 			read -r -e -n 1 -p "Would you like to update to ${TARGET}($(git log -1 --format=%h "${TARGET}"))? [Y/n] " RESP
# 			case "$RESP" in
# 				[yY] | "")
# 					_bash-it_update_migrate_and_restart "$TARGET" "$version"
# 					;;
# 				[nN])
# 					echo "Not updating…"
# 					;;
# 				*)
# 					echo -e "${echo_orange?}Please choose y or n.${echo_reset_color?}"
# 					;;
# 			esac
# 		fi
# 	else
# 		if [[ "${version}" == "stable" ]]; then
# 			echo "You're on the latest stable version. If you want to check out the latest 'dev' version, please run \"bash-it update dev\""
# 		else
# 			echo "Bash-it is up to date, nothing to do!"
# 		fi
# 	fi
# 	popd > /dev/null || return
# }