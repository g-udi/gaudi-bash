#!/usr/bin/env bash
# shellcheck shell=bash

# @function     hr
# @description  outputs the history of commands used sorted by usage and count
hr() {
	history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head
}

# The history settings below are gaudi-bash's defaults: set GAUDI_BASH_HISTORY=false before gaudi-bash is loaded
# to keep Bash's own. A setting you made yourself (before gaudi-bash is loaded) is never replaced: only the
# values Bash starts with are (HISTSIZE and HISTFILESIZE 500, HISTFILE ~/.bash_history)
[[ "${GAUDI_BASH_HISTORY:-true}" == "false" ]] && return 0

shopt -s histappend

# Modify history sizes before changing location to avoid unintentionally
# truncating the history file early.

# "Numeric values less than zero result in every command being saved on the history list (there is no limit)"
if [[ -z "${HISTSIZE:-}" || "$HISTSIZE" == 500 ]]; then
	HISTSIZE=-1
fi

# "Non-numeric values and numeric values less than zero inhibit truncation"
if [[ -z "${HISTFILESIZE:-}" || "$HISTFILESIZE" == 500 ]]; then
	HISTFILESIZE='unlimited'
fi

# Use a custom history file location so history is not truncated
# if the environment ever loses this "eternal" configuration.
if [[ -z "${HISTFILE:-}" || "$HISTFILE" == "${HOME?}/.bash_history" ]]; then
	HISTDIR="${XDG_STATE_HOME:-${HOME?}/.local/state}/bash"
	[[ -d ${HISTDIR?} ]] || mkdir -p "${HISTDIR?}"
	HISTFILE="${HISTDIR?}/history"
fi
