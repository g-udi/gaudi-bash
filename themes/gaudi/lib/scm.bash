#!/usr/bin/env bash

source "$BASH_IT/themes/gaudi/lib/helpers/git.helpers.bash"
source "$BASH_IT/themes/gaudi/lib/helpers/hg.helpers.bash"
source "$BASH_IT/themes/gaudi/lib/helpers/p4.helpers.bash"
source "$BASH_IT/themes/gaudi/lib/helpers/svn.helpers.bash"

SCM_CHECK=${SCM_CHECK:=true}

GAUDI_SCM_THEME_PROMPT_DIRTY=' ✕'
GAUDI_SCM_THEME_PROMPT_CLEAN=' ✓'
GAUDI_SCM_THEME_BRANCH_PREFIX=''
GAUDI_SCM_THEME_TAG_PREFIX='tag:'
GAUDI_SCM_THEME_DETACHED_PREFIX='detached:'
GAUDI_SCM_THEME_BRANCH_TRACK_PREFIX=' → '
GAUDI_SCM_THEME_BRANCH_GONE_PREFIX=' ⇢ '
GAUDI_SCM_THEME_CHAR_PREFIX=''
GAUDI_SCM_THEME_CHAR_SUFFIX=''
GAUDI_SCM_NONE='NONE'
GAUDI_SCM_NONE_CHAR='○'

function scm {
  if [[ "$SCM_CHECK" = false ]]; then SCM=$GAUDI_SCM_NONE
  elif [[ -f .git/HEAD ]] && which git &> /dev/null; then SCM=$GAUDI_SCM_GIT
  elif which git &> /dev/null && [[ -n "$(git rev-parse --is-inside-work-tree 2> /dev/null)" ]]; then SCM=$GAUDI_SCM_GIT
  elif which p4 &> /dev/null && [[ -n "$(p4 set P4CLIENT 2> /dev/null)" ]]; then SCM=$GAUDI_SCM_P4
  elif [[ -d .hg ]] && which hg &> /dev/null; then SCM=$GAUDI_SCM_HG
  elif which hg &> /dev/null && [[ -n "$(hg root 2> /dev/null)" ]]; then SCM=$GAUDI_SCM_HG
  elif [[ -d .svn ]] && which svn &> /dev/null; then SCM=$GAUDI_SCM_SVN
  else SCM=$GAUDI_SCM_NONE
  fi
}

function scm_prompt_char {
  if [[ -z $SCM ]]; then scm; fi
  if [[ $SCM == $GAUDI_SCM_GIT ]]; then GAUDI_SCM_CHAR=$GAUDI_SCM_GIT_CHAR
  elif [[ $SCM == $GAUDI_SCM_P4 ]]; then GAUDI_SCM_CHAR=$GAUDI_SCM_P4_CHAR
  elif [[ $SCM == $GAUDI_SCM_HG ]]; then GAUDI_SCM_CHAR=$GAUDI_SCM_HG_CHAR
  elif [[ $SCM == $GAUDI_SCM_SVN ]]; then GAUDI_SCM_CHAR=$GAUDI_SCM_SVN_CHAR
  else GAUDI_SCM_CHAR=$GAUDI_SCM_NONE_CHAR
  fi
}

function scm_prompt_vars {
  scm
  scm_prompt_char
  GAUDI_SCM_DIRTY=0
  GAUDI_SCM_STATE=''
  [[ $SCM == $GAUDI_SCM_GIT ]] && git_prompt_vars && return
  [[ $SCM == $GAUDI_SCM_P4 ]] && p4_prompt_vars && return
  [[ $SCM == $GAUDI_SCM_HG ]] && hg_prompt_vars && return
  [[ $SCM == $GAUDI_SCM_SVN ]] && svn_prompt_vars && return
}

function scm_prompt_info {
  scm
  scm_prompt_char
  scm_prompt_info_common
}

function scm_prompt_char_info {
  scm_prompt_char
  echo -ne "${GAUDI_SCM_THEME_CHAR_PREFIX}${GAUDI_SCM_CHAR}${GAUDI_SCM_THEME_CHAR_SUFFIX}"
  scm_prompt_info_common
}

function scm_prompt_info_common {
  GAUDI_SCM_DIRTY=0
  GAUDI_SCM_STATE=''

  if [[ ${SCM} == ${GAUDI_SCM_GIT} ]]; then
    if [[ ${GAUDI_SCM_GIT_SHOW_MINIMAL_INFO} == true ]]; then
      # user requests minimal git status information
      git_prompt_minimal_info
    else
      # more detailed git status
      git_prompt_info
    fi
    return
  fi

  # TODO: consider adding minimal status information for hg and svn
  [[ ${SCM} == ${GAUDI_SCM_P4} ]] && p4_prompt_info && return
  [[ ${SCM} == ${GAUDI_SCM_HG} ]] && hg_prompt_info && return
  [[ ${SCM} == ${GAUDI_SCM_SVN} ]] && svn_prompt_info && return
}

# backwards-compatibility
function git_prompt_info {
  _git-hide-status && return
  git_prompt_vars
  echo -e "${GAUDI_SCM_BRANCH}${GAUDI_SCM_STATE}"
}

function p4_prompt_info() {
  p4_prompt_vars
  echo -e "${GAUDI_SCM_BRANCH}:${GAUDI_SCM_CHANGE}${GAUDI_SCM_STATE}"
}

function svn_prompt_info {
  svn_prompt_vars
  echo -e "${GAUDI_SCM_BRANCH}${GAUDI_SCM_STATE}"
}

function hg_prompt_info() {
  hg_prompt_vars
  echo -e "${GAUDI_SCM_BRANCH}:${GAUDI_SCM_CHANGE#*:}${GAUDI_SCM_STATE}"
}

function scm_char {
  scm_prompt_char
  echo -e "${GAUDI_SCM_THEME_CHAR_PREFIX}${GAUDI_SCM_CHAR}${GAUDI_SCM_THEME_CHAR_SUFFIX}"
}