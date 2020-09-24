#!/usr/bin/env bash

GAUDI_SCM_HG='hg'
GAUDI_SCM_HG_CHAR='\uf223'

# this functions returns absolute location of .hg directory if one exists
# It starts in the current directory and moves its way up until it hits /.
# If we get to / then no Mercurial repository was found.
# Example:
# - lets say we cd into ~/Projects/Foo/Bar
# - .hg is located in ~/Projects/Foo/.hg
# - get_hg_root starts at ~/Projects/Foo/Bar and sees that there is no .hg directory, so then it goes into ~/Projects/Foo
get_hg_root () {
    local CURRENT_DIR=$(pwd)

    while [ "$CURRENT_DIR" != "/" ]; do
        if [ -d "$CURRENT_DIR/.hg" ]; then
            echo "$CURRENT_DIR/.hg"
            return
        fi

        CURRENT_DIR=$(dirname $CURRENT_DIR)
    done
}

hg_prompt_vars () {
    if [[ -n $(hg status 2> /dev/null) ]]; then
      GAUDI_SCM_DIRTY=1
        GAUDI_SCM_STATE=${HG_THEME_PROMPT_DIRTY:-$GAUDI_SCM_THEME_PROMPT_DIRTY}
    else
      GAUDI_SCM_DIRTY=0
        GAUDI_SCM_STATE=${HG_THEME_PROMPT_CLEAN:-$GAUDI_SCM_THEME_PROMPT_CLEAN}
    fi
    GAUDI_SCM_PREFIX=${HG_THEME_PROMPT_PREFIX:-$GAUDI_SCM_THEME_PROMPT_PREFIX}
    GAUDI_SCM_SUFFIX=${HG_THEME_PROMPT_SUFFIX:-$GAUDI_SCM_THEME_PROMPT_SUFFIX}

    HG_ROOT=$(get_hg_root)

    if [ -f "$HG_ROOT/branch" ]; then
        # Mercurial holds it's current branch in .hg/branch file
        GAUDI_SCM_BRANCH=$(cat "$HG_ROOT/branch")
    else
        GAUDI_SCM_BRANCH=$(hg summary 2> /dev/null | grep branch: | awk '{print $2}')
    fi

    if [ -f "$HG_ROOT/dirstate" ]; then
        # Mercurial holds various information about the working directory in .hg/dirstate file. More on http://mercurial.selenic.com/wiki/DirState
        GAUDI_SCM_CHANGE=$(hexdump -n 10 -e '1/1 "%02x"' "$HG_ROOT/dirstate" | cut -c-12)
    else
        GAUDI_SCM_CHANGE=$(hg summary 2> /dev/null | grep parent: | awk '{print $2}')
    fi
}
