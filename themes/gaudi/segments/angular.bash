#!/usr/bin/env bash
#
# Angular.js
#
# An open-source JavaScript web framework.
# Link: https://www.angular.io/

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_ANGULAR_SHOW="${GAUDI_ANGULAR_SHOW=true}"
GAUDI_ANGULAR_PREFIX="${GAUDI_ANGULAR_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_ANGULAR_SUFFIX="${GAUDI_ANGULAR_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_ANGULAR_SYMBOL="${GAUDI_ANGULAR_SYMBOL="\\ufbb0"}"
GAUDI_ANGULAR_COLOR="${GAUDI_ANGULAR_COLOR="$RED"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current version of Ember, exception system.
gaudi_angular () {
  [[ $GAUDI_ANGULAR_SHOW == false ]] && return

  [[ -f node_modules/angular/package.json ]] || return

  local angular_version=$(grep '"version":' ./node_modules/angular/package.json | cut -d\" -f4)

  [[ $angular_version == "system" || $angular_version == "angular" ]] && return

  gaudi::section \
    "$GAUDI_ANGULAR_COLOR" \
    "$GAUDI_ANGULAR_PREFIX" \
    "$GAUDI_ANGULAR_SYMBOL" \
    "v.$angular_version" \
    "$GAUDI_ANGULAR_SUFFIX"
}
