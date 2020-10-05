#!/usr/bin/env bash

# Caches the component in the /tmp directory
_bash-it-component-cache-file () {
  local component file

  component=$(_bash-it-pluralize-component "${1}")
  file="${BASH_IT}/tmp/cache/${component}"

  [[ -f ${file} ]] || mkdir -p "$(dirname "${file}")"

  printf "%s" "${file}"
}

# Clean the component cache directory in /tmp
_bash-it-clean-component-cache () {
  local component="$1"
  local cache
  local -a BASH_IT_COMPONENTS=(aliases plugins completions)

  if [[ -z ${component} ]] ; then
    for component in "${BASH_IT_COMPONENTS[@]}" ; do
      _bash-it-clean-component-cache "${component}"
    done
  else
    cache=$(_bash-it-component-cache-file "${component}")
    if [[ -f "${cache}" ]] ; then
      rm -f "${cache}"
    fi
  fi
}
