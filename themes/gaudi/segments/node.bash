#!/usr/bin/env bash
#
# Node.js
#
# Node.js is a JavaScript runtime built on Chrome's V8 JavaScript engine.
# Link: https://nodejs.org/

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_NODE_SHOW="${GAUDI_NODE_SHOW=true}"
GAUDI_NODE_PREFIX="${GAUDI_NODE_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_NODE_SUFFIX="${GAUDI_NODE_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_NODE_SYMBOL="${GAUDI_NODE_SYMBOL="\\ue74e"}"
GAUDI_NODE_DEFAULT_VERSION="${GAUDI_NODE_DEFAULT_VERSION=""}"
GAUDI_NODE_COLOR="${GAUDI_NODE_COLOR="$GAUDI_YELLOW"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current version of node, exception system.
gaudi_node () {

  shopt -s nullglob

  [[ $GAUDI_NODE_SHOW == false ]] && return

  # Show NODE status only for JS-specific folders
  [[ -f package.json || -d node_modules ||
     -n $(find . -not -path '*/\.*' -maxdepth 1 -name "*.js")
  ]] || return

  local 'node_version'

  if gaudi::exists nvm; then
    node_version=$(nvm current 2>/dev/null)
    [[ $node_version == "system" || $node_version == "node" ]] && return
  elif gaudi::exists nodenv; then
    node_version=$(nodenv version-name)
    [[ $node_version == "system" || $node_version == "node" ]] && return
  elif gaudi::exists node; then
    node_version=$(node -v 2>/dev/null)
  else
    return
  fi

  [[ $node_version == $GAUDI_NODE_DEFAULT_VERSION ]] && return

  gaudi::section \
    "$GAUDI_NODE_COLOR" \
    "$GAUDI_NODE_PREFIX" \
    "$GAUDI_NODE_SYMBOL" \
    "$node_version"\
    "$GAUDI_NODE_SUFFIX"
}
