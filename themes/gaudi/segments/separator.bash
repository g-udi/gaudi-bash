#!/usr/bin/env bash
#
# Line separator
#

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

GAUDI_PROMPT_SEPARATE_LINE="${GAUDI_PROMPT_SEPARATE_LINE=true}"
NEWLINE="\\n"

# Should it write prompt in two lines or not?
gaudi_separator () {

  [[ $GAUDI_PROMPT_SEPARATE_LINE == true ]] && echo -n "$NEWLINE"
}
