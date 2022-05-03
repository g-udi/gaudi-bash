#!/usr/bin/env bash
# shellcheck shell=bash

export GAUDI_BASH_COMPONENT_TYPES=(plugins aliases completions)

# Component-specific functions (component is either an alias, a plugin, or a completion).

# @function     __check-function-parameters
# @description  check the passed parameter to make sure its valid and matches a component type
# @param $1     component: the component type (plugin, alias, completion)
# @return       success (0) or failure status (1)
# @example      ❯ __check-function-parameters plugin
__check-function-parameters() {
	about "check the passed parameter to make sure its valid and matches a component type"
	group "gaudi-bash:core:components"

	[[ -z "$1" ]] && return 1
	_array-contains "$(_gaudi-bash-pluralize-component "${1}")" "${GAUDI_BASH_COMPONENT_TYPES[@]}" && return 0
	return 1
}

# @function     _gaudi-bash-pluralize-component
# @description  pluralize component name for consistency especially for search
# @param $1     component: the component type (plugin, alias, completion)
# @return       plural form of the component type
# @example      ❯ _gaudi-bash-pluralize-component plugin
_gaudi-bash-pluralize-component() {
	about "pluralize component name for consistency especially for search"
	group "gaudi-bash:core:components"

	local component="${1}"
	local len=$((${#component} - 1))

	[[ -n $component ]] || return 1

	[[ ${component:${len}:1} != 's' ]] && component="${component}s"
	[[ ${component} == "alias" ]] && component="aliases"

	printf "%s" "${component}"
}

# @function     _gaudi-bash-singularize-component
# @description  singularize component name for consistency especially for search
# @param $1     component: the component type (plugin, alias, completion)
# @return       singular form of the component type
# @example      ❯ _gaudi-bash-singularize-component plugins
_gaudi-bash-singularize-component() {
	about "singularize component name for consistency especially for search"
	group "gaudi-bash:core:components"

	__check-function-parameters "$1" || return 1

	local component="${1}"

	# Handle aliases -> alias and plugins -> plugin, etc.
	[[ "$component" == *es ]] && component_singular=${component/es/}
	[[ "$component" == *ns ]] && component_singular=${component/ns/n}

	printf "%s" "${component_singular:-$component}"
}

# @function     _gaudi-bash-component-help
# @description  show the about description for a component
#               if no component is passed then the list of all components of the passed type will be show (proxy for gaudi-bash show <component>)
#               the function caches the first call to speed up search and grep after the first run
# @param $1     type: the component type (plugin, alias, completion)
# @param $2     component: the component name
# @return       component help
# @example      ❯ _gaudi-bash-component-help plugins git
_gaudi-bash-component-help() {
	about "show the about description for a component"
	group "gaudi-bash:core:components"

	local type component

	__check-function-parameters "$1" || return 1

	type=$(_gaudi-bash-pluralize-component "${1}")
	component="$2"
	help=$(_gaudi-bash-show "$type" | tail -n +4)

	# If there is a component passed then grep the type list
	if [[ -n $component ]]; then
		printf "%s" "$help" | grep "${component}" && return 0
		return 1
	fi
	printf "%s" "${help}"
}

# @function     _gaudi-bash-component-list
# @description  returns a list of items within each component (plugin, alias, completion)
# @param $1     type: the component type (plugin, alias, completion)
# @return       <array> list of components
# @example      ❯ _gaudi-bash-component-list plugins
_gaudi-bash-component-list() {
	about "returns a list of items within each component (plugin, alias, completion)"
	group "gaudi-bash:core:components"

	__check-function-parameters "$1" || return 1
	_gaudi-bash-component-help "$1" | awk '{print $1}' | uniq | sort | tr '\n' ' '
}

# @function     _gaudi-bash-component-list
# @description  returns a list of items within each component (plugin, alias, completion) that match a string
# @param $1     type: the component type (plugin, alias, completion)
# @param $2     component: the component name (search string) to match against
# @return       <array> list of matched components
# @example      ❯ _gaudi-bash-component-list-matching plugins git
_gaudi-bash-component-list-matching() {
	about "returns a list of items within each component (plugin, alias, completion) that match a string "
	group "gaudi-bash:core:components"

	__check-function-parameters "$1" || return 1
	if [[ -n "$1" ]] && [[ -n "$2" ]]; then
		local match
		match=$(_gaudi-bash-component-help "$1" | $(_gaudi-bash-grep) -E -- "$2" | awk '{print $1}' | uniq | sort | tr '\n' ' ')
		[[ -n "$match" ]] && echo "$match" && return 0
	fi
	return 1
}

# @function     _gaudi-bash-component-list-enabled
# @description  returns a list of enabled items within each component (plugin, alias, completion)
# @param $1     type: the component type (plugin, alias, completion)
# @return       <array> list of enabled components
# @example      ❯ _gaudi-bash-component-list-enabled plugins
_gaudi-bash-component-list-enabled() {
	about "returns a list of enabled items within each component (plugin, alias, completion)"
	group "gaudi-bash:core:components"

	__check-function-parameters "$1" || return 1
	_gaudi-bash-component-help "${1}" | $(_gaudi-bash-grep) -E '◉' | awk '{print $1}' | uniq | sort | tr '\n' ' '
}

# @function     _gaudi-bash-component-list-disabled
# @description  returns a list of disabled items within each component (plugin, alias, completion)
# @param $1     type: the component type (plugin, alias, completion)
# @return       <array> list of disabled components
# @example      ❯ _gaudi-bash-component-list-disabled plugins
_gaudi-bash-component-list-disabled() {
	about "returns a list of disabled items within each component (plugin, alias, completion)"
	group "gaudi-bash:core:components"

	__check-function-parameters "$1" || return 1
	_gaudi-bash-component-help "${1}" | $(_gaudi-bash-grep) -E '◯' | awk '{print $1}' | uniq | sort | tr '\n' ' '
}

# @function     _gaudi-bash-component-item-is-enabled
# @description  checks if a given item is enabled for a particular component/file-type
#               Uses the component cache if available
# @param $1     type: the component type (plugin, alias, completion)
# @param $2     component: the component name (search string) to match against
# @return       success status (0) if an item of the component is enabled, fail status (1) otherwise.
# @example      ❯ _gaudi-bash-component-item-is-enabled alias git && echo "git alias is enabled"
_gaudi-bash-component-item-is-enabled() {
	about "checks if a given item is enabled for a particular component/file-type"
	group "gaudi-bash:core:components"

	__check-function-parameters "$1" || return 1
	if [[ -n "$1" ]] && [[ -n "$2" ]]; then
		_gaudi-bash-component-list-enabled "$1" | tr ' ' '\n' | $(_gaudi-bash-grep) -E -q -- "^${2}$"
	else
		return 1
	fi
}

# @function     _gaudi-bash-component-item-is-disabled
# @description  checks if a given item is disabled for a particular component/file-type
#               Uses the component cache if available
# @param $1     type: the component type (plugin, alias, completion)
# @param $2     component: the component name (search string) to match against
# @return       success status (0) if an item of the component is enabled, fail status (1) otherwise.
# @example      ❯ _gaudi-bash-component-item-is-disabled alias git && echo "git aliases are disabled"
_gaudi-bash-component-item-is-disabled() {
	about "checks if a given item is disabled for a particular component/file-type"
	group "gaudi-bash:core:components"

	__check-function-parameters "$1" || return 1
	if [[ -n "$1" ]] && [[ -n "$2" ]]; then
		_gaudi-bash-component-list-disabled "$1" | tr ' ' '\n' | $(_gaudi-bash-grep) -E -q -- "^${2}$"
	else
		return 1
	fi
}
