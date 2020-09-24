#!/usr/bin/env bash
#
# React.js
#
# An open-source JavaScript web framework.
# Link: https://www.reactjs.org/

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_REACT_SHOW="${GAUDI_REACT_SHOW=true}"
GAUDI_REACT_PREFIX="${GAUDI_REACT_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_REACT_SUFFIX="${GAUDI_REACT_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_REACT_SYMBOL="${GAUDI_REACT_SYMBOL="\\ufc06"}"
GAUDI_REACT_COLOR="${GAUDI_REACT_COLOR="$CYAN"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current version of Ember, exception system.
gaudi_react () {
  [[ $GAUDI_REACT_SHOW == false ]] && return

  [[ -f node_modules/react/package.json ]] || return

  local react_version=$(grep '"version":' ./node_modules/react/package.json | cut -d\" -f4)
  [[ $react_version == "system" || $react_version == "react" ]] && return

  gaudi::section \
    "$GAUDI_REACT_COLOR" \
    "$GAUDI_REACT_PREFIX" \
    "$GAUDI_REACT_SYMBOL" \
    "v.$react_version" \
    "$GAUDI_REACT_SUFFIX"
}
