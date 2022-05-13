#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

@test "gaudi-bash install: verify that the install script exists" {

	assert_file_exist "$GAUDI_BASH/install.sh"
}

@test "gaudi-bash install: verify that the setup script exists" {

	assert_file_exist "$GAUDI_BASH/setup.sh"
}

@test "gaudi-bash install: run the install script silently by skipping prompts" {

	run ./setup.sh --silent
	[[ -z $output ]]
}

@test "gaudi-bash install: run the install script silently and check that config file exists" {

	cd "$GAUDI_BASH"

	./setup.sh --silent
	assert_file_exist "$HOME/$GAUDI_BASH_BASHRC_PROFILE"
}

@test "gaudi-bash install: run the install script silently and enable sane defaults" {

	cd "$GAUDI_BASH"

	./setup.sh --silent

	assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/365___alias-completion.plugins.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/350___system.completions.bash"
}

@test "gaudi-bash install: run the install script silently and don't modify configs" {
	rm -rf "${HOME:?}/${GAUDI_BASH_BASHRC_PROFILE:?}"

	cd "$GAUDI_BASH"
	./setup.sh --silent --no_modify_config

	assert_file_not_exist "$HOME/${GAUDI_BASH_BASHRC_PROFILE}"
}

@test "gaudi-bash install: verify that a backup file is created" {

	local md5_orig
	local md5_bak

	cd "$GAUDI_BASH" || exit

	touch "$HOME/$GAUDI_BASH_BASHRC_PROFILE"
	echo "test file content" > "$HOME/$GAUDI_BASH_BASHRC_PROFILE"
	md5_orig=$(md5sum "$HOME/$GAUDI_BASH_BASHRC_PROFILE" | awk '{print $1}')

	./setup.sh --silent

	assert_file_exist "$HOME/$GAUDI_BASH_BASHRC_PROFILE"
	assert_file_exist "$HOME/$GAUDI_BASH_BASHRC_PROFILE.bak"

	md5_bak=$(md5sum "$HOME/$GAUDI_BASH_BASHRC_PROFILE.bak" | awk '{print $1}')

	assert_equal "$md5_orig" "$md5_bak"
}
