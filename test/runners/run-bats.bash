#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2155

# Capture all the test files except for search.
if [[ $# -eq 0 ]]; then
	while IFS= read -r lib; do
		test_dirs+=("$lib")
	done < <(find "${GAUDI_TEST_DIRECTORY}" -type f -name '*.bats' ! -path '*search*' | sort)
else
	test_dirs=("$@")
fi

exec "$GAUDI_BATS" ${CI:+--tap} "${test_dirs[@]}"
