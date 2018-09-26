#!/usr/bin/env bash


# Reset
export NC=$(tput sgr0)       # Text Reset

# Regular Colors
export BLACK=$(tput setaf 0)        # Black
export RED=$(tput setaf 1)          # Red
export GREEN=$(tput setaf 2)        # Green
export YELLOW=$(tput setaf 3)       # Yellow
export BLUE=$(tput setaf 4)         # Blue
export MAGENTA=$(tput setaf 165)    # magenta
export CYAN=$(tput setaf 6)         # Cyan
export WHITE=$(tput setaf 15)       # White
export ORANGE=$(tput setaf 202)     # Orange

# Background
export BACKGROUND_BLACK=$(tput setab 0)        # Black
export BACKGROUND_RED=$(tput setab 1)          # Red
export BACKGROUND_GREEN=$(tput setab 2)        # Green
export BACKGROUND_YELLOW=$(tput setab 3)       # Yellow
export BACKGROUND_BLUE=$(tput setab 4)         # Blue
export BACKGROUND_MAGENTA=$(tput setab 5)      # magenta
export BACKGROUND_CYAN=$(tput setab 6)         # Cyan
export BACKGROUND_WHITE=$(tput setab 15)       # White
export BACKGROUND_ORANGE=$(tput setab 202)     # Orange


# # Reset
# export NC="\\[\\033[0m\\]"       # Text Reset

# # Regular Colors
# export BLACK="\\[\\033[0;30m\\]"       # Black
# export RED="\\[\\033[0;31m\\]"         # Red
# export GREEN="\\[\\033[0;32m\\]"       # Green
# export YELLOW="\\[\\033[0;33m\\]"      # Yellow
# export BLUE="\\[\\033[0;34m\\]"        # Blue
# export MAGENTA="\\[\\033[0;35m\\]"     # magenta
# export CYAN="\\[\\033[0;36m\\]"        # Cyan
# export WHITE="\\[\\033[0;37m\\]"       # White
# export ORANGE="\\[\\033[38;5;202m\\]"  # Orange

# # Background
# export BACKGROUND_BLACK="\\[\\033[40m\\]"           # Black
# export BACKGROUND_RED="\\[\\033[41m\\]"             # Red
# export BACKGROUND_GREEN="\\[\\033[42m\\]"           # Green
# export BACKGROUND_YELLOW="\\[\\033[43m\\]"          # Yellow
# export BACKGROUND_BLUE="\\[\\033[44m\\]"            # Blue
# export BACKGROUND_MAGENTA="\\[\\033[45m\\]"         # magenta
# export BACKGROUND_CYAN="\\[\\033[46m\\]"            # Cyan
# export BACKGROUND_WHITE="\\[\\033[47m\\]"           # White
# export BACKGROUND_ORANGE="\\[\\033[48;5;202m\\]"    # Orange