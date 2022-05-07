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

# Capture all the test files by searching the lib folder for .bats files except for search
if [[ -z "$1" ]]; then
	shopt -s globstar
	for lib in "${test_directory}"/**/*.bats; do
		[[ ! "$lib" =~ "search" ]] && test_dirs+=("$lib")
	done
else
	test_dirs=("$1")
fi

# Make sure that the `parallel` command is installed,
# AND that it is the GNU version of `parallel`.
# If that is the case, try to guess the number of CPU cores,
# so we can run `bats` in parallel processing mode, which is a lot faster.
if command -v parallel &> /dev/null \
	&& parallel -V &> /dev/null \
	&& { parallel -V 2> /dev/null | grep -q '^GNU\>'; }; then
	printf "\n\n%s\n\n" "[[ Parallel Mode Enabled ✓ ]]"
	# Expect to run at least on a dual-core CPU; slightly degraded performance
	# shouldn't matter otherwise.
	declare -i -r test_jobs_default=1
	declare -i -r test_jobs_effective="$(
		if [ "${TEST_JOBS:-detect}" = "detect" ] \
			&& command -v nproc &> /dev/null; then
			nproc
		elif [ -n "${TEST_JOBS}" ] \
			&& [ "${TEST_JOBS}" != "detect" ]; then
			echo "${TEST_JOBS}"
		else
			echo ${test_jobs_default}
		fi
	)"
	exec "$bats_executable" ${CI:+--tap} --jobs "${test_jobs_effective}" \
		"${test_dirs[@]}"
else
	printf "\n\n%s\n\n" "[[ Single Mode Enabled ✓ ]]"
	exec "$bats_executable" ${CI:+--tap} "${test_dirs[@]}"
fi