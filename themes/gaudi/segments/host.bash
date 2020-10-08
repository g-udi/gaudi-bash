#!/usr/bin/env bash
#
# Hostname
#

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_HOST_SHOW="${GAUDI_HOST_SHOW=always}"
GAUDI_HOST_PREFIX="${GAUDI_HOST_PREFIX=""}"
GAUDI_HOST_SUFFIX="${GAUDI_HOST_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_HOST_COLOR="${GAUDI_HOST_COLOR="$GAUDI_WHITE$BACKGROUND_GAUDI_BLUE"}"
GAUDI_HOST_COLOR_SSH="${GAUDI_HOST_COLOR_SSH="$GAUDI_BLACK$BACKGROUND_GAUDI_YELLOW"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# If there is an ssh connections, current machine name.
gaudi_host () {
  [[ $GAUDI_HOST_SHOW == false ]] && return

  if [[ $GAUDI_HOST_SHOW == 'always' ]] || [[ -n $SSH_CONNECTION ]]; then
    local host_color host

    # Determination of what color should be used
    if [[ -n $SSH_CONNECTION ]] || [[ -n "${SSH_CLIENT-}${SSH2_CLIENT-}${SSH_TTY-}" ]]; then
      host_color=$GAUDI_HOST_COLOR_SSH
    else
      host_color=$GAUDI_HOST_COLOR
    fi

    gaudi::section \
      "$host_color" \
      "$GAUDI_HOST_PREFIX" \
      "$GAUDI_HOST_PREFIX" \
      "$(hostname)" \
      "$GAUDI_HOST_SUFFIX"
  fi
}
