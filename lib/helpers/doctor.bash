#!/usr/bin/env bash
# shellcheck disable=SC2034

_bash-it-doctor () {
  _about 'reloads a profile file with a BASH_IT_LOG_LEVEL set'
  _param '1: BASH_IT_LOG_LEVEL argument: "errors" "warnings" "all"'
  _group 'lib'

  BASH_IT_LOG_LEVEL=$1
  _bash-it-reload
  unset BASH_IT_LOG_LEVEL
}

_bash-it-doctor-all () {
  _about 'reloads a profile file with error, warning and debug logs'
  _group 'lib'

  _bash-it-doctor $BASH_IT_LOG_LEVEL_ALL
}

_bash-it-doctor-warnings () {
  _about 'reloads a profile file with error and warning logs'
  _group 'lib'

  _bash-it-doctor $BASH_IT_LOG_LEVEL_WARNING
}

_bash-it-doctor-errors () {
  _about 'reloads a profile file with error logs'
  _group 'lib'

  _bash-it-doctor $BASH_IT_LOG_LEVEL_ERROR
}

_bash-it-doctor- () {
  _about 'default bash-it doctor behavior, behaves like bash-it doctor all'
  _group 'lib'

  _bash-it-doctor-all
}
