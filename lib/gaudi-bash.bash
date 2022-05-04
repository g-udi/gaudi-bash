#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC1090,SC2034,SC2001

export GAUDI_BASH_LOAD_PRIORITY_SEPARATOR="___"

# Load all the helper libraries
for helper in "${GAUDI_BASH}"/lib/helpers/*.bash; do source "$helper"; done

# @function     _gaudi-bash-version
# @description  prints the gaudi-bash version
#               shows current git SHA, commit hash and the remote that was compared against
# @return       current git SHA e.g., Current git SHA: 47d1e26 on 2020-10-01T17:50:08-07:00
#               last git commit link e.g., git@github.com:g-udi/gaudi-bash/commit/47d1e26
#               latest remote e.g., Compare to latest: git@github.com:g-udi/gaudi-bash/compare/47d1e26...master
_gaudi-bash-version() {
	about "shows current gaudi-bash version with the Current git SHA and commit hash"
	group "gaudi-bash:core"

	cd "${GAUDI_BASH}" || return

	if [[ -z $GAUDI_BASH_REMOTE ]]; then
		GAUDI_BASH_REMOTE="origin"
	fi

	GAUDI_BASH_GIT_REMOTE=$(git remote get-url $GAUDI_BASH_REMOTE)
	GAUDI_BASH_GIT_URL=${GAUDI_BASH_GIT_REMOTE%.git}

	GAUDI_BASH_GIT_VERSION_INFO="$(git log --pretty=format:'%h on %aI' -n 1)"
	GAUDI_BASH_GIT_SHA=${GAUDI_BASH_GIT_VERSION_INFO%% *}

	echo -e "Current git SHA: ${GREEN}$GAUDI_BASH_GIT_VERSION_INFO${NC}"
	echo -e "${MAGENTA}$GAUDI_BASH_GIT_URL/commit/$GAUDI_BASH_GIT_SHA${NC}"
	echo -e "Compare to latest: ${YELLOW}$GAUDI_BASH_GIT_URL/compare/$GAUDI_BASH_GIT_SHA...master${NC}"

	cd - &> /dev/null || return

}

# @function     _gaudi-bash-reload
# @description  reloads the bash profile
#               reloads the profile that corresponds to the correct OS type (.bashrc, .bash_profile)
_gaudi-bash-reload() {
	about "reloads the bash profile that corresponds to the correct OS type (.bashrc, .bash_profile)"
	group "gaudi-bash:core"

	pushd "${GAUDI_BASH}" &> /dev/null || return

	case $OSTYPE in
		darwin*)
			source "$HOME/.bash_profile"
			;;
		*)
			source "$HOME/.bashrc"
			;;
	esac

	popd &> /dev/null || return
}

# @function     _gaudi-bash-restart
# @description  restarts the bash profile
#               restarts the profile that corresponds to the correct OS type (.bashrc, .bash_profile) preserving context
function _gaudi-bash-restart() {
	_about 'restarts the shell in order to fully reload it'
	group "gaudi-bash:core"

	exec "${0#-}" --rcfile "${BASH_IT_BASHRC:-${HOME?}/.bashrc}"
}

# @function     _gaudi-bash-help
# @description  shows help command of a component (alias, plugin, completion)
# @param $1     type: component type of: aliases, plugins, completions
# @param $2     component: component name to show help for
# @return       help list for each component
#               completions: show list of completion components in the gaudi-bash show table
#               aliases: show list of aliases in either 1) all enabled aliases if no alias was passed or 2) a specific alias
#               plugins: show function descriptions of either 1) all enabled plugins if no plugin was passed or 2) a specific plugin
_gaudi-bash-help() {
	! __check-function-parameters "$1" && reference gaudi-bash && return 0

	local type component

	type="$(_gaudi-bash-pluralize-component "$1")"
	_command_exists _help-"${type}" && _help-"${type}" "$2"
}

# @function     _gaudi-bash-show
# @description  shows a list of all items of a component (alias, plugin, completion)
#               if no param was passed, shows all enabled components across.
#               components descriptions are retrieved via the composure metadata 'about'
# @param $1     type: component type of: aliases, plugins, completions
# @param $2     mode <enabled, all>: either show all available components or filter only for enabled ones
# @return       table showing each component name, status (enabled/disabled) and description
_gaudi-bash-show() {
	about "list available gaudi_bash components or allow filtering for a specific type e.g., plugins, aliases, completions"
	group "gaudi-bash:core"

	if [[ -n "$1" ]]; then
		_gaudi-bash-describe "$1" "$2"
	else
		for file_type in "aliases" "plugins" "completions"; do
			_gaudi-bash-describe "$file_type" "enabled"
		done
	fi
}

# @function     _gaudi-bash-backup
# @description  backs up enabled components (plugins, aliases, completions)
#               the function writes "enable" commands into a file in $GAUDI_BASH/tmp/enabled.gaudi-bash.backup
# @return       $GAUDI_BASH/tmp/enabled.gaudi-bash.backup file with 'gaudi-bash enable' commands
_gaudi-bash-backup() {
	about "backs up enabled components (plugins, aliases, completions)"
	group "gaudi-bash:core"

	# Clear out the existing backup file
	echo -n "" > "${GAUDI_BASH}/tmp/enabled.gaudi-bash.backup"

	for _file in "${GAUDI_BASH}"/components/enabled/*.bash; do
		local _component _type

		_component="$(echo "$_file" | sed -e "s/.*$GAUDI_BASH_LOAD_PRIORITY_SEPARATOR\(.*\).bash.*/\1/")"
		_type=$(_gaudi-bash-singularize-component "${_component##*.}")
		_component=${_component%%.*}

		echo "Backing up $_type: ${_component}"
		printf "%s\n" "gaudi-bash enable ${_type} ${_component}" >> "${GAUDI_BASH}/tmp/enabled.gaudi-bash.backup"

	done
}

# @function     _gaudi-bash-restore
# @description  restores enabled gaudi-bash components
#               the function gets the list of enabled commands from the backup file in $GAUDI_BASH/tmp/enabled.gaudi-bash.backup
# @return       status message to indicate the outcome
_gaudi-bash-restore() {
	about "restores enabled components (plugins, aliases, completions)"
	group "gaudi-bash:core"

	! [[ -f "${GAUDI_BASH}/tmp/enabled.gaudi-bash.backup" ]] && echo -e "${RED}No valid backup file found :(${NC}" && return

	while IFS= read -r line; do
		$line
	done < "${GAUDI_BASH}/tmp/enabled.gaudi-bash.backup"
}

gaudi-bash() {
	about 'provides a solid framework for using, developing and maintaining shell scripts and custom commands for your daily work'
	param '1: verb [one of: help | backup | show | enable | disable | update | restore | search | version | reload | doctor ]] '
	param '2: component type [one of: alias(es) | completion(s) | plugin(s) ]] or search term(s)'
	param '3: specific component [optional]'

	example '$ gaudi-bash show plugins'
	example '$ gaudi-bash help aliases'
	example '$ gaudi-bash enable plugin git [tmux]...'
	example '$ gaudi-bash disable alias hg [tmux]...'
	example '$ gaudi-bash update'
	example '$ gaudi-bash backup'
	example '$ gaudi-bash help plugins'
	example '$ gaudi-bash search [-|@]term1 [-|@]term2 ... [[ -e/--enable ]] [[ -d/--disable ]] [[ -r/--refresh ]] [[ -c/--no-color ]]'
	example '$ gaudi-bash version'
	example '$ gaudi-bash reload'
	example '$ gaudi-bash doctor errors|warnings|all'

	local verb=${1:-}
	shift
	local component=${1:-}
	shift
	local func

	case $verb in
		show)
			func=_gaudi-bash-show
			;;
		enable)
			func=_gaudi-bash-enable
			;;
		disable)
			func=_gaudi-bash-disable
			;;
		help)
			_gaudi-bash-help "$component" "$@"
			return
			;;
		doctor)
			func=_gaudi-bash-doctor
			;;
		update)
			_gaudi-bash-update "$component" "$@"
			return
			;;
		version)
			func=_gaudi-bash-version
			;;
		backup)
			func=_gaudi-bash-backup
			;;
		restore)
			func=_gaudi-bash-restore
			;;
		reload)
			func=_gaudi-bash-reload
			;;
		search)
			_gaudi-bash-search "$component" "$@"
			return
			;;
		*)
			reference gaudi-bash
			return
			;;
	esac

	if [[ "$verb" == "enable" || "$verb" == "disable" ]] && [[ ${#@} != 0 ]]; then
		for arg in "$@"; do
			$func "$(_gaudi-bash-pluralize-component "$component")" "$arg"
		done
	else
		$func "$(_gaudi-bash-pluralize-component "$component")" "$@"
	fi

}
