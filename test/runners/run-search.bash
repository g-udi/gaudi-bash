#!/usr/bin/env bash
# shellcheck disable=SC2155

declare test_directory bats_executable

test_directory="$GAUDI_BASH/test"
bats_executable="${test_directory}/../bin/bats-core/bin/bats"

git submodule init && git submodule update

if [[ -z "${GAUDI_BASH}" ]]; then
	declare GAUDI_BASH
	GAUDI_BASH=$(cd "${test_directory}" && ${PWD})
	export GAUDI_BASH
fi

printf "\n\n%s\n\n" "[[ Running the search tests in single threaded mode ]]"
find "${test_directory}"/**/search.bats -exec "$bats_executable" {} \;