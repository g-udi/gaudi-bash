#!/usr/bin/env bash
#
# Conda
#
# Package, dependency and environment management for any language
# Link: https://conda.io/

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_CONDA_SHOW="${GAUDI_CONDA_SHOW=true}"
GAUDI_CONDA_PREFIX="${GAUDI_CONDA_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_CONDA_SUFFIX="${GAUDI_CONDA_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_CONDA_SYMBOL="${GAUDI_CONDA_SYMBOL="\\uf820 "}"
GAUDI_CONDA_COLOR="${GAUDI_CONDA_COLOR="$BLUE"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current conda virtual environment
gaudi_conda () {
  [[ $GAUDI_CONDA_SHOW == false ]] && return

  # Check if running via conda virtualenv
  gaudi::exists conda && [[ -n "$CONDA_DEFAULT_ENV" ]] || return

  gaudi::section \
    "$GAUDI_CONDA_COLOR" \
    "$GAUDI_CONDA_PREFIX" \
    "$GAUDI_CONDA_SYMBOL" \
    "$CONDA_DEFAULT_ENV" \
    "$GAUDI_CONDA_SUFFIX"
}
