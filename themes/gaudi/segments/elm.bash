#!/usr/bin/env bash
#
# Elm
#
# A delightful language for reliable webapps
# http://elm-lang.org/

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_ELM_SHOW="${GAUDI_ELM_SHOW=true}"
GAUDI_ELM_PREFIX="${GAUDI_ELM_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_ELM_SUFFIX="${GAUDI_ELM_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_ELM_SYMBOL="${GAUDI_ELM_SYMBOL="\\ufa30"}"
GAUDI_ELM_COLOR="${GAUDI_ELM_COLOR="$BLUE"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Shows selected AWS-cli profile.
gaudi_elm() {
  [[ $GAUDI_ELM_SHOW == false ]] && return
   
   # Show ELM status only if elm is installed in the system
  gaudi::exists elm || return
   
   # Show ELM status only for folders w/ elm-package.json file
  [[ -f elm-package.json ]] || return

  local elm_version=$(elm --version)

   gaudi::section \
    "$GAUDI_ELM_COLOR" \
    "$GAUDI_ELM_PREFIX" \
    "$GAUDI_ELM_SYMBOL" \
    "$elm_version" \
    "$GAUDI_ELM_SUFFIX"
}