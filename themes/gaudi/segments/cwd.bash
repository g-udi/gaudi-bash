#!/usr/bin/env bash
#
# Working directory
#
# Current directory. Return only three last items of path

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_CWD_SHOW="${GAUDI_CWD_SHOW=true}"
GAUDI_CWD_SHORTEN="${GAUDI_CWD_SHORTEN=true}"
GAUDI_CWD_PREFIX="${GAUDI_CWD_PREFIX=""}"
GAUDI_CWD_SUFFIX="${GAUDI_CWD_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_CWD_COLOR="${GAUDI_CWD_COLOR="$BACKGROUND_BLUE"}"
GAUDI_CWD_COLOR_LOCKED="${GAUDI_CWD_COLOR_LOCKED="$WHITE$BACKGROUND_RED"}"
GAUDI_CWD_SEPARATOR="${GAUDI_CWD_SEPARATOR=""}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Shows selected AWS-cli profile.
gaudi_cwd() {
  [[ $GAUDI_CWD_SHOW == false ]] && return
  
  [[ x"$whoami" != *'('* || x"$whoami" = *'(:'* || x"$whoami" = *'(tmux'* ]] && color=$GAUDI_CWD_COLOR
  [[ -w $PWD ]] && color=$GAUDI_CWD_COLOR || color=$GAUDI_CWD_COLOR_LOCKED
  
  reduce-path() {
    local path=${1-$PWD} target=${2-33} IFS=/
    [[ "$path" =~ ^$HOME(/|$) ]] && path="~${path#$HOME}"
    [[ ${#path} -le $target ]] && echo "$path" && return
    local order=$((i=0; for e in $path; do echo ${#e} $i; ((i++)); done) |
        head -n-1 | sort -rn | cut -d " " -f 2)
    local elements=($path)
    IFS=$'\n'
    for i in $order; do
        elements[i]=${elements[i]:0:1}
        IFS=/
        path="${elements[*]}"
        [[ ${#path} -le $target ]] && echo "$path" && return
    done
    echo "${path:0:target/2}~${path: -target/2}"
  }

  [ $GAUDI_CWD_SHORTEN == true ] && GAUDI_CWD=$(reduce-path) || GAUDI_CWD=$(pwd | sed "s|^${HOME}|~|")
  
  gaudi::section \
    "$color" \
    "$GAUDI_CWD_PREFIX" \
    "$GAUDI_CWD_SEPARATOR" \
    "$GAUDI_CWD" \
    "$GAUDI_CWD_SUFFIX"
}

