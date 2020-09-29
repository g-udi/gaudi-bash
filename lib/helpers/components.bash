#!/usr/bin/env bash

# Component-specific functions (component is either an alias, a plugin, or a completion).

# display help text for the component
_bash-it-component-help () {
  local component
  local file

  component=$(_bash-it-pluralize-component "${1}")
  file=$(_bash-it-component-cache-file ${component})

  if [[ ! -s "${file}" || -z $(find "${file}" -mmin -300) ]] ; then
    rm -f "${file}" 2>/dev/null
    local func="_bash-it-${component}"
    ${func} | $(_bash-it-grep) -E '   \[' | cat > ${file}
  fi

  cat "${file}"
}

# caches the component in the /tmp directory
_bash-it-component-cache-file () {
  local component

  component=$(_bash-it-pluralize-component "${1}")
  local file="${BASH_IT}/tmp/cache/${component}"

  [[ -f ${file} ]] || mkdir -p "$(dirname ${file})"

  printf "${file}"
}

# pluralize component name for consistency especially for search
_bash-it-pluralize-component () {
  local component="${1}"
  local len=$(( ${#component} - 1 ))

  [[ ${component:${len}:1} != 's' ]] && component="${component}s"
  [[ ${component} == "alias" ]] && component="aliases"

  printf ${component}
}

# clean the component cache directory in /tmp
_bash-it-clean-component-cache () {
  local component="$1"
  local cache
  local -a BASH_IT_COMPONENTS=(aliases plugins completions)

  if [[ -z ${component} ]] ; then
    for component in "${BASH_IT_COMPONENTS[@]}" ; do
      _bash-it-clean-component-cache "${component}"
    done
  else
    cache="$(_bash-it-component-cache-file ${component})"
    if [[ -f "${cache}" ]] ; then
      rm -f "${cache}"
    fi
  fi
}

# Returns an array of items within each compoenent
_bash-it-component-list () {
  local component="$1"

  _bash-it-component-help "${component}" | awk '{print $1}' | uniq | sort | tr '\n' ' '
}

# Returns an array of items matching a string within each compoenent
_bash-it-component-list-matching () {
  local component="$1"; shift
  local term="$1"

  _bash-it-component-help "${component}" | $(_bash-it-grep) -E -- "${term}" | awk '{print $1}' | sort | uniq
}

# Returns an array of enabled items within each compoenent
_bash-it-component-list-enabled () {
  local component="$1"

  _bash-it-component-help "${component}" | $(_bash-it-grep) -E  '\[x\]' | awk '{print $1}' | uniq | sort | tr '\n' ' '
}

# Returns an array of disabled items within each compoenent
_bash-it-component-list-disabled () {
  local component="$1"

  _bash-it-component-help "${component}" | $(_bash-it-grep) -E -v '\[x\]' | awk '{print $1}' | uniq | sort | tr '\n' ' '
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

  _bash-it-component-help "${component}" | $(_bash-it-grep) -E '\[x\]' |  $(_bash-it-grep) -E -q -- "^${item}\s"
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

  _bash-it-component-help "${component}" | $(_bash-it-grep) -E -v '\[x\]' |  $(_bash-it-grep) -E -q -- "^${item}\s"
}
