#!/usr/bin/env bats
# shellcheck shell=bats
# shellcheck disable=SC2031

load "$GAUDI_TEST_DIRECTORY"/helper.bash

@test "gaudi-bash uninstall: verify that the uninstall script exists" {

	assert_file_exist "$GAUDI_BASH/uninstall.sh"
}

@test "gaudi-bash uninstall: run the uninstall script with an existing backup file" {

	local md5_conf

	echo "test file content for backup" > "$HOME/$GAUDI_BASH_PROFILE.bak"
	echo "test file content for original file" > "$HOME/$GAUDI_BASH_PROFILE"
	md5_bak=$(md5sum "$HOME/$GAUDI_BASH_PROFILE.bak" | awk '{print $1}')

	. "$GAUDI_BASH"/uninstall.sh

	assert_file_not_exist "$HOME/$GAUDI_BASH_PROFILE.uninstall"
	assert_file_not_exist "$HOME/$GAUDI_BASH_PROFILE.bak"
	assert_file_exist "$HOME/$GAUDI_BASH_PROFILE"

	md5_conf=$(md5sum "$HOME/$GAUDI_BASH_PROFILE" | awk '{print $1}')

	assert_equal "$md5_bak" "$md5_conf"
}

@test "gaudi-bash uninstall: run the uninstall script without an existing backup file" {

	local md5_uninstall
	local md5_orig

	echo "test file content for original file" > "$HOME/$GAUDI_BASH_PROFILE"
	md5_orig=$(md5sum "$HOME/$GAUDI_BASH_PROFILE" | awk '{print $1}')
	. "$GAUDI_BASH"/uninstall.sh

	assert_file_exist "$HOME/$GAUDI_BASH_PROFILE.uninstall"
	assert_file_not_exist "$HOME/$GAUDI_BASH_PROFILE.bak"
	assert_file_not_exist "$HOME/$GAUDI_BASH_PROFILE"

	md5_uninstall=$(md5sum "$HOME/$GAUDI_BASH_PROFILE.uninstall" | awk '{print $1}')

	assert_equal "$md5_orig" "$md5_uninstall"
}
