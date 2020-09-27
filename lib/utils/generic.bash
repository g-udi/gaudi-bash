#!/usr/bin/env bash

# A collection of reusable functions

_is_function () {
    _about 'sets $? to true if parameter is the name of a function'
    _param '1: name of alleged function'
    _group 'lib'
    [ -n "$(LANG=C type -t $1 2>/dev/null | grep 'function')" ]
}

_command_exists () {
  _about 'checks for existence of a command'
  _param '1: command to check'
  _param '2: (optional) log message to include when command not found'
  _example '$ _command_exists ls && echo exists'
  _group 'lib'
  local msg="${2:-Command '$1' does not exist!}"
  type "$1" &> /dev/null || (_log_warning "$msg" && return 1) ;
}
