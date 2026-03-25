#!/bin/bash
# shellcheck shell=bash
# shellcheck disable=SC1090,SC2034

GAUDI_BASH_LOG_PREFIX="LOADER"

if [[ -d "$GAUDI_BASH/components/enabled" ]]; then
	_log_debug "Loading all enabled components..."
	for _gaudi_bash_config_file in "${GAUDI_BASH}"/components/enabled/*.bash; do
		if [[ -e "${_gaudi_bash_config_file}" ]]; then
			_log_component "$_gaudi_bash_config_file"
			source "$_gaudi_bash_config_file"
		fi
	done
fi

unset _gaudi_bash_config_file
unset GAUDI_BASH_LOG_PREFIX
