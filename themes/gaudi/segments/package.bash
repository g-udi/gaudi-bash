#!/usr/bin/env bash
#
# Package
#
# Current package version.
# These package managers supported:
#   * NPM

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_PACKAGE_SHOW="${GAUDI_PACKAGE_SHOW=true}"
GAUDI_PACKAGE_PREFIX="${GAUDI_PACKAGE_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_PACKAGE_SYMBOL="${GAUDI_PACKAGE_SYMBOL="\\ufc29"}"
GAUDI_PACKAGE_SUFFIX="${GAUDI_PACKAGE_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_PACKAGE_COLOR="${GAUDI_PACKAGE_COLOR=""}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

gaudi_package() {
  [[ $GAUDI_PACKAGE_SHOW == false ]] && return

  # Show package version only when repository is a package
  # @todo: add more package managers
  [[ -f package.json ]] || return

  gaudi::exists npm || return

  local 'package_version'

  if gaudi::exists jq; then
    package_version=$(jq -r '.version' package.json 2>/dev/null)
  else
    package_version=$(grep -E '^  "version": "v?([0-9]+\.){1,}' package.json | cut -d\" -f4  2>/dev/null)
  fi

  [[ -z $package_version || $package_version == null ]] && return

  gaudi::section \
    "$GAUDI_PACKAGE_COLOR" \
    "$GAUDI_PACKAGE_PREFIX" \
    "$GAUDI_PACKAGE_SYMBOL" \
    "v.$package_version" \
    "$GAUDI_PACKAGE_SUFFIX"
}
