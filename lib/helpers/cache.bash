#!/usr/bin/env bash

# @function     _bash-it-component-cache-add
# @description  caches the component view in the /tmp directory
# @param $1     type: the component type
# @return       cache file
# @example      ❯ _bash-it-component-cache-add plugin
_bash-it-component-cache-add () {
  about "caches the component view in the /tmp directory"
  group "bash-it:core"

  local component file

  component=$(_bash-it-pluralize-component "${1}")
  file="${BASH_IT}/tmp/cache/${component}"

  [[ -f ${file} ]] || mkdir -p "$(dirname "${file}")"

  printf "%s" "${file}"
}

# @function     _bash-it-component-cache-clean
# @description  clears the cache view in the /tmp directory for a passed component type
#               clears all the caches if no component type was passed
# @param $1     type: the component type
# @example      ❯ _bash-it-component-cache-clean
_bash-it-component-cache-clean () {
  about "caches the component view in the /tmp directory"
  group "bash-it:core"

  local component="$1"
  local cache
  local -a BASH_IT_COMPONENTS=(aliases plugins completions)

  if [[ -z ${component} ]] ; then
    for component in "${BASH_IT_COMPONENTS[@]}" ; do
      _bash-it-component-cache-clean "${component}"
    done
  else
    cache=$(_bash-it-component-cache-add "${component}")
    if [[ -f "${cache}" ]] ; then
      rm -f "${cache}"
    fi
  fi
}
