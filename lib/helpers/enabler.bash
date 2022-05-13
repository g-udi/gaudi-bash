#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2002

GAUDI_BASH_LOAD_PRIORITY_DEFAULT_ALIASES=${GAUDI_BASH_LOAD_PRIORITY_DEFAULT_ALIASES:-150}
GAUDI_BASH_LOAD_PRIORITY_DEFAULT_PLUGINS=${GAUDI_BASH_LOAD_PRIORITY_DEFAULT_PLUGINS:-250}
GAUDI_BASH_LOAD_PRIORITY_DEFAULT_COMPLETIONS=${GAUDI_BASH_LOAD_PRIORITY_DEFAULT_COMPLETIONS:-350}

# @function     _gaudi-bash-enable
# @description  enables a component
# @param $1     component type: gaudi-bash component of type aliases, plugins, completions
# @param $2     component name: gaudi-bash component name .e.g., base, git
# @return       message to indicate the outcome
_gaudi-bash-enable() {

	about "enable a gaudi-bash component (plugin, component, alias)"
	group "gaudi-bash:core"

	! __check-function-parameters "$1" && printf "%s\n" "Please enter a valid component to enable" && return 1

	local type component load_priority

	# Make sure the component is pluralized in case this function is called directly e.g., for unit tests
	type=$(_gaudi-bash-pluralize-component "$1")
	type_singular=$(_gaudi-bash-singularize-component "$1")
	_load_priority="GAUDI_BASH_LOAD_PRIORITY_DEFAULT_${type^^}"
	component="$2"
	load_priority="${!_load_priority}"

	# Capture if the user prompted for a disable all and iterate on all components
	if [[ "$type" = "alls" ]] && [[ -z "$component" ]]; then
		_read_input "This will enable all gaudi-bash components (aliases, plugins and completions). Are you sure you want to proceed? [yY/nN]"
		if [[ $REPLY =~ ^[yY]$ ]]; then
			for file_type in "aliases" "plugins" "completions"; do
				_gaudi-bash-enable "$file_type" "all"
			done
		fi
		return 0
	fi

	[[ -z "$component" ]] && printf "${RED}%s${NC}\n" "Please enter a valid $type_singular(s) to enable" && return 1

	if [[ "$component" = "all" ]]; then
		local _component
		for _component in "${GAUDI_BASH}/components/$type/lib/"*.bash; do
			_gaudi-bash-enable "$type" "$(basename "$_component" ."$type".bash)"
		done
	else
		local _component

		_component=$(command ls "${GAUDI_BASH}/components/$type/lib/$component".*bash 2> /dev/null | head -1)

		[[ -z "$_component" ]] && printf "${CYAN}$component ${RED}%s ${GREEN}$type_singular${NC}\n" "does not appear to be an available" && return 1
		_component=$(basename "$_component")

		local enabled_component

		enabled_component=$(command compgen -G "${GAUDI_BASH}/components/enabled/[0-9][0-9][0-9]$GAUDI_BASH_LOAD_PRIORITY_SEPARATOR$_component" 2> /dev/null | head -1)
		if [[ -n "$enabled_component" ]]; then
			printf "${GREEN}$type_singular ${CYAN}$component${NC} %s\n" "is already enabled"
			return 0
		fi

		mkdir -p "${GAUDI_BASH}/components/enabled"

		# Load the priority from the file if it present there
		declare local_file_priority use_load_priority

		local_file_priority=$(cat "${GAUDI_BASH}/components/$type/lib/$_component" | metafor priority)
		use_load_priority=${local_file_priority:-$load_priority}
		echo "linking now to:     ---> $GAUDI_BASH"
		ln -s "${GAUDI_BASH}"/components/"$type"/lib/"$_component" "${GAUDI_BASH}/components/enabled/${use_load_priority}${GAUDI_BASH_LOAD_PRIORITY_SEPARATOR}${_component}"
	fi

	_gaudi-bash-component-cache-clean "${type}"

	printf "${GREEN}%s $type_singular: ${CYAN}$component${NC} %s ${RED}$use_load_priority${NC}\n" "◉" "enabled with priority"

	if [[ -n "$GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE" ]]; then
		_gaudi-bash-reload
	fi

	return 0
}
