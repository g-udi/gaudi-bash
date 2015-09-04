#!/usr/bin/env bash

# Bosco completion

if command -v bosco &>/dev/null
then
  eval "$(bosco --completion=bash)"
fi