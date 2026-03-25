#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	load_gaudi_libs gaudi-bash
}

assert_sane_defaults() {
	assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/150___gaudi-bash.aliases.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/325___system.completions.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
}

@test "gaudi-bash core: _gaudi-bash-backup should successfully backup enabled components" {

	cd "$GAUDI_BASH"
	./setup.sh --silent

	assert_sane_defaults

	assert_file_not_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run _gaudi-bash-backup

	assert_file_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run cat "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"
	assert_success
	assert_output --partial "gaudi-bash enable alias general"
	assert_output --partial "gaudi-bash enable plugin base"
	assert_output --partial "gaudi-bash enable completion system"
}

@test "gaudi-bash core: _gaudi-bash-backup should overwrite old backed up components" {

	cd "$GAUDI_BASH"
	./setup.sh --silent

	assert_sane_defaults

	assert_file_not_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run _gaudi-bash-backup

	assert_file_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run gaudi-bash disable completion git
	run _gaudi-bash-backup

	assert_file_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"
	run cat "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"
	assert_output --partial "gaudi-bash enable alias general"
}

@test "gaudi-bash core: _gaudi-bash-restore should successfully restore backed up components" {

	cd "$GAUDI_BASH"
	./setup.sh --silent

	assert_sane_defaults

	assert_file_not_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run _gaudi-bash-backup

	assert_line --index 0 "Backing up alias: gaudi-bash"
	assert_file_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run gaudi-bash disable plugins all
	run gaudi-bash disable completion all
	run gaudi-bash disable aliases all

	assert_file_not_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/150___gaudi-bash.aliases.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/365___alias-completion.plugins.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/325___system.completions.bash"

	run _gaudi-bash-restore

	assert_sane_defaults

}
