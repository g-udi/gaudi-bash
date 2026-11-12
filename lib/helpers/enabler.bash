#!/usr/bin/env bash
# shellcheck shell=bash

GAUDI_BASH_LOAD_PRIORITY_DEFAULT_ALIASES=${GAUDI_BASH_LOAD_PRIORITY_DEFAULT_ALIASES:-150}
GAUDI_BASH_LOAD_PRIORITY_DEFAULT_PLUGINS=${GAUDI_BASH_LOAD_PRIORITY_DEFAULT_PLUGINS:-250}
GAUDI_BASH_LOAD_PRIORITY_DEFAULT_COMPLETIONS=${GAUDI_BASH_LOAD_PRIORITY_DEFAULT_COMPLETIONS:-350}

# @function     _gaudi-bash-enable
# @description  enables a component
#               the link made in components/enabled is relative, so that it survives moving the installation
#               a component whose link points to a missing file is linked again
# @param $1     component type: gaudi-bash component of type aliases, plugins, completions
# @param $2     component name: gaudi-bash component name .e.g., base, git (or "all")
# @return       message to indicate the outcome, fail status (1) when a component could not be enabled
_gaudi-bash-enable() {

	about "enable a gaudi-bash component (plugin, completion, alias)"
	group "gaudi-bash:core"

	mkdir -p "${GAUDI_BASH}/components/enabled"

	! __check-function-parameters "$1" && printf "%s\n" "Please enter a valid component to enable" && return 1

	local type type_singular component load_priority

	# Make sure the component is pluralized in case this function is called directly e.g., for unit tests
	type=$(_gaudi-bash-pluralize-component "$1")
	type_singular=$(_gaudi-bash-singularize-component "$1")
	local _load_priority type_upper
	type_upper=$(printf "%s" "$type" | tr "[:lower:]" "[:upper:]")
	_load_priority="GAUDI_BASH_LOAD_PRIORITY_DEFAULT_${type_upper}"
	component="$2"
	load_priority="${!_load_priority}"

	[[ -z "$component" ]] && printf "${RED}%s${NC}\n" "Please enter a valid $type_singular(s) to enable" && return 1

	local _component

	if [[ "$component" = "all" ]]; then
		local _failed=""

		for _component in "${GAUDI_BASH}/components/$type/lib/"*."$type".bash; do
			[[ -e "$_component" ]] || continue
			_component="${_component##*/}"
			# Every component reports on its own, the reload is left to the end
			GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE="" _gaudi-bash-enable "$type" "${_component%."$type".bash}" || _failed=true
		done

		if [[ -n "$GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE" ]]; then
			_gaudi-bash-reload-after-change
		fi

		[[ -z "$_failed" ]]
		return
	fi

	_component="${component}.${type}.bash"

	if [[ ! -e "${GAUDI_BASH}/components/$type/lib/$_component" ]]; then
		printf "${CYAN}%s ${RED}%s ${GREEN}%s${NC}\n" "$component" "does not appear to be an available" "$type_singular"
		return 1
	fi

	local _enabled

	if _enabled=$(_gaudi-bash-component-enabled-file "$type" "$component"); then
		if [[ -e "$_enabled" ]]; then
			printf "${GREEN}%s ${CYAN}%s${NC} %s\n" "$type_singular" "$component" "is already enabled"
			return 0
		fi
		# The link points to a file that is gone (e.g., the installation was moved): link the component again
		rm -f "$_enabled"
	fi

	# Load the priority from the file if it present there
	local local_file_priority use_load_priority

	local_file_priority=$(metafor priority < "${GAUDI_BASH}/components/$type/lib/$_component")
	use_load_priority=${local_file_priority:-$load_priority}
	if ! ln -s "$(_gaudi-bash-component-link-target "$type" "$_component")" "${GAUDI_BASH}/components/enabled/${use_load_priority}${GAUDI_BASH_LOAD_PRIORITY_SEPARATOR}${_component}"; then
		printf "${RED}%s ${GREEN}%s${NC}: ${CYAN}%s${NC}\n" "Could not enable" "$type_singular" "$component"
		return 1
	fi

	printf "${GREEN}%s %s: ${CYAN}%s${NC} %s ${RED}%s${NC}\n" "◉" "$type_singular" "$component" "enabled with priority" "$use_load_priority"

	if [[ -n "$GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE" ]]; then
		_gaudi-bash-reload-after-change
	fi

	return 0
}
