#!/bin/bash
# shellcheck shell=bash
# shellcheck disable=SC1090,SC2034,SC2013

GAUDI_BASH_LOG_PREFIX="LOADER"

pushd "${GAUDI_BASH}" > /dev/null || exit 1
if [[ -d "./components/enabled" ]]; then
	_gaudi_bash_config_type=""
	_log_debug "Loading all enabled components..."
	for _gaudi_bash_config_file in $(sort <(compgen -G "./components/enabled/*${_gaudi_bash_config_type}.bash")); do
		if [[ -e "${_gaudi_bash_config_file}" ]]; then
			_log_component "$_gaudi_bash_config_file"
			source "$_gaudi_bash_config_file"
		fi
	done
fi

unset _gaudi_bash_config_file
unset _gaudi_bash_config_type
unset GAUDI_BASH_LOG_PREFIX

popd > /dev/null || exit 1
