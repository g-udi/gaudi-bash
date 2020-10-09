#!/bin/bash
# shellcheck disable=SC1090,SC2034

BASH_IT_LOG_PREFIX="LOADER"

pushd "${BASH_IT}" >/dev/null || exit 1
if [[ -d "./components/enabled" ]]; then
  _bash_it_config_type=""
  _log_debug "Loading all enabled components..."
  for _bash_it_config_file in $(sort <(compgen -G "./components/enabled/*${_bash_it_config_type}.bash")); do
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
