#!/usr/bin/env bash

export CLICOLOR=1
export LS_COLORS=Exfxcxdxbxegedabagacad

# colored grep
GREP_OPTIONS="--color=auto"
alias grep="grep $GREP_OPTIONS"

# Load the theme
if [[ $BASH_IT_THEME ]]; then
    source "$BASH_IT/themes/$BASH_IT_THEME/$BASH_IT_THEME.theme.bash"
fi

# Adding needed files for dircoloring
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
# Enabling dircolors coloring
eval `gdircolors -b ~/.dircolors`

# If we have grc enabled this is used to add coloring to various commands
source "`brew --prefix grc`/etc/grc.bashrc"
