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