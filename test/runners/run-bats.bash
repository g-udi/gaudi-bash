#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2155

# Capture all the test files by searching the lib folder for .bats files except for search
if [[ -z "$1" ]]; then
	shopt -s globstar
	for lib in "${GAUDI_TEST_DIRECTORY}"/**/doctor.bats; do
		[[ ! "$lib" =~ "search" ]] && test_dirs+=("$lib")
	done
else
	test_dirs=("$1")
fi

	exec "$GAUDI_BATS" ${CI:+--tap} "${test_dirs[@]}"
