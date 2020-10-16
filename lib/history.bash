#!/usr/bin/env bash

# shopt -s histappend                                      # append to bash_history if Terminal.app quits
# export HISTCONTROL=${HISTCONTROL:-ignorespace:erasedups} # erase duplicates; alternative option: export HISTCONTROL=ignoredups
# export HISTSIZE=${HISTSIZE:-5000}                        # resize history size
# export AUTOFEATURE=${AUTOFEATURE:-true autotest}         # cucumber / Autotest integration

# # @function     hr
# # @description  outputs the history of commands used sorted by usage and count
# hr () {
#   history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
# }
