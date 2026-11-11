#!/usr/bin/env bash
# shellcheck shell=bash

# Cache directory: $XDG_CACHE_HOME/gaudi-bash when XDG_CACHE_HOME is set, ~/.cache/gaudi-bash otherwise
GAUDI_BASH_CACHE_DIR="${XDG_CACHE_HOME:-${HOME}/.cache}/gaudi-bash"

# @function     _gaudi-bash-component-cache-add
# @description  gets the component cache path
#               will create a cache folder if it doesn't exist
# @param $1     type: the component type
# @return       returns the cache file path
# @example      ❯ _gaudi-bash-component-cache-add plugin
_gaudi-bash-component-cache-add() {
	about "gets the component cache path"
	group "gaudi-bash:core:cache"

	[[ -z $1 ]] && return 1

	local file
	file="${GAUDI_BASH_CACHE_DIR}/${1}"
	[[ -f ${file} ]] || mkdir -p "${file%/*}"
	printf "%s" "${file}"
}

# @function     _gaudi-bash-component-cache-clean
# @description  clears the cached descriptions of a passed component type from the cache directory
#               clears all the caches if no component type was passed
#               the "<type>" and "<type>-enabled" files are the table caches written by older versions
# @param $1     type: the component type
# @example      ❯ _gaudi-bash-component-cache-clean
_gaudi-bash-component-cache-clean() {
	about "clears the cached component descriptions"
	group "gaudi-bash:core:cache"

	local component="$1"
	local cache
	local -a GAUDI_BASH_COMPONENTS=(aliases plugins completions)

	if [[ -z ${component} ]]; then
		for component in "${GAUDI_BASH_COMPONENTS[@]}"; do
			_gaudi-bash-component-cache-clean "${component}"
		done
	else
		cache=$(_gaudi-bash-component-cache-add "${component}")
		rm -f "${cache}" "${cache}-enabled" "${cache}-descriptions"
	fi
}
