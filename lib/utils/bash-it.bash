#!/usr/bin/env bash

# A collection of reusable bash-it functions

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

# This function searches an array for an exact match against the term passed
# as the first argument to the function. This function exits as soon as
# a match is found.
#
# Returns:
#   0 when a match is found, otherwise 1.
#
# Examples:
#   $ declare -a fruits=(apple orange pear mandarin)
#
#   $ _bash-it-array-contains-element apple "@{fruits[@]}" && echo 'contains apple'
#   contains apple
#
#   $ if $(_bash-it-array-contains-element pear "${fruits[@]}"); then
#       echo "contains pear!"
#     fi
#   contains pear!
#
#
_bash-it-array-contains-element() {
  local e

  for e in "${@:2}"; do
    [[ "$e" == "$1" ]] && return 0
  done
  return 1
}

# Dedupe a simple array of words without spaces.
_bash-it-array-dedup() {
  echo "$*" | tr ' ' '\n' | sort -u | tr '\n' ' '
}

# Outputs a full path of the grep found on the filesystem
_bash-it-grep() {
  if [[ -z "${BASH_IT_GREP}" ]] ; then
    export BASH_IT_GREP="$(which egrep || which grep || '/usr/bin/grep')"
  fi
  printf "%s " "${BASH_IT_GREP}"
}
