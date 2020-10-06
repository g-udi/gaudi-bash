#!/usr/bin/env bash

# Component-specific functions (component is either an alias, a plugin, or a completion).

# @function     _bash-it-pluralize-component
# @description  pluralize component name for consistency especially for search
# @param $1     component: the component type
# @return       plural form of the component type
# @example      ❯ _bash-it-pluralize-component plugin
_bash-it-pluralize-component () {
  about "pluralize component name for consistency especially for search"
  group "bash-it:core"

  local component="${1}"
  local len=$(( ${#component} - 1 ))

  [[ -n $component ]] || return 1

  [[ ${component:${len}:1} != 's' ]] && component="${component}s"
  [[ ${component} == "alias" ]] && component="aliases"

  printf "%s" "${component}"
}

# @function     _bash-it-singularize-component
# @description  singularize component name for consistency especially for search
# @param $1     component: the component type
# @return       singular form of the component type
# @example      ❯ _bash-it-singularize-component plugins
_bash-it-singularize-component () {
  about "singularize component name for consistency especially for search"
  group "bash-it:core"

  local component="${1}"

  # Handle aliases -> alias and plugins -> plugin, etc.
  [[ "$component" == *es ]] && component_singular=${component/es/}
  [[ "$component" == *ns ]] && component_singular=${component/ns/n}

  printf "%s" "${component_singular:-$component}"
}

# @function     _bash-it-component-help
# @description  show the about description for a component
#               if no component is passed then the list of all components of the passed type will be show (proxy for bash-it show <component>)
#               the function caches the first call to speed up search and grep after the first run
# @param $1     type: the component type
# @param $2     component: the component name
# @return       component help
# @example      ❯ _bash-it-component-help plugins git
_bash-it-component-help () {
  local type component file

  [[ -z $1 ]] && return 1

  type=$(_bash-it-pluralize-component "${1}")
  component="$2"
  file=$(_bash-it-component-cache-add "${type}")

  if [[ ! -s "${file}" || -z $(find "${file}" -mmin -300) ]] ; then
    rm -f "${file}" 2>/dev/null
    _bash-it-show "$type" | tail -n +4 | cat > "${file}"
  fi
  # If there is a component passed then grep the type list
  [[ -n $component ]] && grep "$component" "${file}" && return
  cat "${file}"
}

# Returns an array of items within each component
_bash-it-component-list () {
  local component="$1"

  _bash-it-component-help "${component}" | awk '{print $1}' | uniq | sort | tr '\n' ' '
}

# Returns an array of items matching a string within each component
_bash-it-component-list-matching () {
  local component="$1"; shift
  local term="$1"

  _bash-it-component-help "${component}" | $(_bash-it-grep) -E -- "${term}" | awk '{print $1}' | sort | uniq
}

# Returns an array of enabled items within each component
_bash-it-component-list-enabled () {
  local component="$1"

  _bash-it-component-help "${component}" | $(_bash-it-grep) -E '◉' | awk '{print $1}' | uniq | sort | tr '\n' ' '
}

# Returns an array of disabled items within each component
_bash-it-component-list-disabled () {
  local component="$1"

  _bash-it-component-help "${component}" | $(_bash-it-grep) -E  '◯' | awk '{print $1}' | uniq | sort | tr '\n' ' '
}

# Checks if a given item is enabled for a particular component/file-type.
# Uses the component cache if available.
#
# Returns:
#    0 if an item of the component is enabled, 1 otherwise.
#
# Examples:
#    _bash-it-component-item-is-enabled alias git && echo "git alias is enabled"
_bash-it-component-item-is-enabled () {
  local component="$1"
  local item="$2"

  _bash-it-component-list-enabled "$component" | tr ' ' '\n' |  $(_bash-it-grep) -E -q -- "^${item}$"
}

# Checks if a given item is disabled for a particular component/file-type.
# Uses the component cache if available.
#
# Returns:
#    0 if an item of the component is enabled, 1 otherwise.
#
# Examples:
#    _bash-it-component-item-is-disabled alias git && echo "git aliases are disabled"
_bash-it-component-item-is-disabled () {
  local component="$1"
  local item="$2"

  _bash-it-component-list-disabled "$component" | tr ' ' '\n' |  $(_bash-it-grep) -E -q -- "^${item}$"
}
