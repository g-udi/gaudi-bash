#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2034

# @function     _gaudi-bash-doctor
# @description  reloads a profile file with a GAUDI_BASH_LOG_LEVEL set
# @param $1     log level: log level to show of warning, errors or all (default: all)
# @return       gaudi-bash log messages
_gaudi-bash-doctor() {
	about 'reloads a profile file with a GAUDI_BASH_LOG_LEVEL set'
	group 'gaudi-bash:core'

	local _log_level

	_log_level=${1:-all}
	_log_level="GAUDI_BASH_LOG_LEVEL_${_log_level/s/}"
	_log_level=${_log_level^^}

	export GAUDI_BASH_LOG_LEVEL=${!_log_level}
	_gaudi-bash-reload
	unset GAUDI_BASH_LOG_LEVEL
}
