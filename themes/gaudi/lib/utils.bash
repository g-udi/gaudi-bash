#!/usr/bin/env bash

# ------------------------------------------------------------------------------
# UTILS
# Utils for common used actions
# ------------------------------------------------------------------------------

# Check if command exists in $PATH
# USAGE:
#   gaudi::exists <command>
gaudi::exists() {
  command -v $1 > /dev/null 2>&1
}

# Check if function is defined
# USAGE:
#   gaudi::defined <function>
gaudi::defined() {
  type -t "$1" &> /dev/null
}

# Draw prompt section
# USAGE:
#   gaudi::section <color> [prefix] [symbol] <content> [suffix]
gaudi::section() {
    
    local content color prefix symbol content suffix
    
    [[ -n $1 ]] && color="$1"    || color=""
    [[ -n $2 ]] && prefix="$2"   || prefix=""
    [[ -n $3 ]] && symbol="$3"   || symbol=""
    [[ -n $4 ]] && content="$4"  || content=""
    [[ -n $5 ]] && suffix="$5"   || suffix=""
    
    # gaudi::escape "$color$prefix$symbol $content$suffix${NC}"
    # printf "%b%b%b %b%b%b" "$color" "$prefix" "$symbol" "$content" "$suffix" "${NC}"

    [ $GAUDI_ENABLE_SYMBOLS == false ] && symbol="$GAUDI_SYMBOL_ALT " || symbol="$symbol "
    # Why are wrapping the cariables with "" you say ?
    # To pass a whole string containing whitespaces as a single argument, enclose it in double quotes
    # Like every other program, echo or printf interprets strings separated by whitespace as different arguments
    echo -n "$color"    # Print out any coloring needed for the section with order of <font_color><background_color>
    echo -n "$prefix"   # Print the prefix before the content .. default prefix is a space 
    echo -n "$symbol"   # Print the symbol if exists which is the icon to show before the segment
    echo -n "$content"  # Print the actual content to display in the prompt
    echo -n "$suffix"   # Print the suffix before the content .. default prefix is a space 
    echo -n "$NC"       # Reset the coloring set in the $color
}

# Kill all background gaudi::render_async that are running in the wrong context
# Wrong context is any directory (CWD) that is not the current directory
# USAGE:
#   gaudi::kill_outdated_asyncRender
gaudi::kill_outdated_asyncRender() {
  joblist="$(jobs | grep 'render_async.*wd:' | cut -d "[" -f2 | cut -d "]" -f1 | tr '\n' ' ')"
  IFS=' '
  for job in $joblist; do kill "%$job"; done
}

# Render a prompt section by getting the segments from the segments definitions array
# USAGE:
#   gaudi::render_prompt segments <array>
gaudi::render_prompt() {
  local _prompt=""
  declare -a _segments=("${!1}")
  if [[ -n "${_segments}" ]]; then
    for segment in ${_segments[@]}; do
      source "$GAUDI_ROOT/segments/$segment.bash"
      export GAUDI_SYMBOL_ALT=$segment
      local info="$(gaudi_$segment)"
      [[ -n "${info}" ]] && _prompt+="$info"
    done
    printf "%s" "$_prompt"
    unset GAUDI_SYMBOL_ALT
  fi;
}

# Append the prompt "safely"
# USAGE:
#   gaudi::safe_append_prompt_command <command>
gaudi::safe_append_prompt_command() {
    local prompt_re

    __check_precmd_conflict() {
        local f
        for f in "${precmd_functions[@]}"; do
            if [[ "${f}" == "${1}" ]]; then
                return 0
            fi
        done
        return 1
    }

    if [ "${__bp_imported}" == "defined" ]; then
        # We are using bash-preexec
        if ! __check_precmd_conflict "${1}" ; then
            precmd_functions+=("${1}")
        fi
    else
        # Set OS dependent exact match regular expression
        if [[ ${OSTYPE} == darwin* ]]; then
          # macOS
          prompt_re="[[:<:]]${1}[[:>:]]"
        else
          # Linux, FreeBSD, etc.
          prompt_re="\<${1}\>"
        fi

        if [[ ${PROMPT_COMMAND} =~ ${prompt_re} ]]; then
          return
        elif [[ -z ${PROMPT_COMMAND} ]]; then
          PROMPT_COMMAND="${1}"
        else
          PROMPT_COMMAND="${1};${PROMPT_COMMAND}"
        fi
    fi
}

# Display seconds in human readable fromat
# Based on http://stackoverflow.com/a/32164707/3859566
# USAGE:
#   spaceship::displaytime <seconds>
gaudi::displaytime() {
  local T=$1
  local D=$((T/60/60/24))
  local H=$((T/60/60%24))
  local M=$((T/60%60))
  local S=$((T%60))
  [[ $D > 0 ]] && printf '%dd ' $D
  [[ $H > 0 ]] && printf '%dh ' $H
  [[ $M > 0 ]] && printf '%dm ' $M
  printf '%ds' $S
}
