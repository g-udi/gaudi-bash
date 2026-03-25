#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

@test "gaudi-bash test runner: should return nonzero when a suite fails" {

	local fakebin="${BATS_TEST_TMPDIR}/fakebin"
	local runner_root="${BATS_TEST_TMPDIR}/runner-root"

	mkdir -p "$fakebin" "$runner_root/test/runners"

	cp "$GAUDI_BASH/test/run" "$runner_root/test/run"

	cat > "$runner_root/test/runners/run-bats.bash" << 'FAKE_BATS'
#!/bin/bash
exit 1
FAKE_BATS

	cat > "$runner_root/test/runners/run-search.bash" << 'FAKE_SEARCH'
#!/bin/bash
exit 0
FAKE_SEARCH

	cat > "$fakebin/git" << 'FAKE_GIT'
#!/bin/bash
exit 0
FAKE_GIT

	chmod +x \
		"$runner_root/test/run" \
		"$runner_root/test/runners/run-bats.bash" \
		"$runner_root/test/runners/run-search.bash" \
		"$fakebin/git"

	run env PATH="$fakebin:$PATH" /bin/bash "$runner_root/test/run"
	assert_failure
}
