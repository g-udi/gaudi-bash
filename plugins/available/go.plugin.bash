#!/usr/bin/env bash

cite about-plugin
about-plugin 'go environment variables & path configuration'

[ ! command -v go &>/dev/null ] && return

export GOPATH="$HOME/Applications/Go"

export GOROOT=${GOROOT:-$(go env | grep GOROOT | cut -d'"' -f2)}
pathmunge "${GOROOT}/bin"
export GOPATH=${GOPATH:-"$HOME/go"}
pathmunge "${GOPATH}/bin"
