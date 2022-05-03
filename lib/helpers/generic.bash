#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2034,SC2154,SC2016

# Prevent duplicate directories in you PATH variable
#
# Example:
# pathmunge /path/to/dir is equivalent to PATH=/path/to/dir:$PATH
# pathmunge /path/to/dir after is equivalent to PATH=$PATH:/path/to/dir
if ! type pathmunge > /dev/null 2>&1; then
	pathmunge() {
		IFS=':' local -a 'a=($1)'
		local i=${#a[@]}
		while [[ $i -gt 0 ]]; do
			i=$((i - 1))
			p=${a[i]}
			if ! [[ $PATH =~ (^|:)$p($|:) ]]; then
				if [[ "$2" = "after" ]]; then
					export PATH=$PATH:$p
				else
					export PATH=$p:$PATH
				fi
			fi
		done
	}
fi

# Handle the different ways of running `sed` without generating a backup file based on OS
# - GNU sed (Linux) uses `-i`
# - BSD sed (macOS) uses `-i ''`
#
# In order to use this in gaudi-bash for inline replacements with `sed`, use the following syntax:
# ❯ sed "${GAUDI_BASH_SED_I_PARAMETERS[@]}" -e "..." file
GAUDI_BASH_SED_I_PARAMETERS=(-i)
case "$(uname)" in
	Darwin*) GAUDI_BASH_SED_I_PARAMETERS=(-i "") ;;
esac

# Adding Support for other OSes
PREVIEW="less"

if [[ -s /usr/bin/gloobus-preview ]]; then
	PREVIEW="gloobus-preview"
elif [[ -s /Applications/Preview.app ]]; then
	PREVIEW="/Applications/Preview.app"
fi
