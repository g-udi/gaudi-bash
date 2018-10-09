#!/usr/bin/env bash

cite about-plugin
about-plugin 'go environment variables & path configuration'

[ ! command -v go &>/dev/null ] && return

# Check if the directories for GOPATH are not there and create them
[ -d "$GOPATH" ] && mkdir -p "$GOPATH"

export GOROOT=${GOROOT:-$(go env | grep GOROOT | cut -d'"' -f2)}
pathmunge "${GOROOT}/bin"
export GOPATH=${GOPATH:-"$HOME/go"}
pathmunge "${GOPATH}/bin"
