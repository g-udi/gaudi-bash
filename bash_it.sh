#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034

# Initialize Bash It
BASH_IT_LOG_PREFIX="CORE"

# Only set $BASH_IT if it's not already set
if [[ -z "$BASH_IT" ]];
then
  # Setting $BASH to maintain backwards compatibility
  export BASH_IT=$BASH
  BASH="$(bash -c 'echo $BASH')"
  export BASH
fi

# Load composure first, so we support function metadata and then logging
source "${BASH_IT}/lib/composure.bash"
source "${BASH_IT}/lib/log.bash"

# Load all the libraries
for lib in "${BASH_IT}"/lib/*.bash; do
  [[ "$lib" != "${BASH_IT}/lib/appearance.bash" ]] && _log_component "$lib" "library" && source "$lib"
done

# Load the reloader script that will load all enabled components
source "${BASH_IT}/scripts/reloader.bash"

# Load enabled aliases, completion, plugins
for file_type in "aliases" "plugin" "completion"; do source "${BASH_IT}/scripts/reloader.bash" "skip" "$file_type"; done

# Load custom aliases, completions, plugins
CUSTOM_LIB="${BASH_IT_CUSTOM:=${BASH_IT}/components/custom}/*.bash ${BASH_IT_CUSTOM:=${BASH_IT}/components/custom}/**/*.bash"
for custom in ${CUSTOM_LIB}; do [[ -e "${custom}" ]] && _log_component "$custom" "custom" && source "$custom"; done

# Load the bash theme
source "${BASH_IT}/lib/appearance.bash"

# handle the case where BASH_IT_RELOAD_LEGACY is set
if ! command -v reload &>/dev/null && [[ -n "$BASH_IT_RELOAD_LEGACY" ]]; then
  case $OSTYPE in
    darwin*)
      alias reload='source ~/.bash_profile'
      ;;
    *)
      alias reload='source ~/.bashrc'
      ;;
  esac
fi

# Disable trap DEBUG on subshells [ref:https://github.com/Bash-it/bash-it/pull/1040]
set +T

unset _bash_it_config_file
