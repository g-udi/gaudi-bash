#!/usr/bin/env bash
# shellcheck shell=bash

# @function     _gaudi-bash-component-cache-add
# @description  gets the component cache path in the /tmp directory
#               will create a cache folder if doesn't exist in /tmp
# @param $1     type: the component type
# @return       returns the cache file path
# @example      ❯ _gaudi-bash-component-cache-add plugin
_gaudi-bash-component-cache-add() {
	about "gets the component cache path in the /tmp directory"
	group "gaudi-bash:core:cache"

	[[ -z $1 ]] && return 1

	local file
	echo "GAUDI_BASH::::> $GAUDI_BASH"
	file="${GAUDI_BASH}/tmp/cache/${1}"
	echo "file::::> $file"
	[[ -f ${file} ]] || mkdir -p "${file%/*}"
	echo "!!! $file"
	printf "%s" "${file}"
	echo ">>>> $(ls -la ${GAUDI_BASH}/tmp/cache/)"
}

# @function     _gaudi-bash-component-cache-clean
# @description  clears the cache view in the /tmp directory for a passed component type
#               clears all the caches if no component type was passed
# @param $1     type: the component type
# @example      ❯ _gaudi-bash-component-cache-clean
_gaudi-bash-component-cache-clean() {
	about "caches the component view in the /tmp directory"
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
		if [[ -f "${cache}" ]]; then
			rm -f "${cache}" && rm -f "${cache}-enabled"
		fi
	fi
}
