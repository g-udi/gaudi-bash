#!/usr/bin/env bash
#
# Elixir
#
# Elixir is a dynamic, functional language designed for building scalable applications.
# Link: https://elixir-lang.org/

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_ELIXIR_SHOW="${GAUDI_ELIXIR_SHOW=true}"
GAUDI_ELIXIR_PREFIX="${GAUDI_ELIXIR_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_ELIXIR_SUFFIX="${GAUDI_ELIXIR_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_ELIXIR_SYMBOL="${GAUDI_ELIXIR_SYMBOL="\\ue275"}"
GAUDI_ELIXIR_DEFAULT_VERSION="${GAUDI_ELIXIR_DEFAULT_VERSION=""}"
GAUDI_ELIXIR_COLOR="${GAUDI_ELIXIR_COLOR="$GAUDI_MAGENTA"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current version of Elixir
gaudi_elixir () {
  [[ $GAUDI_ELIXIR_SHOW == false ]] && return

  # Show versions only for Elixir-specific folders
  [[ -f mix.exs ||
     -n $(find . -not -path '*/\.*' -maxdepth 1 -name "*.ex") ||
     -n $(find . -not -path '*/\.*' -maxdepth 1 -name "*.exs")
  ]] || return

  local 'elixir_version'

  if gaudi::exists kiex; then
    elixir_version="${ELIXIR_VERSION}"
  elif gaudi::exists exenv; then
    elixir_version=$(exenv version-name)
  fi

  if [[ $elixir_version == "" ]]; then
    gaudi::exists elixir || return
    elixir_version=$(elixir -v 2>/dev/null | grep "Elixir" --color=never | cut -d ' ' -f 2)
  fi

  [[ $elixir_version == "system" ]] && return
  [[ $elixir_version == $GAUDI_ELIXIR_DEFAULT_VERSION ]] && return

  # Add 'v' before elixir version that starts with a number
  [[ "${elixir_version}" =~ ^[0-9].+$ ]] && elixir_version="v${elixir_version}"

  gaudi::section \
    "$GAUDI_ELIXIR_COLOR" \
    "$GAUDI_ELIXIR_PREFIX" \
    "$GAUDI_ELIXIR_SYMBOL" \
    "$elixir_version" \
    "$GAUDI_ELIXIR_SUFFIX"
}
