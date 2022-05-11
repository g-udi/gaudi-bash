#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC1090

export GAUDI_BASH_LOG_LEVEL_ERROR=1
export GAUDI_BASH_LOG_LEVEL_WARNING=2
export GAUDI_BASH_LOG_LEVEL_ALL=3

export GAUDI_BASH_LOG_GENERAL_COLOR=${MAGENTA}
export GAUDI_BASH_LOG_DEBUG_COLOR=${GREEN}
export GAUDI_BASH_LOG_WARNING_COLOR=${YELLOW}
export GAUDI_BASH_LOG_ERROR_COLOR=${RED}

# : "${GAUDI_LOG_DISABLE_COLOR:=0}"

# @function     _gaudi-bash-get-component-name-from-path
# @description  get a component name from a component path
# @param $1     component path: filesystem path for the component e.g., /Users/ahmadassaf/.gaudi_bash/lib/colors.plugins.bash
# @return       component name stripped from the extension e.g., colors
_gaudi-bash-get-component-name-from-path() {
	about "get a component name from a component path"
	group "gaudi-bash:log"

	local file_name component_name

	file_name=${1%.*.bash}
	component_name=${file_name##*/}
	echo "${component_name##*"$GAUDI_BASH_LOAD_PRIORITY_SEPARATOR"}"
}

# @function     _gaudi-bash-get-component-type-from-path
# @description  get a component type from a component path in a singular form (alias, plugin, completion)
# @param $1     component path: filesystem path for the component e.g., /Users/ahmadassaf/.gaudi_bash/lib/colors.plugins.bash
# @return       component type in singular form e.g., plugin
_gaudi-bash-get-component-type-from-path() {
	about "get a component type from a component path in a singular form (alias, plugin, completion)"
	group "gaudi-bash:log"

	local filename

	filename=${1##*/}
	filename=$(echo "${filename##*"$GAUDI_BASH_LOAD_PRIORITY_SEPARATOR"}" | cut -d "." -f 2)
	_gaudi-bash-singularize-component "$filename"
}

# @function     _log_general
# @description  logs a message to terminal
#               uses GAUDI_BASH_LOG_PREFIX as a prefix or fallbacks to [CORE] if not defined
# @param $1     log type: log type of: DEBUG, WARN, ERROR
# @param $2     log message: the log message to print
# @return       message printed in the terminal
_log_general() {
	about "internal function used for logging, uses GAUDI_BASH_LOG_PREFIX as a prefix"
	group "gaudi-bash:log"

	[[ -z $1 ]] && return

	# When no GAUDI_BASH_LOG_PREFIX is defined fallback to [CORE]
	GAUDI_BASH_LOG_PREFIX=${GAUDI_BASH_LOG_PREFIX:-"CORE"}

	local log_type log_color log_prefix

	log_type=${2:-GENERAL}
	log_prefix="${NC}${YELLOW}[${GAUDI_BASH_LOG_PREFIX}]${NC}"

	if [[ -n $GAUDI_LOG_DISABLE_COLOR  ]]; then
		printf "%s\n" " [ ${log_type^^} ] ${log_prefix} $1"
	else
		log_color=GAUDI_BASH_LOG_${log_type^^}_COLOR
		printf "%b\n" "${!log_color} [ ${log_type^^} ] ${log_prefix} $1"
	fi
}

# @function     _log_debug
# @description  log a debug message by echoing to the screen
#               needs GAUDI_BASH_LOG_LEVEL >= GAUDI_BASH_LOG_LEVEL_ALL"
#               used the default debug color defined in GAUDI_BASH_LOG_DEBUG_COLOR
# @param $1     log message: message to be logged
# @return       log message printed in the terminal
_log_debug() {
	about "log a debug message by echoing to the screen"
	group "gaudi-bash:log"

	[[ "$GAUDI_BASH_LOG_LEVEL" -ge $GAUDI_BASH_LOG_LEVEL_ALL ]] || return 0
	_log_general "$1" debug
}

# @function     _log_warning
# @description  log a wraning message by echoing to the screen
#               needs GAUDI_BASH_LOG_LEVEL >= GAUDI_BASH_LOG_LEVEL_WARNING"
#               used the default warning color defined in GAUDI_BASH_LOG_WARN_COLOR
# @param $1     log message: message to be logged
# @return       log message printed in the terminal
_log_warning() {
	about "log a warning message by echoing to the screen"
	group "gaudi-bash:log"

	[[ "$GAUDI_BASH_LOG_LEVEL" -ge $GAUDI_BASH_LOG_LEVEL_WARNING ]] || return 0
	_log_general "$1" warning
}

# @function     _log_error
# @description  log an error message by echoing to the screen
#               needs GAUDI_BASH_LOG_LEVEL >= GAUDI_BASH_LOG_LEVEL_ERROR"
#               used the default error color defined in GAUDI_BASH_LOG_ERROR_COLOR
# @param $1     log message: message to be logged
# @return       log message printed in the terminal
_log_error() {
	about "log an error message by echoing to the screen"
	group "gaudi-bash:log"

	[[ "$GAUDI_BASH_LOG_LEVEL" -ge $GAUDI_BASH_LOG_LEVEL_ERROR ]] || return 0
	_log_general "$1" error
}

# @function     _log_component
# @description  component-aware log proxy that logs a message when components are loaded
#               the function print a log message using the _log_general function with the extractec component name and type
# @param $1     component path: filesystem path for the component e.g., /Users/ahmadassaf/.gaudi_bash/lib/colors.plugins.bash
# @param $2     component type: component type e.g., library, custom, theme, component (default: component)
#                 - library: a gaudi-bash core library file e.g., colors, appearence, etc.
#                 - component: a gaudi-bash component of any of the types: alias, plugin or completion
#                 - custom: a gaudi-bash custom component of any type
# @return       message (log) printed in the terminal
_log_component() {
	about "log a component loading message by echoing to the screen the name and type"
	group "gaudi-bash:log"

	[[ "$GAUDI_BASH_LOG_LEVEL" -ge $GAUDI_BASH_LOG_LEVEL_ALL ]] || return 0

	local type component_path component_name component_type

	component_path=${1}
	type=${2:-component}

	if [[ $type = "component" ]]; then
		component_name="$(_gaudi-bash-get-component-name-from-path "$component_path")"
		component_type="$(_gaudi-bash-get-component-type-from-path "$component_path")"
		_log_general "Loading ${MAGENTA}$component_type${NC}: ${GREEN}$component_name${NC}" debug
	else
		component_name=${component_path##*/}
		_log_general "Loading ${MAGENTA}$type${NC}: ${component_name%*.bash}" debug
	fi

}
