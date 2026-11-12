#!/usr/bin/env bash
# shellcheck shell=bash

# @function     _on-disable-callback
# @description  calls the disabled plugin destructor, if present
# @param $1     component name: gaudi-bash component name .e.g., base, git
_on-disable-callback() {
	local callback=$1_on_disable
	declare -F "$callback" > /dev/null && $callback
}

# @function     _gaudi-bash-disable
# @description  disables a component
# @param $1     component type: gaudi-bash component of type aliases, plugins, completions
# @param $2     component name: gaudi-bash component name .e.g., base, git (or "all")
# @return       message to indicate the outcome
_gaudi-bash-disable() {
	about "disable a gaudi-bash component (plugin, completion, alias)"
	group "gaudi-bash:core"

	! __check-function-parameters "$1" && printf "${RED}%s${NC}\n" "Please enter a valid component to disable" && return 1

	local type type_singular component

	# Make sure the component is pluralized in case this function is called directly e.g., for unit tests
	type=$(_gaudi-bash-pluralize-component "$1")
	type_singular=$(_gaudi-bash-singularize-component "$1")
	component="$2"

	if [[ "$component" = "all" ]]; then
		local _name

		for _name in $(_gaudi-bash-component-list-enabled "$type"); do
			rm -f "$(_gaudi-bash-component-enabled-file "$type" "$_name")"
			# Every plugin gets the chance to clean up after itself
			[[ $type == "plugins" ]] && _on-disable-callback "$_name"
		done
	else

		[[ -z "$component" ]] && printf "${RED}%s ${GREEN}%s(s) ${RED}%s${NC}\n" "Please enter a valid" "$type_singular" "to disable" && return 1

		local _component

		if ! _component=$(_gaudi-bash-component-enabled-file "$type" "$component"); then
			printf "${RED}∴${NC} ${CYAN}%s ${NC}%s ${GREEN}%s${NC}\n" "$component" "does not appear to be an enabled" "$type_singular"
			return 1
		fi
		rm "$_component" || return 1

		[[ $type == "plugins" ]] && _on-disable-callback "$component"
	fi

	printf "${CYAN}%s ${GREEN}%s: ${CYAN}%s${NC}\n" "◯ disabled" "$type_singular" "$component"

	if [[ -n "$GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE" ]]; then
		_gaudi-bash-reload-after-change
	fi

	return 0
}
