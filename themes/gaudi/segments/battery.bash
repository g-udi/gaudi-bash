#!/usr/bin/env bash
#
# Battery
#

source "$GAUDI_ROOT/lib/battstat.bash"

GAUDI_BATTERY_SHOW="${GAUDI_BATTERY_SHOW=true}"
GAUDI_BATTERY_THRESHOLD="${GAUDI_BATTERY_THRESHOLD=10}"
GAUDI_BATTERY_PREFIX="${GAUDI_BATTERY_PREFIX=""}"
GAUDI_BATTERY_SUFFIX="${GAUDI_BATTERY_SUFFIX=""}"
GAUDI_BATTERY_SYMBOL_CHARGING="${GAUDI_BATTERY_SYMBOL_CHARGING="\\uf240"}"
GAUDI_BATTERY_SYMBOL_DISCHARGING="${GAUDI_BATTERY_SYMBOL_DISCHARGING="\\uf241"}"

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

  BATTERY="$(battstat -t $GAUDI_BATTERY_THRESHOLD -d $GAUDI_BATTERY_SYMBOL_DISCHARGING -c $GAUDI_BATTERY_SYMBOL_CHARGING {b} {i} {p})"
  
  gaudi::section \
    "" \
    "$GAUDI_EXEC_TIME_PREFIX" \
    "" \
    "$BATTERY" \
    "$GAUDI_EXEC_TIME_SUFFIX"
}
