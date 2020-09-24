#!/usr/bin/env bash
#
# Time
#
# Current time

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_TIME_SHOW="${GAUDI_TIME_SHOW=true}"
GAUDI_TIME_PREFIX="${GAUDI_TIME_PREFIX=""}"
GAUDI_TIME_SYMBOL="\\ue384"
GAUDI_TIME_SUFFIX="${GAUDI_TIME_SUFFIX=$GAUDI_PROMPT_DEFAULT_SUFFIX}"
GAUDI_TIME_FORMAT="${GAUDI_TIME_FORMAT="+%H:%M"}"
GAUDI_TIME_COLOR="${GAUDI_TIME_COLOR="$GREEN"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

gaudi_time () {

  [[ $GAUDI_TIME_SHOW == false ]] && return

  local 'time_str'

  if [[ $GAUDI_TIME_FORMAT != false ]]; then
    time_str=`date ${GAUDI_TIME_FORMAT}`
  fi

  gaudi::section \
    "$GAUDI_TIME_COLOR" \
    "$GAUDI_TIME_PREFIX" \
    "$GAUDI_TIME_SYMBOL" \
    "$time_str" \
    "$GAUDI_TIME_SUFFIX"
}
