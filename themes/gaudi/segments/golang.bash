#!/usr/bin/env bash
#
# Go
#
# Go is an open source programming language that makes it easy
# to build efficient software.
# Link: https://golang.org/

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_GOLANG_SHOW="${GAUDI_GOLANG_SHOW=true}"
GAUDI_GOLANG_PREFIX="${GAUDI_GOLANG_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_GOLANG_SUFFIX="${GAUDI_GOLANG_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_GOLANG_SYMBOL="${GAUDI_GOLANG_SYMBOL="\\ue627"}"
GAUDI_GOLANG_COLOR="${GAUDI_GOLANG_COLOR="$CYAN"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

gaudi_golang () {
  [[ $GAUDI_GOLANG_SHOW == false ]] && return

  # If there are Go-specific files in current directory, or current directory is under the GOPATH
  [[ -d Godeps || -f glide.yaml || -f Gopkg.yml || -f Gopkg.lock ||
     ( $GOPATH && $PWD =~ $GOPATH ) ||
     -n $(find . -not -path '*/\.*' -maxdepth 1 -name "*.go")
  ]] || return

  gaudi::exists go || return

  local go_version=$(go version | awk '{print substr($3, 3)}' )

  gaudi::section \
    "$GAUDI_GOLANG_COLOR" \
    "$GAUDI_GOLANG_PREFIX" \
    "$GAUDI_GOLANG_SYMBOL" \
    "$go_version" \
    "$GAUDI_GOLANG_SUFFIX"

}
