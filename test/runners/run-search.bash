#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2155

printf "\n\n%s\n\n" "[[ Running the search tests in single threaded mode ]]"

# Collect the exit status of every run so a failing search test fails the whole run
test_files=()
while IFS= read -r test_file; do
	test_files+=("$test_file")
done < <(find "${GAUDI_TEST_DIRECTORY}" -name search.bats -type f | sort)

status=0
for test_file in "${test_files[@]}"; do
	"$GAUDI_BATS" ${CI:+--tap} "$test_file" || status=$?
done

exit "$status"
