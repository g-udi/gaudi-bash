#!/usr/bin/env bash
#
# Battery
#

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

# ------------------------------------------------------------------------------
# | GAUDI_BATTERY_SHOW | below threshold | above threshold | fully charged |
# |------------------------+-----------------+-----------------+---------------|
# | false                  | hidden          | hidden          | hidden        |
# | always                 | shown           | shown           | shown         |
# | true                   | shown           | hidden          | hidden        |
# | charged                | shown           | hidden          | shown         |
# ------------------------------------------------------------------------------

source "$GAUDI_ROOT/lib/battstat.bash"

GAUDI_BATTERY_THRESHOLD="${GAUDI_BATTERY_THRESHOLD=10}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show section only if either of follow is true
# - Always show is true
# - battery percentage is below the given limit (default: 10%)
# - Battery is fully charged
# Escape % for display since it's a special character in zsh prompt expansion
gaudi_battery() {
  
  [[ $GAUDI_BATTERY_SHOW == false ]] && return

  BATTERY=$(battstat -t $GAUDI_BATTERY_THRESHOLD {b} {i} {p})
  
  printf "%b%b" "$BATTERY" "$NC"
}
