#!/usr/bin/env bash
#
# Java
#
# Java is a general-purpose computer-programming language that is concurrent, class-based, object-oriented, and specifically designed to have as few implementation dependencies as possible
# Link: https://www.java.com/

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_JAVA_SHOW="${GAUDI_JAVA_SHOW=true}"
GAUDI_JAVA_PREFIX="${GAUDI_JAVA_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_JAVA_SUFFIX="${GAUDI_JAVA_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_JAVA_SYMBOL="${GAUDI_JAVA_SYMBOL="\\ue256"}"
GAUDI_JAVA_COLOR="${GAUDI_JAVA_COLOR="$ORANGE"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current version of java
gaudi_java() {
  [[ $GAUDI_JAVA_SHOW == false ]] && return

	# Show only if .java or .jar exist in current directory
  [[ -f pom.xml || -f build.gradle || -f build.gradle.kts ||
	   -n $(find . -not -path '*/\.*' -maxdepth 1 -name "*.java") ||
	   -n $(find . -not -path '*/\.*' -maxdepth 1 -name "*.jar")
	]] || return

	if gaudi::exists java; then
			_java=java
	elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
			_java="$JAVA_HOME/bin/java"
	fi

	if [[ "$_java" ]]; then
			java_version=$("$_java" -version 2>&1 | awk -F '"' '/version/ {print $2}' | cut -f1 -d"_")
	else 
		return
	fi

  gaudi::section \
    "$GAUDI_JAVA_COLOR" \
    "$GAUDI_JAVA_PREFIX" \
    "$GAUDI_JAVA_SYMBOL" \
    "$java_version" \
    "$GAUDI_JAVA_SUFFIX"
}
