#!/usr/bin/env bash
# shellcheck shell=bash

# @function     _gaudi-bash-doctor
# @description  reloads a profile file with a GAUDI_BASH_LOG_LEVEL set
#               the level is only set for the reload, a GAUDI_BASH_LOG_LEVEL of your own is left as it was
# @param $1     log level: log level to show of errors, warnings or all (default: all)
# @return       gaudi-bash log messages, fail status (1) for an unknown log level
_gaudi-bash-doctor() {
	about 'reloads a profile file with a GAUDI_BASH_LOG_LEVEL set'
	group 'gaudi-bash:core'

	local _log_level

	case "${1:-all}" in
		error | errors)
			_log_level="GAUDI_BASH_LOG_LEVEL_ERROR"
			;;
		warning | warnings)
			_log_level="GAUDI_BASH_LOG_LEVEL_WARNING"
			;;
		all)
			_log_level="GAUDI_BASH_LOG_LEVEL_ALL"
			;;
		*)
			printf "${RED:-}%s${NC:-}\n" "Unknown log level: $1"
			printf "%s\n" "Usage: gbash doctor [errors|warnings|all]"
			return 1
			;;
	esac

	# Being local, the level set here is gone when the function returns: a GAUDI_BASH_LOG_LEVEL that was
	# set before (e.g., in the profile) is neither changed nor unset by running the doctor
	local -x GAUDI_BASH_LOG_LEVEL="${!_log_level}"
	_gaudi-bash-reload
}
