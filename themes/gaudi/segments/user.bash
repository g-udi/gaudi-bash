#!/usr/bin/env bash
#
# Username
#

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

# --------------------------------------------------------------------------
# | GAUDI_USER_SHOW | show username on local | show username on remote |
# |---------------------+------------------------+-------------------------|
# | false               | never                  | never                   |
# | always              | always                 | always                  |
# | true                | if needed              | always                  |
# | needed              | if needed              | if needed               |
# --------------------------------------------------------------------------

GAUDI_USER_SHOW="${GAUDI_USER_SHOW=always}"
GAUDI_USER_PREFIX="${GAUDI_USER_PREFIX=""}"
GAUDI_USER_SUFFIX="${GAUDI_USER_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_USER_COLOR="${GAUDI_USER_COLOR="$GAUDI_WHITE$BACKGROUND_GAUDI_GREEN"}"
GAUDI_USER_COLOR_ROOT="${GAUDI_USER_COLOR_ROOT="$GAUDI_WHITE$BACKGROUND_GAUDI_RED"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

gaudi_user () {
  [[ $GAUDI_USER_SHOW == false ]] && return

  if [[ $GAUDI_USER_SHOW == 'always' ]] \
  || [[ $LOGNAME != $USER ]] \
  || [[ $UID == 0 ]] \
  || [[ $GAUDI_USER_SHOW == true && -n $SSH_CONNECTION ]]
  then
    local user_color user_symbol

    if [[ $USER == 'root' ]]; then
      user_color=$GAUDI_USER_COLOR_ROOT
      user_symbol=" \\uf83d"
    else
      user_color="$GAUDI_USER_COLOR"
    fi

    gaudi::section \
      "$user_color" \
      "$GAUDI_USER_PREFIX" \
      "$user_symbol" \
      "$USER" \
      "$GAUDI_USER_SUFFIX"
  fi
}
