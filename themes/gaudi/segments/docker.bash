#!/usr/bin/env bash
#
# Docker
#
# Docker automates the repetitive tasks of setting up development environments
# Link: https://www.docker.com

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_DOCKER_SHOW="${GAUDI_DOCKER_SHOW=true}"
GAUDI_DOCKER_PREFIX="${GAUDI_DOCKER_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_DOCKER_SUFFIX="${GAUDI_DOCKER_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_DOCKER_SYMBOL="${GAUDI_DOCKER_SYMBOL="\\uf308"}"
GAUDI_DOCKER_COLOR="${GAUDI_DOCKER_COLOR="$GAUDI_CYAN"}"
GAUDI_DOCKER_VERBOSE="${GAUDI_DOCKER_VERBOSE=false}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current Docker version and connected machine
gaudi_docker () {
  [[ $GAUDI_DOCKER_SHOW == false ]] && return

  gaudi::exists docker || return

  # Better support for docker environment vars: https://docs.docker.com/compose/reference/envvars/
  local compose_exists=false
  if [[ -n "$COMPOSE_FILE" ]]; then
    # Use COMPOSE_PATH_SEPARATOR or colon as default
    local separator=${COMPOSE_PATH_SEPARATOR:-":"}

    # COMPOSE_FILE may have several filenames separated by colon, test all of them
    local filenames=("${(@ps/$separator/)COMPOSE_FILE}")

    for filename in $filenames; do
      if [[ ! -f $filename ]]; then
        compose_exists=false
        break
      fi
      compose_exists=true
    done

    # Must return if COMPOSE_FILE is present but invalid
    [[ "$compose_exists" == false ]] && return
  fi

  # Show Docker status only for Docker-specific folders
  [[ "$compose_exists" == true || -f Dockerfile || -f docker-compose.yml ||
     -n $(find . -not -path '*/\.*' -maxdepth 1 -name "*.Dockerfile")
  ]] || return

  # if docker daemon isn't running you'll get an error saying it can't connect
  local docker_version=$(docker version -f "{{.Server.Version}}" 2>/dev/null | cut -f1 -d"-")
  [[ -z $docker_version ]] && return

  if [[ -n $DOCKER_MACHINE_NAME ]]; then
    docker_version+=" via ($DOCKER_MACHINE_NAME)"
  fi

  gaudi::section \
    "$GAUDI_DOCKER_COLOR" \
    "$GAUDI_DOCKER_PREFIX" \
    "$GAUDI_DOCKER_SYMBOL" \
    "$docker_version" \
    "$GAUDI_DOCKER_SUFFIX"
}
