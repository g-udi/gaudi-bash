#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034

# Initialize Bash It
BASH_IT_LOG_PREFIX="[CORE]"

# Only set $BASH_IT if it's not already set
if [ -z "$BASH_IT" ];
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
for lib in ${BASH_IT}/lib/*.bash; do _log_component "$lib" && source "$lib"; done

source "${BASH_IT}/scripts/reloader.bash"

# Load enabled aliases, completion, plugins
for file_type in "aliases" "plugins" "completion"; do source "${BASH_IT}/scripts/reloader.bash" "skip" "$file_type"; done

# Load theme, if a theme was set
if [[ -n "${BASH_IT_THEME}" ]]; then
  _log_debug "Loading \"${BASH_IT_THEME}\" theme..."
  BASH_IT_LOG_PREFIX="lib: appearance: "
  # appearance (themes) now, after all dependencies
  # shellcheck source=./lib/appearance.bash
  source "${BASH_IT}/lib/appearance.bash"
fi

BASH_IT_LOG_PREFIX="core: main: "
_log_debug "Loading custom aliases, completion, plugins..."
for file_type in "aliases" "completion" "plugins"
do
  if [ -e "${BASH_IT}/${file_type}/custom.${file_type}.bash" ]
  then
    BASH_IT_LOG_PREFIX="${file_type}: custom: "
    _log_debug "Loading component..."
    source "${BASH_IT}/${file_type}/custom.${file_type}.bash"
  fi
done

# Custom
BASH_IT_LOG_PREFIX="core: main: "
_log_debug "Loading general custom files..."
CUSTOM="${BASH_IT_CUSTOM:=${BASH_IT}/custom}/*.bash ${BASH_IT_CUSTOM:=${BASH_IT}/custom}/**/*.bash"
for _bash_it_config_file in $CUSTOM
do
  if [ -e "${_bash_it_config_file}" ]; then
    filename=$(basename "${_bash_it_config_file}")
    filename=${filename%*.bash}
    BASH_IT_LOG_PREFIX="custom: $filename: "
    _log_debug "Loading custom file..."
    # shellcheck disable=SC1090
    source "$_bash_it_config_file"
  fi
done

# handle the case where BASH_IT_RELOAD_LEGACY is set
if ! command -v reload &>/dev/null && [ -n "$BASH_IT_RELOAD_LEGACY" ]; then
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
