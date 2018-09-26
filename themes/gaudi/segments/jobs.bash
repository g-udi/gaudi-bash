#!/usr/bin/env bash
#
# Background jobs
#

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_JOBS_SHOW="${GAUDI_JOBS_SHOW=true}"
GAUDI_JOBS_PREFIX="${GAUDI_JOBS_PREFIX=" "}"
GAUDI_JOBS_SUFFIX="${GAUDI_JOBS_SUFFIX=" "}"
GAUDI_JOBS_SYMBOL="${GAUDI_JOBS_SYMBOL="\\uf013"}"
GAUDI_JOBS_COLOR="${GAUDI_JOBS_COLOR="$WHITE"}"
GAUDI_JOBS_AMOUNT_PREFIX="${GAUDI_JOBS_AMOUNT_PREFIX=""}"
GAUDI_JOBS_AMOUNT_SUFFIX="${GAUDI_JOBS_AMOUNT_SUFFIX=""}"
GAUDI_JOBS_AMOUNT_THRESHOLD="${GAUDI_JOBS_AMOUNT_THRESHOLD=1}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show icon if there's a working jobs in the background
gaudi_jobs() {
  [[ $GAUDI_JOBS_SHOW == false ]] && return

  local jobs_amount=$( jobs -r | awk '!/wd/' | wc -l | tr -d " ")

  [[ $jobs_amount -gt 0 ]] || return

  if [[ $jobs_amount -le $GAUDI_JOBS_AMOUNT_THRESHOLD ]]; then
    jobs_amount=''
    GAUDI_JOBS_AMOUNT_PREFIX=''
    GAUDI_JOBS_AMOUNT_SUFFIX=''
  fi

  gaudi::section \
    "$GAUDI_JOBS_COLOR" \
    "$GAUDI_JOBS_PREFIX" \
    "$GAUDI_JOBS_SYMBOL" \
    "$jobs_amount" \
    "$GAUDI_JOBS_SUFFIX"
}
