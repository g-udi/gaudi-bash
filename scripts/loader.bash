#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC1090,SC2034

GAUDI_BASH_LOG_PREFIX="LOADER"

if [[ -d "$GAUDI_BASH/components/enabled" ]]; then
	_log_debug "Loading all enabled components..."
	for _gaudi_bash_config_file in "${GAUDI_BASH}"/components/enabled/*.bash; do
		if [[ -e "${_gaudi_bash_config_file}" ]]; then
			_log_component "$_gaudi_bash_config_file"
			source "$_gaudi_bash_config_file"
		elif [[ -L "${_gaudi_bash_config_file}" ]] \
			&& [[ $- == *i* || "${GAUDI_BASH_LOG_LEVEL:-0}" -ge "${GAUDI_BASH_LOG_LEVEL_WARNING:-2}" ]]; then
			# The link points to a file that is gone (e.g., the installation was moved): say so instead of
			# skipping it silently (interactive shells and `gbash doctor` runs only, scripts stay quiet)
			printf '%s\n' "gaudi-bash: enabled component '${_gaudi_bash_config_file##*/}' points to a missing file, skipped. Fix: gbash migrate" >&2
		fi
	done
fi

unset _gaudi_bash_config_file
unset GAUDI_BASH_LOG_PREFIX
