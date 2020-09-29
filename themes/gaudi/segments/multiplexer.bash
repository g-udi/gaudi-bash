#!/usr/bin/env bash
#
# Multiplexer
# A terminal multiplexer, allowing a user to access multiple separate terminal sessions inside a single terminal window or remote terminal session.
# Currently supporting tmux and screen
# tmux: https://github.com/tmux/tmux
# screen: https://www.gnu.org/software/screen/
#

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_MULTIPLEXER_SHOW="${GAUDI_MULTIPLEXER_SHOW=true}"
GAUDI_MULTIPLEXER_PREFIX="${GAUDI_MULTIPLEXER_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_MULTIPLEXER_SUFFIX="${GAUDI_MULTIPLEXER_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_MULTIPLEXER_SYMBOL="\\uf878"
GAUDI_MULTIPLEXER_COLOR="${GAUDI_MULTIPLEXER_COLOR=""}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current Maven version
gaudi_multiplexer () {
  [[ $GAUDI_MULTIPLEXER_SHOW == false ]] && return

  # Check if tmux or scren are installed
  ! gaudi::exists tmux && ! gaudi::exists screen && return

  local multiplexers

  detached_tmux_sessions=$(tmux list-sessions 2> /dev/null | \grep -cv 'attached')
  detached_screen_sessions=$(screen -ls 2> /dev/null | \grep -c '[Dd]etach[^)]*)$')

  [[ $detached_tmux_sessions == 0 ]] && [[ $detached_screen_sessions == 0 ]] && return

  [[ $detached_tmux_sessions != 0 ]] && multiplexers=" T:$detached_tmux_sessions"
  [[ $detached_screen_sessions != 0 ]] && multiplexers="$multiplexers S:$detached_screen_sessions"

  gaudi::section \
    "$GAUDI_MULTIPLEXER_COLOR" \
    "$GAUDI_MULTIPLEXER_PREFIX" \
    "$GAUDI_MULTIPLEXER_SYMBOL" \
    "$multiplexers" \
    "$GAUDI_MULTIPLEXER_SUFFIX"
}
