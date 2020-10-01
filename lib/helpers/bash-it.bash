#!/usr/bin/env bash

# A collection of reusable bash-it functions

# Outputs a full path of the grep found on the filesystem
_bash-it-grep () {
  if [[ -z "${BASH_IT_GREP}" ]] ; then
    BASH_IT_GREP="$(which egrep || which grep || '/usr/bin/grep')"
    export BASH_IT_GREP
  fi
  printf "%s " "${BASH_IT_GREP}"
}
