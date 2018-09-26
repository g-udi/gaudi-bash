#!/usr/bin/env bash
#
# pyenv
#
# pyenv lets you easily switch between multiple versions of Python.
# Link: https://github.com/pyenv/pyenv

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_PYENV_SHOW="${GAUDI_PYENV_SHOW=true}"
GAUDI_PYENV_PREFIX="${GAUDI_PYENV_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_PYENV_SUFFIX="${GAUDI_PYENV_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_PYENV_SYMBOL="${GAUDI_PYENV_SYMBOL="\\uf81f "}"
GAUDI_PYENV_COLOR="${GAUDI_PYENV_COLOR="$BLUE"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current version of pyenv Python, including system.
gaudi_pyenv() {
  [[ $GAUDI_PYENV_SHOW == false ]] && return

  # Show pyenv python version only for Python-specific folders
  [[ -f requirements.txt ]] || [[ -n $(find . -not -path '*/\.*' -maxdepth 1 -name "*.py") ]] || return

  local 'pyenv_version'

  if gaudi::exists pyenv; then
    pyenv_version=${$(pyenv version-name 2>/dev/null)//:/ }
  elif gaudi::exists virtualenv; then
    pyenv_version=`basename "$VIRTUAL_ENV"`
  elif gaudi::exists python; then
    pyenv_version=$(python -V 2>&1 | grep --color=never -oe "^Python\s*[0-9.]\+" | awk '{print $2}')
  else
    return
  fi
  
  gaudi::section \
    "$GAUDI_PYENV_COLOR" \
    "$GAUDI_PYENV_PREFIX" \
    "$GAUDI_PYENV_SYMBOL" \
    "$pyenv_version"
}
