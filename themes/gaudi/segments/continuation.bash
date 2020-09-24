#!/usr/bin/env bash
#
# Continuation character
#

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_CHAR_PREFIX="${GAUDI_CHAR_PREFIX=""}"
GAUDI_CHAR_SUFFIX="${GAUDI_CHAR_SUFFIX="\\t"}"
GAUDI_CHAR_SYMBOL="${GAUDI_CHAR_SYMBOL="\\uf6d7"}"
GAUDI_CHAR_COLOR="${GAUDI_CHAR_COLOR_SUCCESS="$YELLOW"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Paint PS2 – Continuation interactive prompt
gaudi_continuation() {
  
  gaudi::section \
    "$GAUDI_CHAR_COLOR" \
    "$GAUDI_CHAR_PREFIX" \
    "$GAUDI_CHAR_SYMBOL" \
    "" \
    "$GAUDI_CHAR_SUFFIX"
}