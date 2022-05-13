#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

@test "gaudi-bash uninstall: verify that the uninstall script exists" {

	assert_file_exist "$GAUDI_BASH/uninstall.sh"
}

@test "gaudi-bash uninstall: run the uninstall script with an existing backup file" {

	local md5_conf

	cd "$GAUDI_BASH" || exit

	echo "test file content for backup" > "$HOME/$CONFIG_FILE.bak"
	echo "test file content for original file" > "$HOME/$CONFIG_FILE"
	md5_bak=$(md5sum "$HOME/$CONFIG_FILE.bak" | awk '{print $1}')

	./uninstall.sh

	assert_file_not_exist "$HOME/$CONFIG_FILE.uninstall"
	assert_file_not_exist "$HOME/$CONFIG_FILE.bak"
	assert_file_exist "$HOME/$CONFIG_FILE"

	md5_conf=$(md5sum "$HOME/$CONFIG_FILE" | awk '{print $1}')

	assert_equal "$md5_bak" "$md5_conf"
}

@test "gaudi-bash uninstall: run the uninstall script without an existing backup file" {

	local md5_uninstall
	local md5_orig

	cd "$GAUDI_BASH" || exit

	echo "test file content for original file" > "$HOME/$CONFIG_FILE"
	md5_orig=$(md5sum "$HOME/$CONFIG_FILE" | awk '{print $1}')

	./uninstall.sh

	assert_file_exist "$HOME/$CONFIG_FILE.uninstall"
	assert_file_not_exist "$HOME/$CONFIG_FILE.bak"
	assert_file_not_exist "$HOME/$CONFIG_FILE"

	md5_uninstall=$(md5sum "$HOME/$CONFIG_FILE.uninstall" | awk '{print $1}')

	assert_equal "$md5_orig" "$md5_uninstall"
}
