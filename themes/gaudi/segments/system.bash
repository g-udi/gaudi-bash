#
# System
#
# Get System stats e.g., CPU count, load, memory usage

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

source "$GAUDI_ROOT/lib/sysstat.bash"

GAUDI_SYSTEM_SHOW="${GAUDI_SYSTEM_SHOW=true}"
GAUDI_SYSTEM_PREFIX="${GAUDI_SYSTEM_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_SYSTEM_SUFFIX="${GAUDI_SYSTEM_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_SYSTEM_CPU_SYMBOL="\\ufb19"
GAUDI_SYSTEM_MEMORY_SYMBOL="\\ue28c"
GAUDI_SYSTEM_HDD_SYMBOL="\\uf7c9"
GAUDI_SYSTEM_CPU_COLOR="${GAUDI_SYSTEM_CPU_COLOR="$YELLOW"}"
GAUDI_SYSTEM_MEMORY_COLOR="${GAUDI_SYSTEM_MEMORY_COLOR="$MAGENTA"}"
GAUDI_SYSTEM_HDD_COLOR="${GAUDI_SYSTEM_HDD_COLOR="$CYAN"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

gaudi_system() {
  [[ $GAUDI_SYSTEM_SHOW == false ]] && return

  local system
  [[ -n $GAUDI_CPU_LOAD ]] && gaudi::section "$GAUDI_SYSTEM_PREFIX" "$GAUDI_SYSTEM_CPU_COLOR" "$GAUDI_SYSTEM_CPU_SYMBOL" "$GAUDI_CPU_LOAD%" "$GAUDI_SYSTEM_SUFFIX"
  [[ -n $GAUDI_MEMORY_FREE ]] && gaudi::section "$GAUDI_SYSTEM_PREFIX" "$GAUDI_SYSTEM_MEMORY_COLOR" "$GAUDI_SYSTEM_MEMORY_SYMBOL" ""$GAUDI_MEMORY_FREE"GB" "$GAUDI_SYSTEM_SUFFIX"
  [[ -n $GAUDI_HDD_USAGE ]] && gaudi::section "$GAUDI_SYSTEM_PREFIX" "$GAUDI_SYSTEM_HDD_COLOR" "$GAUDI_SYSTEM_HDD_SYMBOL" "$GAUDI_HDD_USAGE" "$GAUDI_SYSTEM_SUFFIX"

}