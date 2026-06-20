#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC1090,1091

: "${GAUDI_BASH_ORIGIN:="$GAUDI_BASH"}"

source "${GAUDI_BASH_ORIGIN}/bin/composure/composure.sh"

# Components may include load-order metadata such as `priority "325"` at
# top-level. Composure does not define that keyword by default, so make it a
# no-op metadata function before any enabled component is sourced.
cite priority
