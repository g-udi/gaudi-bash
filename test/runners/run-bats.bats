#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	# Stub the bats binary so the runner only reports what it would have run
	GAUDI_BATS_STUB="$BATS_TEST_TMPDIR/bats-stub"
	printf '%s\n' '#!/usr/bin/env bash' 'printf "%s\n" "$@"' > "$GAUDI_BATS_STUB"
	chmod +x "$GAUDI_BATS_STUB"
}

@test "gaudi-bash test runner: run-bats: should run only the files passed as arguments" {
	GAUDI_BATS="$GAUDI_BATS_STUB" run bash "$GAUDI_TEST_DIRECTORY/runners/run-bats.bash" "one.bats" "some dir/two.bats" < /dev/null
	assert_success
	assert_line "one.bats"
	assert_line "some dir/two.bats"
	refute_line --partial "help.bats"
}

@test "gaudi-bash test runner: run-bats: should run every test except search when no argument is passed" {
	GAUDI_BATS="$GAUDI_BATS_STUB" run bash "$GAUDI_TEST_DIRECTORY/runners/run-bats.bash" < /dev/null
	assert_success
	assert_line --partial "helpers/help.bats"
	refute_line --partial "search.bats"
}
