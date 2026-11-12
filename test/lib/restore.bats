#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	load_gaudi_libs log gaudi-bash
}

@test "gaudi-bash core: _gaudi-bash-restore should reject invalid backup entries" {

	cd "$GAUDI_BASH"
	"$GAUDI_BASH/setup.sh" --silent

	mkdir -p "$GAUDI_BASH/tmp"

	# Write a backup file with a mix of valid and invalid entries
	cat > "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup" << 'BACKUP'
gbash enable plugin base
echo INJECTED
gbash enable alias general
rm -rf /tmp/should-not-run
BACKUP

	# Disable everything first
	run gbash disable plugins all
	run gbash disable aliases all
	run gbash disable completion all

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
	"$GAUDI_BASH/setup.sh" --silent

	mkdir -p "$GAUDI_BASH/tmp"

	cat > "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup" << 'BACKUP'
gbash enable plugin base
gbash enable alias general
gbash enable completion gaudi-bash
BACKUP

	run gbash disable plugins all
	run gbash disable aliases all
	run gbash disable completion all

	run _gaudi-bash-restore
	assert_success

	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
}

@test "gaudi-bash core: _gaudi-bash-restore should accept backup entries written with the legacy gaudi-bash prefix" {

	cd "$GAUDI_BASH"
	"$GAUDI_BASH/setup.sh" --silent

	mkdir -p "$GAUDI_BASH/tmp"

	cat > "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup" << 'BACKUP'
gaudi-bash enable plugin base
gbash enable alias general
BACKUP

	run gbash disable plugins all
	run gbash disable aliases all

	run _gaudi-bash-restore
	assert_success

	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
}

@test "gaudi-bash core: _gaudi-bash-restore should fail gracefully with no backup file" {

	cd "$GAUDI_BASH"
	"$GAUDI_BASH/setup.sh" --silent

	rm -f "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run _gaudi-bash-restore
	assert_failure
	assert_output --partial "No valid backup file found"
}

@test "gaudi-bash core: _gaudi-bash-restore should prefer the backup profile over the backup file of older versions" {

	mkdir -p "$GAUDI_BASH/tmp" "$GAUDI_BASH/profiles"
	printf "%s\n" "gbash enable plugin base" > "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"
	printf "%s\n" "alias general" "echo INJECTED" > "$GAUDI_BASH/profiles/backup.gaudi-bash"

	run _gaudi-bash-restore
	assert_success
	refute_output --partial "INJECTED"
	assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
}
