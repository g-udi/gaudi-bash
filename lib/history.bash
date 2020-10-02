#!/usr/bin/env bash

# Bash History Handling

shopt -s histappend                                      # Append to bash_history if Terminal.app quits
export HISTCONTROL=${HISTCONTROL:-ignorespace:erasedups} # Erase duplicates; alternative option: export HISTCONTROL=ignoredups
export HISTSIZE=${HISTSIZE:-5000}                        # Resize history size
export AUTOFEATURE=${AUTOFEATURE:-true autotest}         # Cucumber / Autotest integration

rh () {
  history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
}
