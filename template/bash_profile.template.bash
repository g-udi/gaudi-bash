#!/usr/bin/env bash

# >>> gaudi-bash >>>
# The lines between these two markers are managed by gaudi-bash: setup.sh adds them once and uninstall.sh removes them

# Path to the gaudi-bash installation
export GAUDI_BASH="{{GAUDI_BASH}}"

# Name of the theme to load, themes live in $GAUDI_BASH/components/themes/<name>/
export GAUDI_BASH_THEME="gaudi"

# Don't check mail when opening terminal.
unset MAILCHECK

# Set this to false to turn off version control status checking within the prompt for all themes
export SCM_CHECK=true

# Makes gaudi-bash reload itself automatically after enabling or disabling aliases, plugins, and completions
# Comment this out to reload by hand (gbash reload)
export GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1

# Uncomment this to show gaudi-bash debug logs
# export GAUDI_BASH_LOG_LEVEL=3

# Load gaudi-bash
source "$GAUDI_BASH/gaudi_bash.sh"
# <<< gaudi-bash <<<
