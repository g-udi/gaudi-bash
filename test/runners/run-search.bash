#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2155

printf "\n\n%s\n\n" "[[ Running the search tests in single threaded mode ]]"

overall_status=0

search_tests=()
while IFS= read -r search_test; do
	search_tests+=("$search_test")
done < <(find "${GAUDI_TEST_DIRECTORY}" -type f -name 'search.bats' | sort)

for search_test in "${search_tests[@]}"; do
	"$GAUDI_BATS" "$search_test" || overall_status=$?
done

exit "${overall_status}"
