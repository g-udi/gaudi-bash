#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

assert_sane_defaults() {
	local gaudi_root="${1:-$GAUDI_BASH}"

	assert_file_exist "$gaudi_root/components/enabled/150___general.aliases.bash"
	assert_file_exist "$gaudi_root/components/enabled/150___gaudi-bash.aliases.bash"
	assert_file_exist "$gaudi_root/components/enabled/250___base.plugins.bash"
	assert_file_exist "$gaudi_root/components/enabled/325___system.completions.bash"
	assert_file_exist "$gaudi_root/components/enabled/350___gaudi-bash.completions.bash"

	assert_file_not_exist "$gaudi_root/components/enabled/150___gls.aliases.bash"
	assert_file_not_exist "$gaudi_root/components/enabled/350___git.completions.bash"
	assert_file_not_exist "$gaudi_root/components/enabled/365___alias-completion.plugins.bash"
}

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
	assert_file_exist "$HOME/$GAUDI_BASH_PROFILE"
}

@test "gaudi-bash install: run the install script silently and enable sane defaults" {

	cd "$GAUDI_BASH"

	./setup.sh --silent

	assert_sane_defaults
}

@test "gaudi-bash install: setup should work without GAUDI_BASH and repair stale defaults from a path with spaces" {

	local standalone_checkout="${BATS_TEST_TMPDIR}/standalone gaudi-bash"
	local standalone_home="${BATS_TEST_TMPDIR}/standalone home"
	local normalized_checkout

	cp -R "$GAUDI_BASH" "$standalone_checkout"
	rm -rf "$standalone_checkout/.git"
	rm -rf "$standalone_checkout/components/enabled"
	mkdir -p "$standalone_checkout/components/enabled" "$standalone_home"
	ln -s "/tmp/missing/system.completions.bash" "$standalone_checkout/components/enabled/325___system.completions.bash"

	run env -u GAUDI_BASH HOME="$standalone_home" /bin/bash "$standalone_checkout/setup.sh" --silent --no-modify-config
	assert_success

	assert_sane_defaults "$standalone_checkout"

	normalized_checkout="$(cd "$standalone_checkout" && pwd)"
	run readlink "$standalone_checkout/components/enabled/325___system.completions.bash"
	assert_output "$normalized_checkout/components/completions/lib/system.completions.bash"
}

@test "gaudi-bash install: run the install script silently and don't modify configs" {
	rm -rf "${HOME:?}/${GAUDI_BASH_PROFILE:?}"

	cd "$GAUDI_BASH"
	./setup.sh --silent --no_modify_config

	assert_file_not_exist "$HOME/${GAUDI_BASH_PROFILE}"
}

@test "gaudi-bash install: verify that a backup file is created" {

	local md5_orig
	local md5_bak

	cd "$GAUDI_BASH" || exit

	touch "$HOME/$GAUDI_BASH_PROFILE"
	echo "test file content" > "$HOME/$GAUDI_BASH_PROFILE"
	md5_orig=$(md5sum "$HOME/$GAUDI_BASH_PROFILE" | awk '{print $1}')

	./setup.sh --silent

	assert_file_exist "$HOME/$GAUDI_BASH_PROFILE"
	assert_file_exist "$HOME/$GAUDI_BASH_PROFILE.bak"

	md5_bak=$(md5sum "$HOME/$GAUDI_BASH_PROFILE.bak" | awk '{print $1}')

	assert_equal "$md5_orig" "$md5_bak"
}
