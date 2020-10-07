#!/usr/bin/env bash
#
# Haskell Stack
#
# An advanced, purely functional programming language.
# Link: https://www.haskell.org/

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_HASKELL_SHOW="${GAUDI_HASKELL_SHOW=true}"
GAUDI_HASKELL_PREFIX="${GAUDI_HASKELL_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_HASKELL_SUFFIX="${GAUDI_HASKELL_SUFFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_HASKELL_SYMBOL="${GAUDI_HASKELL_SYMBOL="\\ue61f"}"
GAUDI_HASKELL_COLOR="${GAUDI_HASKELL_COLOR=""$MAGENTA""}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current version of Haskell Tool Stack.
gaudi_haskell () {
  [[ $GAUDI_HASKELL_SHOW == false ]] && return

  # If there are stack files in current directory
  [[ -f stack.yaml ]] || return

  # The command is stack, so do not change this to haskell.
  gaudi::exists stack || return

  local haskell_version=$(stack ghc -- --numeric-version --no-install-ghc)

  gaudi::section \
    "$GAUDI_HASKELL_COLOR" \
    "$GAUDI_HASKELL_PREFIX" \
    "$GAUDI_HASKELL_SYMBOL" \
    "$haskell_version" \
    "$GAUDI_HASKELL_SUFFIX"

}
