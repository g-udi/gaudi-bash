#!/usr/bin/env bash

GAUDI_SCM_SVN='svn'
GAUDI_SCM_SVN_CHAR='⑆'

function svn_prompt_vars {
  if [[ -n $(svn status 2> /dev/null) ]]; then
    GAUDI_SCM_DIRTY=1
    GAUDI_SCM_STATE=${SVN_THEME_PROMPT_DIRTY:-$GAUDI_SCM_THEME_PROMPT_DIRTY}
  else
    GAUDI_SCM_DIRTY=0
    GAUDI_SCM_STATE=${SVN_THEME_PROMPT_CLEAN:-$GAUDI_SCM_THEME_PROMPT_CLEAN}
  fi
  GAUDI_SCM_PREFIX=${SVN_THEME_PROMPT_PREFIX:-$GAUDI_SCM_THEME_PROMPT_PREFIX}
  GAUDI_SCM_SUFFIX=${SVN_THEME_PROMPT_SUFFIX:-$GAUDI_SCM_THEME_PROMPT_SUFFIX}
  GAUDI_SCM_BRANCH=$(svn info 2> /dev/null | awk -F/ '/^URL:/ { for (i=0; i<=NF; i++) { if ($i == "branches" || $i == "tags" ) { print $(i+1); break }; if ($i == "trunk") { print $i; break } } }') || return
  GAUDI_SCM_CHANGE=$(svn info 2> /dev/null | sed -ne 's#^Revision: ##p' )
}