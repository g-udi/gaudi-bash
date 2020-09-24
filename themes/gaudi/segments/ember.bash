#!/usr/bin/env bash
#
# Ember.js
#
# An open-source JavaScript web framework, based on the MVVM pattern.
# Link: https://www.emberjs.com/

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_EMBER_SHOW="${GAUDI_EMBER_SHOW=true}"
GAUDI_EMBER_PREFIX="${GAUDI_EMBER_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_EMBER_SUFFIX="${GAUDI_EMBER_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_EMBER_SYMBOL="${GAUDI_EMBER_SYMBOL="\\ue71b"}"
GAUDI_EMBER_COLOR="${GAUDI_EMBER_COLOR=""}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current version of Ember, exception system.
gaudi_ember () {
  [[ $GAUDI_EMBER_SHOW == false ]] && return

  # Show EMBER status only for folders w/ ember-cli-build.js files
  [[ -f ember-cli-build.js && -f node_modules/ember-cli/package.json ]] || return

  local ember_version=$(grep '"version":' ./node_modules/ember-cli/package.json | cut -d\" -f4)

  [[ $ember_version == "system" || $ember_version == "ember" ]] && return

  gaudi::section \
    "$GAUDI_EMBER_COLOR" \
    "$GAUDI_EMBER_PREFIX" \
    "$GAUDI_EMBER_SYMBOL" \
    "v.$ember_version" \
    "$GAUDI_EMBER_SUFFIX"
}
