#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	load_gaudi_libs gaudi-bash
}

@test "gaudi-bash core: _gaudi-bash-backup should successfully backup enabled components" {

	local backup_md5

	cd "$GAUDI_BASH"
	./setup.sh --silent

	assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/150___gaudi-bash.aliases.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/350___system.completions.bash"

	assert_file_not_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run _gaudi-bash-backup

	assert_file_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"
	backup_md5=$(md5sum "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup" | awk '{print $1}')
	# This is compare against the md5 hash of the backup file created from a fresh set of enabled plugins after setup
	assert_equal "$backup_md5" "ac215abe7c4938ad7a5f6a3f70e25cbb"
}

@test "gaudi-bash core: _gaudi-bash-backup should overwrite old backed up components" {

	local backup_md5

	cd "$GAUDI_BASH"
	./setup.sh --silent

	assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/150___gaudi-bash.aliases.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/350___system.completions.bash"

	assert_file_not_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run _gaudi-bash-backup

	assert_file_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"
	backup_md5=$(md5sum "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup" | awk '{print $1}')
	# This is compare against the md5 hash of the backup file created from a fresh set of enabled plugins after setup
	assert_equal "$backup_md5" "ac215abe7c4938ad7a5f6a3f70e25cbb"

	run gaudi-bash disable completion git
	run _gaudi-bash-backup
	backup_md5=$(md5sum "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup" | awk '{print $1}')
	# This is compare against the md5 hash of the backup file created from a fresh set of enabled plugins after setup
	assert_equal "$backup_md5" "ac215abe7c4938ad7a5f6a3f70e25cbb"
}

@test "gaudi-bash core: _gaudi-bash-restore should successfully restore backed up components" {

	local backup_md5

	cd "$GAUDI_BASH"
	./setup.sh --silent

	assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/150___gaudi-bash.aliases.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/350___system.completions.bash"

	assert_file_not_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run _gaudi-bash-backup

	assert_line --index 0 "Backing up alias: gaudi-bash"
	assert_file_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"
	backup_md5=$(md5sum "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup" | awk '{print $1}')
	# This is compare against the md5 hash of the backup file created from a fresh set of enabled plugins after setup
	assert_equal "$backup_md5" "50f40560080fdfc2bbb016a2f42a238a"

	run gaudi-bash disable plugins all
	run gaudi-bash disable completion all
	run gaudi-bash disable aliases all

	assert_file_not_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/150___gaudi-bash.aliases.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/365___alias-completion.plugins.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/350___system.completions.bash"

	run _gaudi-bash-restore

	assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/150___gaudi-bash.aliases.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/350___system.completions.bash"

}
