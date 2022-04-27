#!/usr/bin/env bash

# Path to the bash it configuration
export GAUDI_BASH="{{GAUDI_BASH}}"

# Lock and Load a custom theme file
# Location /.gaudi_bash/themes/
export GAUDI_BASH_THEME="gaudi"

# Don't check mail when opening terminal.
unset MAILCHECK

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=true

# (Advanced): Uncomment this to make Bash-it reload itself automatically
# After enabling or disabling aliases, plugins, and completions.
export GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1

# Uncomment this to make Bash-it create alias reload [ref: https://github.com/Bash-it/gaudi-bash/issues/1120]
export GAUDI_BASH_RELOAD_LEGACY=0

# Uncomment this to show gaudi-bash debug logs
# export GAUDI_BASH_LOG_LEVEL=3

# Load Bash It
source $GAUDI_BASH/gaudi_bash.sh
