#!/usr/bin/env bash
#
# Xcode
#
# Xcode is an integrated development environment for macOS.
# Link: https://developer.apple.com/xcode/

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_XCODE_SHOW_LOCAL="${GAUDI_XCODE_SHOW_LOCAL=true}"
GAUDI_XCODE_SHOW_GLOBAL="${GAUDI_XCODE_SHOW_GLOBAL=false}"
GAUDI_XCODE_PREFIX="${GAUDI_XCODE_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_XCODE_SUFFIX="${GAUDI_XCODE_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_XCODE_SYMBOL="${GAUDI_XCODE_SYMBOL="\\ufb32"}"
GAUDI_XCODE_COLOR="${GAUDI_XCODE_COLOR=""}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current version of Xcode
gaudi_xcode () {
  gaudi::exists xcenv || return

  local 'xcode_path'

  if [[ $GAUDI_SWIFT_SHOW_GLOBAL == true ]] ; then
    xcode_path=$(xcenv version | sed 's/ .*//')
  elif [[ $GAUDI_SWIFT_SHOW_LOCAL == true ]] ; then
    if xcenv version | grep ".xcode-version" > /dev/null; then
      xcode_path=$(xcenv version | sed 's/ .*//')
    fi
  fi

  if [[ -n "${xcode_path}" ]]; then
    local xcode_version_path=$xcode_path"/Contents/version.plist"
    if [[ -f ${xcode_version_path} ]]; then
      if gaudi::exists defaults; then
        local xcode_version=$(defaults read ${xcode_version_path} CFBundleShortVersionString)

        gaudi::section \
          "$GAUDI_XCODE_COLOR" \
          "$GAUDI_XCODE_PREFIX" \
          "$GAUDI_XCODE_SYMBOL" \
          "$xcode_version" \
          "$GAUDI_XCODE_SUFFIX"
      fi
    fi
  fi
}
