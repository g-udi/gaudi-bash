#
# Prompt character
#
# Why are we using new ANSI codes for the colors and not our tput you say ?
#
# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_CHAR_PREFIX="${GAUDI_CHAR_PREFIX=""}"
GAUDI_CHAR_SUFFIX="${GAUDI_CHAR_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_CHAR_SYMBOL="${GAUDI_CHAR_SYMBOL=">>"}"
GAUDI_CHAR_COLOR_SUCCESS="${GAUDI_CHAR_COLOR_SUCCESS="\\[\${GREEN}\\]"}"
GAUDI_CHAR_COLOR_FAILURE="${GAUDI_CHAR_COLOR_FAILURE="\\[\${RED}\\]"}"
GAUDI_CHAR_COLOR_CLEAR="${GAUDI_CHAR_COLOR_CLEAR="\\[\${NC}\\]"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Paint $PROMPT_SYMBOL in red if previous command was fail and paint in green if everything was OK
gaudi_char() {
  local 'color'
  
  if [[ $RETVAL == 0 ]]; then
    color="$GAUDI_CHAR_COLOR_SUCCESS"
  else
    color="$GAUDI_CHAR_COLOR_FAILURE"
  fi

  printf "%b%b%b%b%b" "$GAUDI_CHAR_PREFIX" "$color" "$GAUDI_CHAR_SYMBOL" "$GAUDI_CHAR_COLOR_CLEAR" "$GAUDI_CHAR_SUFFIX"

}