#!/usr/bin/env bash
# shellcheck disable=SC2034,SC2143,SC2154

# A collection of reusable functions

# Check if the passed parameter is a function
# Sets $? to true if parameter is the name of a function
_is_function () {
  [[ -n "$(LANG=C type -t "$1" 2>/dev/null | grep 'function')" ]]
}

# Check if the command passed as the argument exists
# A second param can be passed (optional) for a log message to include when command not found
#
# Example:
# _command_exists ls && echo exists
#
_command_exists () {
  local msg="${2:-Command "$1" does not exist!}"

  type "$1" &> /dev/null || (_log_warning "$msg" && return 1) ;
}

# Reads input from the prompt and ensure no empty value
# It will enter a new line as a cosmetic only if there an entry that is not empty
_read_input() {
  unset REPLY
  while ! [[ $REPLY =~ ^[yY]$ ]] && ! [[ $REPLY =~ ^[nN]$ ]]; do
    read -rp "${1} " -n 1 </dev/tty;
    [[ -n $REPLY ]] && echo ""
  done
}

# Handle the different ways of running `sed` without generating a backup file based on OS
# - GNU sed (Linux) uses `-i`
# - BSD sed (macOS) uses `-i ''`
#
# To use this in bash-it for inline replacements with `sed`, use the following syntax:
# sed "${BASH_IT_SED_IparamETERS[@]}" -e "..." file
#
BASH_IT_SED_IparamETERS=(-i)
case "$(uname)" in
  Darwin*) BASH_IT_SED_IparamETERS=(-i "")
esac

# Adding Support for other OSes
PREVIEW="less"

if [[ -s /usr/bin/gloobus-preview ]]; then
  PREVIEW="gloobus-preview"
elif [[ -s /Applications/Preview.app ]]; then
  PREVIEW="/Applications/Preview.app"
fi

# This function searches an array for an exact match against the term passed as the first argument to the function.
# This function exits as soon as a match is found.
#
# Returns:
#   0 when a match is found, otherwise 1.
#
# Examples:
#   $ declare -a fruits=(apple orange pear mandarin)
#
#   $ array-contains apple "${fruits[@]}" && echo 'contains apple'
#   contains apple
#
#   $ if $(array-contains pear "${fruits[@]}"); then
#       echo "contains pear!"
#     fi
#   contains pear!
#
array-contains () {
  local e match="$1"

  shift
  for e; do [[ "$e" == "$match" ]] && return 0; done
  return 1
}

# Clean a string from whitespaces give a passed cleaning mode
#   all: trim all leading and trailing whitespaces
#   leading: trim all leading spaces
#   trailing: trim all trailing spaces
#   any: trim any whitespace in the string
#
# Examples:
#
# FOO=' test test test '
# clean-string $FOO "all" -> 'test test test'
# clean-string $FOO "leading" -> 'test test test '
# clean-string $FOO "trailing" -> ' test test test'
# clean-string $FOO "any" -> 'testtesttest'
#
clean-string () {
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

# Creates a concatinated array of unique and sorted elements
#
# Example:
# declare -a array_a=(apple orange pear mandarin)
# declare -a array_b=(apple pear apricot cucumber orange)
#
# array-dedupe "${array_a[@]}" "${array_b[@]}" -> "apple apricot cucumber mandarin orange pear"
#
array-dedupe () {
  clean-string "$(echo "$*" | tr ' ' '\n' | sort -u | tr '\n' ' ')" "all"
}

# Prevent duplicate directories in you PATH variable
#
# Example:
#
# pathmunge /path/to/dir is equivalent to PATH=/path/to/dir:$PATH
# pathmunge /path/to/dir after is equivalent to PATH=$PATH:/path/to/dir
#
if ! type pathmunge > /dev/null 2>&1
then
  pathmunge () {
    IFS=':' local -a 'a=($1)'
    local i=${#a[@]}
    while [[ $i -gt 0 ]] ; do
      i=$(( i - 1 ))
      p=${a[i]}
      if ! [[ $PATH =~ (^|:)$p($|:) ]] ; then
        if [[ "$2" = "after" ]] ; then
          export PATH=$PATH:$p
        else
          export PATH=$p:$PATH
        fi
      fi
    done
  }
fi
