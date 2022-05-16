#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC1090,SC1091,SC2034

# Initialize Bash It
GAUDI_BASH_LOG_PREFIX="CORE"
: "${GAUDI_BASH:=${BASH_SOURCE%/*}}"
: "${GAUDI_BASH_BASHRC:=${BASH_SOURCE[${#BASH_SOURCE[@]} - 1]}}"

case $OSTYPE in
	darwin*)
		export GAUDI_BASH_PROFILE=".bash_profile"
		;;
	*)
		export GAUDI_BASH_PROFILE=".bashrc"
		;;
esac

# Only set $GAUDI_BASH if it's not already set
if [[ -z "$GAUDI_BASH" ]]; then
	# Setting $BASH to maintain backwards compatibility
	export GAUDI_BASH=$BASH
	BASH="$(bash -c 'echo $BASH')"
	export BASH
	
fi

# Load composure first, so we support function metadata and then logging
source "${GAUDI_BASH}/lib/composure.bash"
source "${GAUDI_BASH}/lib/log.bash"

# Load all the libraries
for lib in "${GAUDI_BASH}"/lib/*.bash; do
	[[ "$lib" != "${GAUDI_BASH}/lib/appearance.bash" ]] && _log_component "$lib" "library" && source "$lib"
done

# Load the loader that will load all enabled components
source "${GAUDI_BASH}/scripts/loader.bash"

# Load custom aliases, completions, plugins
CUSTOM_LIB="${GAUDI_BASH_CUSTOM:=${GAUDI_BASH}/components/custom}/*.bash ${GAUDI_BASH_CUSTOM:=${GAUDI_BASH}/components/custom}/**/*.bash"
for custom in ${CUSTOM_LIB}; do [[ -e "${custom}" ]] && _log_component "$custom" "custom" && source "$custom"; done

# Load the bash theme
source "${GAUDI_BASH}/lib/appearance.bash"

# handle the case where GAUDI_BASH_RELOAD_LEGACY is set
if ! command -v reload &> /dev/null && [[ -n "$GAUDI_BASH_RELOAD_LEGACY" ]]; then
	alias reload="source \$HOME/${GAUDI_BASH_PROFILE}"
fi

# Disable trap DEBUG on subshells [ref:https://github.com/Bash-it/gaudi-bash/pull/1040]
set +T

unset _gaudi_bash_config_file
