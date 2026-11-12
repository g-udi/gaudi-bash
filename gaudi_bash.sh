#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC1090,SC1091,SC2034

# gaudi-bash needs Bash 4.3 or newer: an older Bash (e.g., the /bin/bash 3.2 of macOS) is told so and left as it is
if [[ -z "${BASH_VERSINFO[0]:-}" ]] || ((BASH_VERSINFO[0] < 4 || (BASH_VERSINFO[0] == 4 && BASH_VERSINFO[1] < 3))); then
	printf '%s\n' "gaudi-bash needs Bash 4.3 or newer and was not loaded (this is Bash ${BASH_VERSION:-unknown})." >&2
	if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
		return 1
	fi
	exit 1
fi

# Initialize gaudi-bash
GAUDI_BASH_LOG_PREFIX="CORE"
: "${GAUDI_BASH:=${BASH_SOURCE%/*}}"

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

# Load the libraries, each one once and in the order they depend on each other:
# composure (function metadata) comes first, then the colors used by the logging, then the logging itself
for _gaudi_bash_lib in composure colors log; do
	source "${GAUDI_BASH}/lib/${_gaudi_bash_lib}.bash"
done
# The first three could not be reported before the logging was loaded
for _gaudi_bash_lib in composure colors log gaudi-bash history preexec command_duration search; do
	_log_component "${GAUDI_BASH}/lib/${_gaudi_bash_lib}.bash" "library"
	case "$_gaudi_bash_lib" in
		composure | colors | log) ;;
		*) source "${GAUDI_BASH}/lib/${_gaudi_bash_lib}.bash" ;;
	esac
done
unset _gaudi_bash_lib

# Load the loader that will load all enabled components
source "${GAUDI_BASH}/scripts/loader.bash"

# Load custom aliases, completions, plugins
: "${GAUDI_BASH_CUSTOM:=${GAUDI_BASH}/components/custom}"
: "${GAUDI_BASH_CUSTOM_PATHS:=$GAUDI_BASH_CUSTOM}"
while IFS= read -r custom_dir; do
	[[ -n "$custom_dir" && -d "$custom_dir" ]] || continue
	while IFS= read -r custom; do
		_log_component "$custom" "custom" && source "$custom"
	done < <(find "$custom_dir" -type f -name '*.bash' | sort)
done < <(printf "%s\n" "$GAUDI_BASH_CUSTOM_PATHS" | tr ':' '\n')
unset custom_dir custom

# Load the bash theme
source "${GAUDI_BASH}/lib/appearance.bash"

# Run any registered finalize hooks (for plugins that need everything loaded first)
for _gaudi_bash_hook in "${GAUDI_BASH_LIBRARY_FINALIZE_HOOK[@]}"; do
	"$_gaudi_bash_hook"
done
unset _gaudi_bash_hook

# Disable trap DEBUG on subshells
set +T
