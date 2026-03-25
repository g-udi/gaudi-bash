#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC1090,SC1091,SC2034,SC2139

# Initialize Bash It
GAUDI_BASH_LOG_PREFIX="CORE"
: "${GAUDI_BASH:=${BASH_SOURCE%/*}}"
: "${GAUDI_BASH_BASHRC:=${BASH_SOURCE[${#BASH_SOURCE[@]}-1]}}"

case $OSTYPE in
	darwin*)
		export GAUDI_BASH_PROFILE=".bash_profile"
		;;
	*)
		export GAUDI_BASH_PROFILE=".bashrc"
		;;
esac

# Array of callbacks to run after all components are loaded
GAUDI_BASH_LIBRARY_FINALIZE_HOOK=()

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
: "${GAUDI_BASH_CUSTOM:=${GAUDI_BASH}/components/custom}"
_gaudi_bash_glob_save=$(shopt -p nullglob globstar 2> /dev/null)
shopt -s nullglob globstar
for custom in "${GAUDI_BASH_CUSTOM}"/*.bash "${GAUDI_BASH_CUSTOM}"/**/*.bash; do
	_log_component "$custom" "custom" && source "$custom"
done
eval "$_gaudi_bash_glob_save"
unset _gaudi_bash_glob_save

# Load the bash theme
source "${GAUDI_BASH}/lib/appearance.bash"

# Run any registered finalize hooks (for plugins that need everything loaded first)
for _gaudi_bash_hook in "${GAUDI_BASH_LIBRARY_FINALIZE_HOOK[@]}"; do
	"$_gaudi_bash_hook"
done
unset _gaudi_bash_hook

# handle the case where GAUDI_BASH_RELOAD_LEGACY is set
if ! command -v reload &> /dev/null && [[ -n "$GAUDI_BASH_RELOAD_LEGACY" ]]; then
	alias reload="source \$HOME/${GAUDI_BASH_PROFILE}"
fi

# Disable trap DEBUG on subshells
set +T

unset _gaudi_bash_config_file
