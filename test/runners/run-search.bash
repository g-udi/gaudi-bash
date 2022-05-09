#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2155

printf "\n\n%s\n\n" "[[ Running the search tests in single threaded mode ]]"
find "${GAUDI_TEST_DIRECTORY}"/**/search.bats -exec "$GAUDI_BATS" {} \;
