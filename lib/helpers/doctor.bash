#!/usr/bin/env bash
# shellcheck disable=SC2034

_bash-it-doctor () {
  about 'reloads a profile file with a BASH_IT_LOG_LEVEL set'
  param '1: BASH_IT_LOG_LEVEL argument: "errors" "warnings" "all"'
  group 'lib'

  BASH_IT_LOG_LEVEL=$1
  _bash-it-reload
  unset BASH_IT_LOG_LEVEL
}

_bash-it-doctor-all () {
  about 'reloads a profile file with error, warning and debug logs'
  group 'lib'

  _bash-it-doctor $BASH_IT_LOG_LEVEL_ALL
}

_bash-it-doctor-warnings () {
  about 'reloads a profile file with error and warning logs'
  group 'lib'

  _bash-it-doctor $BASH_IT_LOG_LEVEL_WARNING
}

_bash-it-doctor-errors () {
  about 'reloads a profile file with error logs'
  group 'lib'

  _bash-it-doctor $BASH_IT_LOG_LEVEL_ERROR
}

_bash-it-doctor- () {
  about 'default bash-it doctor behavior, behaves like bash-it doctor all'
  group 'lib'

  _bash-it-doctor-all
}
