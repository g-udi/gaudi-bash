#!/usr/bin/env bash

export BASH_IT_LOG_LEVEL_ERROR=1
export BASH_IT_LOG_LEVEL_WARNING=2
export BASH_IT_LOG_LEVEL_ALL=3

_bash-it-get-component-name-from-path() {
  # filename without path
  filename=${1##*/}
  # filename without path or priority
  filename=${filename##*---}
  # filename without path, priority or extension
  echo ${filename%.*.bash}
}

_bash-it-get-component-type-from-path() {
  # filename without path
  filename=${1##*/}
  # filename without path or priority
  filename=${filename##*---}
  # extension
  echo ${filename} | cut -d '.' -f 2
}

_log_general() {
  about 'Internal function used for logging, uses BASH_IT_LOG_PREFIX as a prefix'
  param '1: color of the log level'
  param '2: log type to print before the prefix'
  param '3: message to log'
  group 'log'

  # if no BASH_IT_LOG_PREFIX is defined fallback to [CORE]
  BASH_IT_LOG_PREFIX=${BASH_IT_LOG_PREFIX:-"[CORE]"}

  echo -e "$1$2${YELLOW}${BASH_IT_LOG_PREFIX}${NC} $3"
}

_log_debug() {
  about 'log a debug message by echoing to the screen. needs BASH_IT_LOG_LEVEL >= BASH_IT_LOG_LEVEL_ALL'
  param '1: message to log'
  example '$ _log_debug "Loading plugin git..."'
  group 'log'

  [[ "$BASH_IT_LOG_LEVEL" -ge $BASH_IT_LOG_LEVEL_ALL ]] || return 0
  _log_general "${GREEN}" " [DEBUG] " "$1"
}

_log_warning() {
  about 'log a message by echoing to the screen. needs BASH_IT_LOG_LEVEL >= BASH_IT_LOG_LEVEL_WARNING'
  param '1: message to log'
  example '$ _log_warning "git binary not found, disabling git plugin..."'
  group 'log'

  [[ "$BASH_IT_LOG_LEVEL" -ge $BASH_IT_LOG_LEVEL_WARNING ]] || return 0
  _log_general "${YELLOW}" " [WARN] " "$1"
}

_log_error() {
  about 'log a message by echoing to the screen. needs BASH_IT_LOG_LEVEL >= BASH_IT_LOG_LEVEL_ERROR'
  param '1: message to log'
  example '$ _log_error "Failed to load git plugin..."'
  group 'log'

  [[ "$BASH_IT_LOG_LEVEL" -ge $BASH_IT_LOG_LEVEL_ERROR ]] || return 0
  _log_general "${RED}" " [ERROR] " "$1"
}

_log_component() {
  about 'log a component loading message by echoing to the screen the name and type'
  param '1: message to log'
  example '$ _log_component "Failed to load git plugin..."'
  group 'log'

  filename=$(_bash-it-get-component-name-from-path "$1")
  extension=$(_bash-it-get-component-type-from-path "$1")

  [[ "$BASH_IT_LOG_LEVEL" -ge $BASH_IT_LOG_LEVEL_ERROR ]] || return 0
  _log_general "${GREEN}" " [DEBUG] " "Loading component ${MAGENTA}[${extension/es/}]${NC} ${BLUE}$filename${NC}"

}
