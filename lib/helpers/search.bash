#!/usr/bin/env bash
# shellcheck shell=bash

# @function     _gaudi-bash-rewind
# @description  rewinds (deletes) the output in the terminal by N characters
# @param $1     length: the length of characters to rewind
# @return       returns the stripped text
# @example      ❯ _gaudi-bash-rewind 2
_gaudi-bash-rewind() {
	local -i length="$1"
	printf '%b' "\033[${length}D"
}

# @function     _gaudi-bash-erase-term
# @description  gets the component cache path in the /tmp directory
#               will create a cache folder if doesn't exist in /tmp
# @param $1     type: the component type
# @return       returns the cache file path
# @example      ❯ _gaudi-bash-component-cache-add plugin
_gaudi-bash-erase-term() {
	local -i length="${1:-0}"
	_gaudi-bash-rewind "${length}"
	for a in {0..30}; do
		[[ ${a} -gt ${length} ]] && break
		printf "%.*s" "$a" " "
		sleep 0.05
	done
}
