#!/usr/bin/env bash
#
# Gradle
#
# Accelerate developer productivity. Gradle helps teams build, automate and deliver better software, faster.
# https://gradle.org/

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_GRADLE_SHOW="${GAUDI_GRADLE_SHOW=true}"
GAUDI_GRADLE_PREFIX="${GAUDI_GRADLE_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_GRADLE_SUFFIX="${GAUDI_GRADLE_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_GRADLE_SYMBOL="${GAUDI_GRADLE_SYMBOL="\\ufcc4"}"
GAUDI_GRADLE_COLOR="${GAUDI_GRADLE_COLOR=""}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Shows selected AWS-cli profile.
gaudi_gradle() {
  [[ $GAUDI_GRADLE_SHOW == false ]] && return
  
  # Check if local ./gradlew first or system gradle is available
  gaudi::exists gradle || return
  
  # Check if gradle project
  [[ -f build.gradle || -f build.gradle.kts ]] || return

  local gradle_version=$(gradle --version 2>&1 | grep '^Gradle' | awk -F ' ' '{print $2}')
  
  gaudi::section \
    "$GAUDI_GRADLE_COLOR" \
    "$GAUDI_GRADLE_PREFIX" \
    "$GAUDI_GRADLE_SYMBOL" \
    "v.$gradle_version" \
    "$GAUDI_GRADLE_SUFFIX"
}

