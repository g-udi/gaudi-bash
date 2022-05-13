#!/usr/bin/env bash
# shellcheck shell=bash

# @function     _on-disable-callback
# @description  calls the disabled plugin destructor, if present
# @param $1     component name: gaudi-bash component name .e.g., base, git
_on-disable-callback() {
	callback=$1_on_disable
	_command_exists "$callback" &> /dev/null && $callback
}

# @function     _gaudi-bash-disable
# @description  disables a component
# @param $1     component type: gaudi-bash component of type aliases, plugins, completions
# @param $2     component name: gaudi-bash component name .e.g., base, git
# @return       message to indicate the outcome
_gaudi-bash-disable() {
	about "disable a gaudi-bash component (plugin, component, alias)"
	group "gaudi-bash:core"

	! __check-function-parameters "$1" && printf "${RED}%s${NC}\n" "Please enter a valid component to disable" && return 1

	local type component

	# Make sure the component is pluralized in case this function is called directly e.g., for unit tests
	type=$(_gaudi-bash-pluralize-component "$1")
	type_singular=$(_gaudi-bash-singularize-component "$1")
	component="$2"

	# Capture if the user prompted for a disable all and iterate on all components
	if [[ "$type" = "alls" ]] && [[ -z "$component" ]]; then
		_read_input "This will disable all gaudi-bash components (aliases, plugins and completions). Are you sure you want to proceed? [yY/nN]"
		if [[ $REPLY =~ ^[yY]$ ]]; then
			for file_type in "aliases" "plugins" "completions"; do
				_gaudi-bash-disable "$file_type" "all"
			done
		fi
		return 0
	fi

	if [[ "$component" = "all" ]]; then
		find "${GAUDI_BASH}/components/enabled" -name "*.${type}.bash" -exec rm {} \;
	else

		[[ -z "$component" ]] && printf "${RED}%s ${GREEN}$type_singular(s) ${RED}%s${NC}\n" "Please enter a valid" "to disable" && return 1

		local _component

		_component=$(command ls $ "${GAUDI_BASH}/components/enabled/"[0-9]*"$GAUDI_BASH_LOAD_PRIORITY_SEPARATOR$component.$type.bash" 2> /dev/null | head -1)

		if [[ -z "$_component" ]]; then
			printf "${CYAN}$component ${RED}%s ${GREEN}$type_singular${NC}\n" "does not appear to be an enabled"
			return 1
		else
			rm "${GAUDI_BASH}/components/enabled/$(basename "$_component")"
		fi
	fi

	_gaudi-bash-component-cache-clean "${type}"

	printf "${RED}%s ${GREEN}$type_singular: ${CYAN}$component${NC}\n" "◯ disabled"

	[[ $type == "plugins" ]] && _on-disable-callback "$component"

	if [[ -n "$GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE" ]]; then
		_gaudi-bash-reload
	fi

	return 0
}
