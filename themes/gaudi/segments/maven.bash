#!/usr/bin/env bash
#
# Maven
#

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_MAVEN_SHOW="${GAUDI_MAVEN_SHOW=true}"
GAUDI_MAVEN_PREFIX="${GAUDI_MAVEN_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_MAVEN_SUFFIX="${GAUDI_MAVEN_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_MAVEN_SYMBOL="${GAUDI_MAVEN_SYMBOL="𝑚"}"
GAUDI_MAVEN_COLOR="${GAUDI_MAVEN_COLOR="$YELLOW"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current Maven version
gaudi_maven () {
  [[ $GAUDI_MAVEN_SHOW == false ]] && return

  # Check if local ./mvnw first or system mvn is available
   gaudi::exists mvn || return

  # Check if maven project
  [[ -f pom.xml ]] || return

  local mvn_version=$(mvn --version 2>&1 | grep '^Apache Maven' | awk -F ' ' '{print $3}')

  gaudi::section \
    "$GAUDI_MAVEN_COLOR" \
    "$GAUDI_MAVEN_PREFIX" \
    "$GAUDI_MAVEN_SYMBOL" \
    "$mvn_version" \
    "$GAUDI_MAVEN_SUFFIX"
}
