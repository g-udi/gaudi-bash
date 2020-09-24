#
# Elapsed
#
# Execution time of the last command.

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_EXEC_TIME_SHOW="${GAUDI_EXEC_TIME_SHOW=true}"
GAUDI_EXEC_TIME_SYMBOL="\\b\\ufa1e"
GAUDI_EXEC_TIME_PREFIX="${GAUDI_EXEC_TIME_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_EXEC_TIME_SUFFIX="${GAUDI_EXEC_TIME_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_EXEC_TIME_COLOR="${GAUDI_EXEC_TIME_COLOR="$ORANGE"}"
GAUDI_EXEC_TIME_ELAPSED_THRESHOLD="2"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

gaudi_elapsed () {

    local _GAUDI_TIMER

    [[ $GAUDI_EXEC_TIME_SHOW == false ]] && return

    [[ "$BASH_COMMAND" != "$PROMPT_COMMAND" ]] || return

    _gaudi::timer_start () {
        _GAUDI_TIMER=${_GAUDI_TIMER:-$SECONDS}
    }

    _gaudi::timer_stop () {
        GAUDI_TIMER=$(($SECONDS - $_GAUDI_TIMER))
        if [[ $GAUDI_TIMER -ge $GAUDI_EXEC_TIME_ELAPSED_THRESHOLD ]]; then
            echo -e "\n$(gaudi::section \
                "$GAUDI_EXEC_TIME_COLOR" \
                "$GAUDI_EXEC_TIME_PREFIX" \
                "$GAUDI_EXEC_TIME_SYMBOL" \
                "\\bLast Command Runtime: [${GAUDI_TIMER}]s" \
                "$GAUDI_EXEC_TIME_SUFFIX")"
        fi
        unset _GAUDI_TIMER
    }

    trap '_gaudi::timer_start' DEBUG

    if [ "$PROMPT_COMMAND" == "" ]; then
        PROMPT_COMMAND="_gaudi::timer_stop"
    else
        PROMPT_COMMAND="$PROMPT_COMMAND; _gaudi::timer_stop"
    fi
}
