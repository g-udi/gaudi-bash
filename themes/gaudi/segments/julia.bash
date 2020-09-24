#!/usr/bin/env bash
#
# Julia
#
# A high-level, high-performance dynamic programming language for numerical computing.
# Link: https://julialang.org/

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_JULIA_SHOW="${GAUDI_JULIA_SHOW=true}"
GAUDI_JULIA_PREFIX="${GAUDI_JULIA_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_JULIA_SUFFIX="${GAUDI_JULIA_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_JULIA_SYMBOL="${GAUDI_JULIA_SYMBOL="\\ue624"}"
GAUDI_JULIA_COLOR="${GAUDI_JULIA_COLOR=""}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current version of Julia
gaudi_julia() {
  [[ $GAUDI_JULIA_SHOW == false ]] && return

  # If there are julia files in current directory
  [[ -n $(find . -not -path '*/\.*' -maxdepth 1 -name "*.jl") ]] || return

  gaudi::exists julia || return

  local julia_version=$(julia --version | grep --color=never -oE '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]')

  gaudi::section \
    "$GAUDI_JULIA_COLOR" \
    "$GAUDI_JULIA_PREFIX" \
    "$GAUDI_JULIA_SYMBOL" \
    "$julia_version" \
    "$GAUDI_JULIA_SUFFIX"
}
