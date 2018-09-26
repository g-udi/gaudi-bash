#
# System
#
# Get System stats e.g., CPU count, load, memory usage

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

source "$GAUDI_ROOT/lib/sysstat.bash"

GAUDI_SYSTEM_SHOW="${GAUDI_SYSTEM_SHOW=true}"
GAUDI_SYSTEM_PREFIX="${GAUDI_SYSTEM_PREFIX="took "}"
GAUDI_SYSTEM_SUFFIX="${GAUDI_SYSTEM_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_SYSTEM_CPU_SYMBOL="\\ufb19"
GAUDI_SYSTEM_MEMORY_SYMBOL="\\ue28c"
GAUDI_SYSTEM_HDD_SYMBOL="\\uf7c9"
GAUDI_SYSTEM_COLOR="${GAUDI_SYSTEM_COLOR="yellow"}"
GAUDI_SYSTEM_ELAPSED="${GAUDI_SYSTEM_ELAPSED=2}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

gaudi_system() {
  [[ $GAUDI_SYSTEM_SHOW == false ]] && return

    # echo "GAUDI_CPU_COUNT: $GAUDI_CPU_COUNT"
    # echo "GAUDI_CPU_LOAD: $GAUDI_CPU_LOAD"
}