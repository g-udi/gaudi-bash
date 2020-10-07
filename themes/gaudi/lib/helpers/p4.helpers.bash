#!/usr/bin/env bash

GAUDI_SCM_P4='p4'
GAUDI_SCM_P4_CHAR='⌛'
GAUDI_SCM_P4_CHANGES_CHAR='C:'
GAUDI_SCM_P4_DEFAULT_CHAR='D:'
GAUDI_SCM_P4_OPENED_CHAR='O:'

_p4-opened () {
  timeout 2.0s p4 opened -s 2> /dev/null
}

_p4-opened-counts () {
  # Return the following counts seperated by tabs:
  #  - count of opened files
  #  - count of pending changesets (other than defaults)
  #  - count of files in the default changeset
  #  - count of opened files in add mode
  #  - count of opened files in edit mode
  #  - count of opened files in delete mode
  _p4-opened | awk '
  BEGIN {
    opened=0;
    type_array["edit"]=0;
    type_array["add"]=0;
    type_array["delete"]=0;
    change_array["change"]=0;
  }
  {
    # p4 opened prints one file per line, and all lines begin with "//"
    # Here is an examples:
    #
    #   $ p4 opened
    #   //depot/some/file.py#4 - edit change 716431 (text)
    #   //depot/another/file.py - edit default change (text)
    #   //now/add/a/newfile.sh -  add change 435645 (text+k)
    #
    #
    if ($1 ~ /^\/\//) {
        opened += 1
        change_array[$5] += 1
        type_array[$3] += 1
    }
  }
  END {
    default_changes=change_array["change"];
    non_default_changes=length(change_array) - 1;
    print opened "\t" non_default_changes "\t" default_changes "\t" type_array["add"] "\t" type_array["edit"] "\t" type_array["delete"]
  }
'
}

p4_prompt_vars () {
  IFS=$'\t' read -r \
     opened_count non_default_changes default_count \
     add_file_count edit_file_count delete_file_count \
     <<< "$(_p4-opened-counts)"
  if [[ "${opened_count}" -gt 0 ]]; then
    GAUDI_SCM_DIRTY=1
    GAUDI_SCM_STATE=${GAUDI_SCM_THEME_PROMPT_DIRTY}
    [[ "${opened_count}" -gt 0 ]] && GAUDI_SCM_BRANCH+=" ${GAUDI_SCM_P4_OPENED_CHAR}${opened_count}"
    [[ "${non_default_changes}" -gt 0 ]] && GAUDI_SCM_BRANCH+=" ${GAUDI_SCM_P4_CHANGES_CHAR}${non_default_changes}"
    [[ "${default_count}" -gt 0 ]] && GAUDI_SCM_BRANCH+=" ${GAUDI_SCM_P4_DEFAULT_CHAR}${default_count}"
  else
    GAUDI_SCM_DIRTY=0
    GAUDI_SCM_STATE=${GAUDI_SCM_THEME_PROMPT_DIRTY}
  fi

  GAUDI_SCM_PREFIX=${P4_THEME_PROMPT_PREFIX:-$GAUDI_SCM_THEME_PROMPT_PREFIX}
  GAUDI_SCM_SUFFIX=${P4_THEME_PROMPT_SUFFIX:-$GAUDI_SCM_THEME_PROMPT_SUFFIX}
}
