#!/usr/bin/env bash

# Path to the bash it configuration
export BASH_IT="{{BASH_IT}}"

# Lock and Load a custom theme file
# Location /.bash_it/themes/
export BASH_IT_THEME="gaudi"

# Don't check mail when opening terminal.
unset MAILCHECK

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=true

# (Advanced): Uncomment this to make Bash-it reload itself automatically
# After enabling or disabling aliases, plugins, and completions.
export BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1

# Uncomment this to make Bash-it create alias reload [ref: https://github.com/Bash-it/bash-it/issues/1120]
export BASH_IT_RELOAD_LEGACY=0

# Uncomment this to show bash-it debug logs
# export BASH_IT_LOG_LEVEL=3

# Load Bash It
source $BASH_IT/bash_it.sh
