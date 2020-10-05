#!/usr/bin/env bash
# shellcheck disable=SC2143,SC2154

# A collection of reusable functions

# @function     _is_function
# @description  check if the passed parameter is a function
#               sets $? to true if parameter is the name of a function
# @return       status code success (0) if the function is found or fails othwerwise
_is_function () {
  about "check if the passed parameter is a function"
  group "bash-it:core"

  [[ -n "$(LANG=C type -t "$1" 2>/dev/null | grep 'function')" ]]
}

# @function     _command_exists
# @description  check if the command passed as the argument exists
# @param $1     command: the command to check
# @param $2     message (optional) for a log message to include when the command not found
# @return       status code success (0) if the function is found or fails othwerwise
# @example      ❯ _command_exists ls && echo exists
_command_exists () {
  about "check if the command passed as the argument exists"
  group "bash-it:core"

  local msg

  msg="${2:-"command $1 does not exist!"}"
  type "$1" &> /dev/null || (echo "$msg" && return 1) ;
}

# @function     _read_input
# @description  reads input from the prompt for a yes/no (one character) input
#               ensure no empty response will be passed by looping the read prompt unitl a valid non empty response is entered
#               will enter a new line as a cosmetic only if there an entry that is not empty
# @param $1     message: the input prompt message to display
# @return       REPLY entered by the user
# @example      ❯ _read_input "would you like to update bash-it?"
_read_input() {
  about "reads input from the prompt for a yes/no (one character) input"
  group "bash-it:core"

  unset REPLY
  while ! [[ $REPLY =~ ^[yY]$ ]] && ! [[ $REPLY =~ ^[nN]$ ]]; do
    read -rp "${1} " -n 1 </dev/tty;
    [[ -n $REPLY ]] && echo ""
  done
}

# @function     _array-contains
# @description  searches an array for an exact match against the term passed as the first argument to the function
#               the function exits as soon as a match is found
# @param $1     item: the item to search for
# @param $2     array <array>: the array to search in
# @return       status code success (0) if the function is found or fails othwerwise
# @example
#   ❯  declare -a fruits=(apple orange pear mandarin)
#
#   ❯  _array-contains apple "${fruits[@]}" && echo 'contains apple'
#   ❯ contains apple
#
#   ❯  if $(_array-contains pear "${fruits[@]}"); then
#       echo "contains pear!"
#     fi
#   ❯ contains pear!
_array-contains () {
  about "searches an array for an exact match against the term passed as the first argument to the function"
  group "bash-it:core"

  local e match="$1"

  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# @function     _clean-string
# @description  cleans a string from whitespaces given a passed cleaning mode
# @param $1     text: the string to clean
# @param $2     mode: the cleaning mode
#                 - all: trim all leading and trailing whitespaces
#                 - leading: trim all leading spaces
#                 - trailing: trim all trailing spaces
#                 - any: trim any whitespace in the string
# @return       status code success (0) if the function is found or fails othwerwise
# @example
#   ❯ _clean-string " test test test " "all"
#   ❯ 'test test test'
#
#   _clean-string " test test test " "leading"
#   ❯  'test test test '
#
#   ❯ _clean-string " test test test " "trailing"
#   ❯ ' test test test'
#
#   ❯ _clean-string " test test test " "any"
#   ❯ 'testtesttest'
_clean-string () {
  about "cleans a string from whitespaces give a passed cleaning mode"
  group "bash-it:core"

  local mode=${2:-"all"}

  if [[ $mode = "all" ]]; then
    echo -e "${1}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//'
  elif [[ $mode = "trailing" ]]; then
    echo -e "${1}" | sed -e 's/[[:space:]]*$//'
  elif [[ $mode = "leading" ]]; then
    echo -e "${1}" | sed -e 's/^[[:space:]]*//'
  elif [[ $mode = "any" ]]; then
    echo -e "${1}" | tr -d '[:space:]'
  fi
}

# @function     _array-dedupe
# @description  creates a concatinated array of unique and sorted elements
# @param $1     origin <array>: the source array
# @param $2     target <array>: the target array
# @return       the unique concatinated array
# @example
#   ❯ declare -a array_a=(apple orange pear mandarin)
#   ❯ declare -a array_b=(apple pear apricot cucumber orange)
#
#   ❯ _array-dedupe "${array_a[@]}" "${array_b[@]}"
#   ❯ apple apricot cucumber mandarin orange pear
_array-dedupe () {
  about "creates a concatinated array of unique and sorted elements"
  group "bash-it:core"

  _clean-string "$(echo "$*" | tr ' ' '\n' | sort -u | tr '\n' ' ')" "all"
}
