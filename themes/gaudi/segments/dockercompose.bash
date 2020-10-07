#!/usr/bin/env bash
#
# Docker Compose
#
# Compose is a tool for defining and running multi-container Docker applications.
# Link: https://docs.docker.com/compose/

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

# DOCKER COMPOSE
GAUDI_DOCKERCOMPOSE_SHOW="${GAUDI_DOCKERCOMPOSE_SHOW:=true}"
GAUDI_DOCKERCOMPOSE_SHOW_SYMBOLS="${GAUDI_DOCKERCOMPOSE_SHOW_SYMBOLS:=false}"
GAUDI_DOCKERCOMPOSE_PREFIX="${GAUDI_DOCKERCOMPOSE_PREFIX:=""}"
GAUDI_DOCKERCOMPOSE_SUFFIX="${GAUDI_DOCKERCOMPOSE_SUFFIX:=" "}"
GAUDI_DOCKERCOMPOSE_SYMBOL=""
GAUDI_DOCKERCOMPOSE_SYMBOL_UP="\\uf55c"
GAUDI_DOCKERCOMPOSE_SYMBOL_DOWN="\\uf544"
GAUDI_DOCKERCOMPOSE_TEXT_COLOR="${GAUDI_DOCKERCOMPOSE_TEXT_COLOR:="${WHITE}"}"
GAUDI_DOCKERCOMPOSE_TEXT_COLOR_UP="${GAUDI_DOCKERCOMPOSE_TEXT_COLOR_UP:="${WHITE}"}"
GAUDI_DOCKERCOMPOSE_TEXT_COLOR_DOWN="${GAUDI_DOCKERCOMPOSE_TEXT_COLOR_DOWN:="${WHITE}"}"
GAUDI_DOCKERCOMPOSE_COLOR="${GAUDI_DOCKERCOMPOSE_COLOR:="${BACKGROUND_GREEN}"}"
GAUDI_DOCKERCOMPOSE_DOWN_COLOR="${GAUDI_DOCKERCOMPOSE_DOWN_COLOR:="${BACKGROUND_RED}"}"
GAUDI_DOCKERCOMPOSE_PARTIAL_COLOR="${GAUDI_DOCKERCOMPOSE_PARTIAL_COLOR:="${BACKGROUND_ORANGE}"}"
# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current docker-compose status
gaudi_dockercompose () {
  [[ $GAUDI_DOCKERCOMPOSE_SHOW == false ]] && return

  # Show Docker-compose status when docker-compose file exists
  gaudi::exists docker-compose || return

  [[ -f docker-compose.yml ]] || return

	local dockercompose_status color

	GAUDI_DOCKERCOMPOSE_SYMBOL_MONGODB="\\ue7a4"
	GAUDI_DOCKERCOMPOSE_SYMBOL_REDIS="\\ue76d"
	GAUDI_DOCKERCOMPOSE_SYMBOL_ELASTICSEARCH="\\ue35d"

	dockercompose_details=$(docker-compose ps 2>/dev/null | tail -n+3 | while read line
		do
			CONTAINER_NAME=$(echo ${line:$(echo $line | awk 'match($0,"_"){print RSTART}')} | tr '[:lower:]' '[:upper:]' | cut -f1 -d"_")
			CONTAINER_LETTER=$(echo ${CONTAINER_NAME:0:1} | tr '[:lower:]' '[:upper:]')
			_CONTAINER_SYMBOL=$(echo "GAUDI_DOCKERCOMPOSE_SYMBOL_${CONTAINER_NAME}")

			if [[ -z ${!_CONTAINER_SYMBOL} || $GAUDI_DOCKERCOMPOSE_SHOW_SYMBOLS == false ]]; then
				CONTAINER_SYMBOL=$CONTAINER_LETTER
			else
				CONTAINER_SYMBOL=${!_CONTAINER_SYMBOL}
			fi

			if [[ $line == *"Up"* ]]; then
				((up_containers++))
				dockercompose_status_up+="$GAUDI_DOCKERCOMPOSE_SYMBOL_UP $CONTAINER_SYMBOL "
			else
				dockercompose_status_down+="$GAUDI_DOCKERCOMPOSE_SYMBOL_DOWN $CONTAINER_SYMBOL "
			fi
		echo -e "$up_containers|$dockercompose_status_up::$dockercompose_status_down"
	done | tail -1)

	_dockercompose_details="${dockercompose_details%%::*}"
	total_containers=$(docker-compose ps | tail -n +3 | wc -l)
	up_containers="${dockercompose_details%%|*}"
	dockercompose_status_up="${_dockercompose_details#*|}"
	dockercompose_status_down="${dockercompose_details#*::}"

	if [[ $up_containers == $total_containers ]]; then
		color=$GAUDI_DOCKERCOMPOSE_COLOR
	elif [[ -z $up_containers ]]; then
		color=$GAUDI_DOCKERCOMPOSE_DOWN_COLOR
	else
		color=$GAUDI_DOCKERCOMPOSE_PARTIAL_COLOR
	fi

	dockercompose_status="$GAUDI_DOCKERCOMPOSE_TEXT_COLOR_UP$dockercompose_status_up$GAUDI_DOCKERCOMPOSE_TEXT_COLOR_DOWN$dockercompose_status_down"

  gaudi::section \
    "$color" \
    "$GAUDI_DOCKERCOMPOSE_PREFIX" \
    "$GAUDI_DOCKERCOMPOSE_SYMBOL" \
    "$(echo -e -n "${GAUDI_DOCKERCOMPOSE_TEXT_COLOR}services: $dockercompose_status")" \
    "$GAUDI_DOCKERCOMPOSE_SUFFIX"
}
