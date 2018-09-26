#!/usr/bin/env bash

# colored ls
export CLICOLOR=1
export LSCOLORS='Gxfxcxdxdxegedabagacad'

# colored grep
GREP_OPTIONS="--color=auto"
alias grep="grep $GREP_OPTIONS"


if [[ -z "$CUSTOM_THEME_DIR" ]]; then
    CUSTOM_THEME_DIR="${BASH_IT_CUSTOM:=${BASH_IT}/custom}/themes"
fi

# Load the theme
if [[ $BASH_IT_THEME ]]; then
    if [[ -f $BASH_IT_THEME ]]; then
        source $BASH_IT_THEME
    elif [[ -f "$CUSTOM_THEME_DIR/$BASH_IT_THEME/$BASH_IT_THEME.theme.bash" ]]; then
        source "$CUSTOM_THEME_DIR/$BASH_IT_THEME/$BASH_IT_THEME.theme.bash"
    else
        source "$BASH_IT/themes/$BASH_IT_THEME/$BASH_IT_THEME.theme.bash"
    fi
fi

# Adding needed files for dircoloring
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
# Enabling dircolors coloring
# eval `gdircolors -b ~/.dircolors`

# If we have grc enabled this is used to add coloring to various commands
source "/usr/local/etc/grc.bashrc"
