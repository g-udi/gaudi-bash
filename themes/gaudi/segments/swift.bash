#!/usr/bin/env bash
#
# Swift
#
# A general-purpose, multi-paradigm, compiled programming language by Apple Inc.
# Link: https://developer.apple.com/swift/

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_SWIFT_SHOW_LOCAL="${GAUDI_SWIFT_SHOW_LOCAL=true}"
GAUDI_SWIFT_SHOW_GLOBAL="${GAUDI_SWIFT_SHOW_GLOBAL=false}"
GAUDI_SWIFT_PREFIX="${GAUDI_SWIFT_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_SWIFT_SUFFIX="${GAUDI_SWIFT_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_SWIFT_SYMBOL="${GAUDI_SWIFT_SYMBOL="\\ufbe3"}"
GAUDI_SWIFT_COLOR="${GAUDI_SWIFT_COLOR=""}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current version of Swift
gaudi_swift() {
  gaudi::exists swiftenv || return

  local 'swift_version'

  if [[ $GAUDI_SWIFT_SHOW_GLOBAL == true ]] ; then
    swift_version=$(swiftenv version | sed 's/ .*//')
  elif [[ $GAUDI_SWIFT_SHOW_LOCAL == true ]] ; then
    if swiftenv version | grep ".swift-version" > /dev/null; then
      swift_version=$(swiftenv version | sed 's/ .*//')
    fi
  fi

  [ -n "${swift_version}" ] || return

  gaudi::section \
    "$GAUDI_SWIFT_COLOR" \
    "$GAUDI_SWIFT_PREFIX" \
    "$GAUDI_SWIFT_SYMBOL" \
    "$swift_version" \
    "$GAUDI_SWIFT_SUFFIX"
}
