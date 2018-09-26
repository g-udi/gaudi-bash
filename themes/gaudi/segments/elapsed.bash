#
# Elapsed
#
# Execution time of the last command.

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_EXEC_TIME_SHOW="${GAUDI_EXEC_TIME_SHOW=true}"
GAUDI_EXEC_TIME_SYMBOL="\\ufa1e"
GAUDI_EXEC_TIME_PREFIX="${GAUDI_EXEC_TIME_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_EXEC_TIME_SUFFIX="${GAUDI_EXEC_TIME_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_EXEC_TIME_COLOR="${GAUDI_EXEC_TIME_COLOR="$YELLOW"}"
GAUDI_EXEC_TIME_ELAPSED_THRESHOLD="2"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

gaudi_elapsed() {

  [[ $GAUDI_EXEC_TIME_SHOW == false ]] && return
  
  if [[ $timer_show -ge $GAUDI_EXEC_TIME_ELAPSED_THRESHOLD ]]; then
    gaudi::section \
      "$GAUDI_EXEC_TIME_COLOR" \
      "$GAUDI_EXEC_TIME_PREFIX" \
      "$GAUDI_EXEC_TIME_SYMBOL" \
      "$(gaudi::displaytime $timer_show)" \
      "$GAUDI_EXEC_TIME_SUFFIX"
  fi
}