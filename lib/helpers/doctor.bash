#!/usr/bin/env bash
# shellcheck disable=SC2034

# @function     _bash-it-doctor
# @description  reloads a profile file with a BASH_IT_LOG_LEVEL set
# @param $1     log level: log level to show of warning, errors or all (default: all)
# @return       bash-it log messages
_bash-it-doctor () {
  about 'reloads a profile file with a BASH_IT_LOG_LEVEL set'
  group 'bash-it:core'

  local _log_level

  _log_level=${1:-all}
  _log_level="BASH_IT_LOG_LEVEL_${_log_level/s/}"
  _log_level=${_log_level^^}

  export BASH_IT_LOG_LEVEL=${!_log_level}
  _bash-it-reload
  unset BASH_IT_LOG_LEVEL
}
