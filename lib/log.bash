#!/usr/bin/env bash
# shellcheck disable=SC1090

export BASH_IT_LOG_LEVEL_ERROR=1
export BASH_IT_LOG_LEVEL_WARNING=2
export BASH_IT_LOG_LEVEL_ALL=3

export BASH_IT_LOG_GENERAL_COLOR=${MAGENTA}
export BASH_IT_LOG_DEBUG_COLOR=${GREEN}
export BASH_IT_LOG_WARNING_COLOR=${YELLOW}
export BASH_IT_LOG_ERROR_COLOR=${RED}

source "$BASH_IT/lib/helpers/components.bash"

# @function     _bash-it-get-component-name-from-path
# @description  Get a component name from a component path
#
# @param $1     component path: filesystem path for the component e.g., /Users/ahmadassaf/.bash_it/lib/colors.plugins.bash
# @return       component name stripped from the extension e.g., colors
_bash-it-get-component-name-from-path () {
  about "get a component name from a component path"
  group "bash-it:log"

  local file_name component_name

  file_name=${1%.*.bash}
  component_name=${file_name##*/}
  echo "${component_name##*$BASH_IT_LOAD_PRIORITY_SEPARATOR}"
}

# @function     _bash-it-get-component-type-from-path
# @description  Get a component type from a component path in a singular form (alias, plugin, completion)
#
# @param $1     component path: filesystem path for the component e.g., /Users/ahmadassaf/.bash_it/lib/colors.plugins.bash
# @return       component type in singular form e.g., plugin
_bash-it-get-component-type-from-path () {
  about "get a component type from a component path in a singular form (alias, plugin, completion)"
  group "bash-it:log"

  local filename

  filename=${1##*/}
  filename=$(echo "${filename##*$BASH_IT_LOAD_PRIORITY_SEPARATOR}" | cut -d "." -f 2)
  _bash-it-singularize-component "$filename"
}

# @function     _log_general
# @description  Logs a message to terminal
#               Uses BASH_IT_LOG_PREFIX as a prefix or fallbacks to [CORE] if not defined
# @param $1     log type: log type of: DEBUG, WARN, ERROR
# @param $2     log message: the log message to print
# @return       A message printed in the terminal
_log_general () {
  about "internal function used for logging, uses BASH_IT_LOG_PREFIX as a prefix"
  group "bash-it:log"

  [[ -z $1 ]] && return

  # If no BASH_IT_LOG_PREFIX is defined fallback to [CORE]
  BASH_IT_LOG_PREFIX=${BASH_IT_LOG_PREFIX:-"CORE"}

  local log_type log_color log_prefix

  log_type=${2:-GENERAL}
  log_color="BASH_IT_LOG_${log_type^^}_COLOR"
  log_prefix="${NC}${YELLOW}[${BASH_IT_LOG_PREFIX}]${NC}"

  echo -e "${!log_color} [ ${log_type^^} ] ${log_prefix} $1"
}

# @function     _log_debug
# @description  log a debug message by echoing to the screen
#               Needs BASH_IT_LOG_LEVEL >= BASH_IT_LOG_LEVEL_ALL"
#               Used the default debug color defined in BASH_IT_LOG_DEBUG_COLOR
# @param $1     log message: message to be logged
# @return       A log message printed in the terminal
_log_debug () {
  about "log a debug message by echoing to the screen"
  group "bash-it:log"

  [[ "$BASH_IT_LOG_LEVEL" -ge $BASH_IT_LOG_LEVEL_ALL ]] || return 0
  _log_general "$1" debug
}

# @function     _log_warning
# @description  log a wraning message by echoing to the screen
#               Needs BASH_IT_LOG_LEVEL >= BASH_IT_LOG_LEVEL_WARNING"
#               Used the default warning color defined in BASH_IT_LOG_WARN_COLOR
# @param $1     log message: message to be logged
# @return       A log message printed in the terminal
_log_warning () {
  about "log a warning message by echoing to the screen"
  group "bash-it:log"

  [[ "$BASH_IT_LOG_LEVEL" -ge $BASH_IT_LOG_LEVEL_WARNING ]] || return 0
  _log_general "$1" warning
}

# @function     _log_error
# @description  log an error message by echoing to the screen
#               Needs BASH_IT_LOG_LEVEL >= BASH_IT_LOG_LEVEL_ERROR"
#               Used the default error color defined in BASH_IT_LOG_ERROR_COLOR
# @param $1     log message: message to be logged
# @return       A log message printed in the terminal
_log_error () {
  about "log an error message by echoing to the screen"
  group "bash-it:log"

  [[ "$BASH_IT_LOG_LEVEL" -ge $BASH_IT_LOG_LEVEL_ERROR ]] || return 0
  _log_general "$1" error
}

# @function     _log_component
# @description  Component-aware log proxy that logs a message when components are loaded
#               The function print a log message using the _log_general function with the extractec component name and type
#
# @param $1     component path: filesystem path for the component e.g., /Users/ahmadassaf/.bash_it/lib/colors.plugins.bash
# @param $2     component type: component type e.g., library, custom, theme, component (default: component)
#                 library: a bash-it core library file e.g., colors, appearence, etc.
#                 component: a bash-it component of any of the types: alias, plugin or completion
#                 custom: a bash-it custom component of any type
# @return       A message (log) printed in the terminal
_log_component () {
  about "log a component loading message by echoing to the screen the name and type"
  group "bash-it:log"

  [[ "$BASH_IT_LOG_LEVEL" -ge $BASH_IT_LOG_LEVEL_ERROR ]] || return 0

  local type component_path component_name component_type

  component_path=${1}
  type=${2:-component}

  if [[ $type = "component" ]]; then
    component_name="$(_bash-it-get-component-name-from-path "$component_path")"
    component_type="$(_bash-it-get-component-type-from-path "$component_path")"
    _log_general "Loading ${MAGENTA}$component_type${NC}: ${GREEN}$component_name${NC}" debug
  else
    component_name=${component_path##*/}
    _log_general "Loading ${MAGENTA}$type${NC}: ${component_name%*.bash}" debug
  fi

}
