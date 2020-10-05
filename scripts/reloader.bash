#!/bin/bash
# shellcheck disable=SC1090,SC2034

BASH_IT_LOG_PREFIX="LOADER"
pushd "${BASH_IT}" >/dev/null || exit 1
if [[ "$1" != "skip" ]] && [[ -d "./enabled" ]]; then
  _bash_it_config_type=""
  if [[ "${1}" =~ ^(alias|completion|plugin)$ ]]; then
    _bash_it_config_type="$1"
    _log_debug "Loading enabled $1 components..."
  else
    _log_debug "Loading all enabled components..."
  fi
  for _bash_it_config_file in $(sort <(compgen -G "./enabled/*${_bash_it_config_type}.bash")); do
    if [[ -e "${_bash_it_config_file}" ]]; then
      _log_component "$_bash_it_config_file"
      source "$_bash_it_config_file"
    fi
  done
fi

unset _bash_it_config_file
unset _bash_it_config_type
unset BASH_IT_LOG_PREFIX

popd >/dev/null || exit 1
