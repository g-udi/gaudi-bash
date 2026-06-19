#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2155

# Capture all the test files by searching the lib folder for .bats files except for search
if [[ -z "$1" ]]; then
	test_dirs=()
	while IFS= read -r lib; do
		[[ "$lib" == *search.bats ]] && continue
		test_dirs+=("$lib")
	done < <(find "${GAUDI_TEST_DIRECTORY}" -name '*.bats' -type f | sort)
else
	test_dirs=("$1")
fi

exec "$GAUDI_BATS" ${CI:+--tap} "${test_dirs[@]}"
