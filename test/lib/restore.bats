#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	load_gaudi_libs log gaudi-bash
}

@test "gaudi-bash core: _gaudi-bash-restore should reject invalid backup entries" {

	cd "$GAUDI_BASH"
	./setup.sh --silent

	mkdir -p "$GAUDI_BASH/tmp"

	# Write a backup file with a mix of valid and invalid entries
	cat > "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup" << 'BACKUP'
gaudi-bash enable plugin base
echo INJECTED
gaudi-bash enable alias general
rm -rf /tmp/should-not-run
BACKUP

	# Disable everything first
	run gaudi-bash disable plugins all
	run gaudi-bash disable aliases all
	run gaudi-bash disable completion all

	# Restore should only process valid lines
	run _gaudi-bash-restore
	assert_success

	# Valid components should be restored
	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"

	# Invalid commands should NOT have created any side effects
	# (the "echo INJECTED" and "rm -rf" lines should have been skipped)
	refute_output --partial "INJECTED"
}

@test "gaudi-bash core: _gaudi-bash-restore should accept all valid component types" {

	cd "$GAUDI_BASH"
	./setup.sh --silent

	mkdir -p "$GAUDI_BASH/tmp"

	cat > "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup" << 'BACKUP'
gaudi-bash enable plugin base
gaudi-bash enable alias general
gaudi-bash enable completion gaudi-bash
BACKUP

	run gaudi-bash disable plugins all
	run gaudi-bash disable aliases all
	run gaudi-bash disable completion all

	run _gaudi-bash-restore
	assert_success

	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
}

@test "gaudi-bash core: _gaudi-bash-restore should fail gracefully with no backup file" {

	cd "$GAUDI_BASH"
	./setup.sh --silent

	rm -f "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run _gaudi-bash-restore
	assert_output --partial "No valid backup file found"
}
