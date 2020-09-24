#!/usr/bin/env bash
#
# Vagrant
#
# Vagrant enables users to create and configure lightweight, reproducible, and portable development environments.
# Link: https://www.vagrantup.com

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_VAGRANT_SHOW="${GAUDI_VAGRANT_SHOW=true}"
GAUDI_VAGRANT_PREFIX="${GAUDI_VAGRANT_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_VAGRANT_SUFFIX="${GAUDI_VAGRANT_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_VAGRANT_SYMBOL="${GAUDI_VAGRANT_SYMBOL="\\ue62b"}"
GAUDI_VAGRANT_COLOR="${GAUDI_VAGRANT_COLOR="$CYAN"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current Vagrant status
gaudi_vagrant () {
  [[ $GAUDI_VAGRANT_SHOW == false ]] && return

  gaudi::exists vagrant || return

  # Show Vagrant status only for Vagrant-specific folders
  [[ -f Vagrantfile || (-n $VAGRANT_VAGRANTFILE && -f ${VAGRANT_VAGRANTFILE}) ]] || return

  if gaudi::exists jq || 0; then
    local vagrant_status=$(cat "$HOME/.vagrant.d/data/machine-index/index" |
        jq -r --arg dir "$PWD" '.machines[] | select(.vagrantfile_path == $dir).state')
  else
    local vagrant_status=$(cat ${HOME}/.vagrant.d/data/machine-index/index | python -c 'import sys, os, json;
        json_file = json.load(sys.stdin)["machines"]
        for box in json_file:
        if (json_file[box]["vagrantfile_path"] == os.getcwd()):
            print (json_file[box]["state"])
            break;
        ')
  fi

  [[ -n ${vagrant_status} ]] || return

  gaudi::section \
    "$GAUDI_VAGRANT_COLOR" \
    "$GAUDI_VAGRANT_PREFIX" \
    "$GAUDI_VAGRANT_SYMBOL" \
    "$vagrant_status" \
    "$GAUDI_VAGRANT_SUFFIX"
}
