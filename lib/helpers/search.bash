#!/usr/bin/env bash

# @function     _bash-it-rewind
# @description  rewinds (deletes) the output in the terminal by N characters
# @param $1     length: the length of characters to rewind
# @return       returns the stripped text
# @example      ❯ _bash-it-rewind 2
_bash-it-rewind () {
  local length="$1"
  printf "\033[${length}D"
}

# @function     _bash-it-erase-term
# @description  gets the component cache path in the /tmp directory
#               will create a cache folder if doesn't exist in /tmp
# @param $1     type: the component type
# @return       returns the cache file path
# @example      ❯ _bash-it-component-cache-add plugin
_bash-it-erase-term () {
  local length="$1"
  _bash-it-rewind ${length}
  for a in {0..30}; do
    [[ ${a} -gt ${length} ]] && break
    printf "%.*s" "$a" " "
    sleep 0.05
  done
}
