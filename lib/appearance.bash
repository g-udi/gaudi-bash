#!/usr/bin/env bash

# Adding needed files for dircoloring
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

export CLICOLOR=1
export LS_COLORS=Exfxcxdxbxegedabagacad

# colored grep
export GREP_OPTIONS='--color=auto'
export GREP_COLOR='1;33'

# Load the theme
if [[ $BASH_IT_THEME ]]; then
    source "$BASH_IT/themes/$BASH_IT_THEME/$BASH_IT_THEME.theme.bash"
fi

# ls color catching functions
# Detect which `ls` flavor is in use
if ls --color > /dev/null 2>&1; then # GNU `ls`
	colorflag="--color"
else # OS X `ls`
	colorflag="-G"
fi

if [ $(uname) = "Linux" ]
then
  alias ls="ls --color=always"
fi

# Enabling dircolors coloring
eval `gdircolors -b ~/.dircolors`