#!/usr/bin/env bash

export BASH_IT_COMPONENT_TYPES=(plugins aliases completions)

# Component-specific functions (component is either an alias, a plugin, or a completion).

# @function     __check-function-parameters
# @description  check the passed parameter to make sure its valid and matches a component type
# @param $1     component: the component type (plugin, alias, completion)
# @return       success (0) or failure status (1)
# @example      ❯ __check-function-parameters plugin
__check-function-parameters () {
  about "check the passed parameter to make sure its valid and matches a component type"
  group "bash-it:core"

  [[ -z "$1" ]] && return 1
  _array-contains $(_bash-it-pluralize-component "${1}") "${BASH_IT_COMPONENT_TYPES[@]}" || return 1
  return 0
}

# @function     _bash-it-pluralize-component
# @description  pluralize component name for consistency especially for search
# @param $1     component: the component type (plugin, alias, completion)
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
# @param $1     component: the component type (plugin, alias, completion)
# @return       singular form of the component type
# @example      ❯ _bash-it-singularize-component plugins
_bash-it-singularize-component () {
  about "singularize component name for consistency especially for search"
  group "bash-it:core"

  __check-function-parameters "$1" || return 1

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
# @param $1     type: the component type (plugin, alias, completion)
# @param $2     component: the component name
# @return       component help
# @example      ❯ _bash-it-component-help plugins git
_bash-it-component-help () {
  about "show the about description for a component"
  group "bash-it:core"

  local type component file

  __check-function-parameters "$1" || return 1

  type=$(_bash-it-pluralize-component "${1}")
  component="$2"
  help=$(_bash-it-show "$type" | tail -n +4)

  # If there is a component passed then grep the type list
  if [[ -n $component ]]; then
    printf "$help" | grep "${component}" && return 0
    return 1
  fi
  printf "${help}"
}

# @function     _bash-it-component-list
# @description  returns a list of items within each component (plugin, alias, completion)
# @param $1     type: the component type (plugin, alias, completion)
# @return       <array> list of components
# @example      ❯ _bash-it-component-list plugins
_bash-it-component-list () {
  about "returns a list of items within each component (plugin, alias, completion)"
  group "bash-it:core"

  __check-function-parameters "$1" || return 1
  _bash-it-component-help "$1" | awk '{print $1}' | uniq | sort | tr '\n' ' '
}

# @function     _bash-it-component-list
# @description  returns a list of items within each component (plugin, alias, completion) that match a string
# @param $1     type: the component type (plugin, alias, completion)
# @param $2     component: the component name (search string) to match against
# @return       <array> list of matched components
# @example      ❯ _bash-it-component-list-matching plugins git
_bash-it-component-list-matching () {
  about "returns a list of items within each component (plugin, alias, completion) that match a string "
  group "bash-it:core"

  __check-function-parameters "$1" || return 1
  if [[ -n "$1" ]] && [[ -n "$2" ]]; then
    local match
    match=$(_bash-it-component-help "$1" | $(_bash-it-grep) -E -- "$2" | awk '{print $1}' | uniq | sort | tr '\n' ' ')
    [[ -n "$match" ]] && echo "$match" && return 0
  fi
  return 1
}

# @function     _bash-it-component-list-enabled
# @description  returns a list of enabled items within each component (plugin, alias, completion)
# @param $1     type: the component type (plugin, alias, completion)
# @return       <array> list of enabled components
# @example      ❯ _bash-it-component-list-enabled plugins
_bash-it-component-list-enabled () {
  about "returns a list of enabled items within each component (plugin, alias, completion)"
  group "bash-it:core"

  __check-function-parameters "$1" || return 1
  _bash-it-component-help "${1}" | $(_bash-it-grep) -E '◉' | awk '{print $1}' | uniq | sort | tr '\n' ' '
}

# @function     _bash-it-component-list-disabled
# @description  returns a list of disabled items within each component (plugin, alias, completion)
# @param $1     type: the component type (plugin, alias, completion)
# @return       <array> list of disabled components
# @example      ❯ _bash-it-component-list-disabled plugins
_bash-it-component-list-disabled () {
  about "returns a list of disabled items within each component (plugin, alias, completion)"
  group "bash-it:core"

  __check-function-parameters "$1" || return 1
  _bash-it-component-help "${1}" | $(_bash-it-grep) -E  '◯' | awk '{print $1}' | uniq | sort | tr '\n' ' '
}

# @function     _bash-it-component-item-is-enabled
# @description  checks if a given item is enabled for a particular component/file-type
#               Uses the component cache if available
# @param $1     type: the component type (plugin, alias, completion)
# @param $2     component: the component name (search string) to match against
# @return       success status (0) if an item of the component is enabled, fail status (1) otherwise.
# @example      ❯ _bash-it-component-item-is-enabled alias git && echo "git alias is enabled"
_bash-it-component-item-is-enabled () {
  about "checks if a given item is enabled for a particular component/file-type"
  group "bash-it:core"

  __check-function-parameters "$1" || return 1
  if [[ -n "$1" ]] && [[ -n "$2" ]]; then
    _bash-it-component-list-enabled "$1" | tr ' ' '\n' |  $(_bash-it-grep) -E -q -- "^${2}$"
  else
    return 1
  fi
}

# @function     _bash-it-component-item-is-disabled
# @description  checks if a given item is disabled for a particular component/file-type
#               Uses the component cache if available
# @param $1     type: the component type (plugin, alias, completion)
# @param $2     component: the component name (search string) to match against
# @return       success status (0) if an item of the component is enabled, fail status (1) otherwise.
# @example      ❯ _bash-it-component-item-is-disabled alias git && echo "git aliases are disabled"
_bash-it-component-item-is-disabled () {
  about "checks if a given item is disabled for a particular component/file-type"
  group "bash-it:core"

  __check-function-parameters "$1" || return 1
  if [[ -n "$1" ]] && [[ -n "$2" ]]; then
    _bash-it-component-list-disabled "$1" | tr ' ' '\n' |  $(_bash-it-grep) -E -q -- "^${2}$"
  else
    return 1
  fi
}
