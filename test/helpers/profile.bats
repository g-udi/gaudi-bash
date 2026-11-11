#!/usr/bin/env bats
# shellcheck shell=bats
# shellcheck disable=SC2329,SC2030,SC2031

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	load_gaudi_libs log gaudi-bash

	# Overwriting a profile asks on the terminal, here the answer comes from the test
	_read_input() {
		echo "ASKED: $1"
		REPLY="${GAUDI_TEST_ANSWER:-y}"
	}
}

@test "gaudi-bash helpers: profile: save should write the enabled components to the profile" {

	run _gaudi-bash-enable plugin base
	run _gaudi-bash-enable alias general
	run _gaudi-bash-enable completion system

	run gbash profile save test-setup
	assert_success
	assert_output --partial "3 component(s) written to"
	refute_output --partial "ASKED"

	run cat "$GAUDI_BASH/profiles/test-setup.gaudi-bash"
	assert_line --index 0 "alias general"
	assert_line --index 1 "plugin base"
	assert_line --index 2 "completion system"
	assert_equal "${#lines[@]}" 3
}

@test "gaudi-bash helpers: profile: save should write an empty profile when nothing is enabled" {

	run gbash profile save test-empty
	assert_success
	assert_output --partial "0 component(s) written to"

	assert_file_exist "$GAUDI_BASH/profiles/test-empty.gaudi-bash"
	run cat "$GAUDI_BASH/profiles/test-empty.gaudi-bash"
	refute_output
}

@test "gaudi-bash helpers: profile: save should fail without a profile name" {

	run gbash profile save
	assert_failure
	assert_output --partial "Please provide a profile name"
}

@test "gaudi-bash helpers: profile: save should ask before replacing a profile" {

	run _gaudi-bash-enable plugin base
	run gbash profile save test-setup
	assert_success

	run _gaudi-bash-enable alias general

	GAUDI_TEST_ANSWER=n run gbash profile save test-setup
	assert_success
	assert_output --partial "ASKED"
	assert_output --partial "Profile save cancelled"
	run cat "$GAUDI_BASH/profiles/test-setup.gaudi-bash"
	assert_output "plugin base"

	GAUDI_TEST_ANSWER=y run gbash profile save test-setup
	assert_success
	assert_output --partial "2 component(s) written to"
}

@test "gaudi-bash helpers: profile: load should enable exactly the components of the profile" {

	mkdir -p "$GAUDI_BASH/profiles"
	printf "%s\n" "plugin base" "" "alias general" > "$GAUDI_BASH/profiles/test-setup.gaudi-bash"

	run _gaudi-bash-enable completion system
	run _gaudi-bash-enable plugin git

	run gbash profile load test-setup
	assert_success
	assert_output --partial "loaded successfully"

	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/250___git.plugins.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/325___system.completions.bash"
}

@test "gaudi-bash helpers: profile: load should change nothing when the profile has an invalid entry" {

	mkdir -p "$GAUDI_BASH/profiles"
	printf "%s\n" "plugin base" "echo INJECTED" > "$GAUDI_BASH/profiles/test-broken.gaudi-bash"

	run _gaudi-bash-enable plugin git

	run gbash profile load test-broken
	assert_failure
	assert_output --partial "Invalid entry"
	assert_output --partial "line 2"

	assert_file_exist "$GAUDI_BASH/components/enabled/250___git.plugins.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
}

@test "gaudi-bash helpers: profile: load should fail for a profile that does not exist" {

	run gbash profile load test-missing
	assert_failure
	assert_output --partial "not found"

	run gbash profile load
	assert_failure
	assert_output --partial "Please provide a profile name"
}

@test "gaudi-bash helpers: profile: list should show the profiles and how many components they hold" {

	run gbash profile list
	assert_success
	assert_output --partial "No profiles found"

	mkdir -p "$GAUDI_BASH/profiles"
	printf "%s\n" "plugin base" "alias general" > "$GAUDI_BASH/profiles/test-setup.gaudi-bash"

	run gbash profile list
	assert_success
	assert_line --partial "test-setup"
	assert_line --partial "(2 component(s))"
}

@test "gaudi-bash helpers: profile: rm should remove a profile but not the default one" {

	mkdir -p "$GAUDI_BASH/profiles"
	printf "%s\n" "plugin base" > "$GAUDI_BASH/profiles/test-setup.gaudi-bash"
	printf "%s\n" "plugin base" > "$GAUDI_BASH/profiles/default.gaudi-bash"

	run gbash profile rm test-setup
	assert_success
	assert_file_not_exist "$GAUDI_BASH/profiles/test-setup.gaudi-bash"

	run gbash profile rm test-setup
	assert_failure
	assert_output --partial "not found"

	run gbash profile rm default
	assert_failure
	assert_output --partial "protected"
	assert_file_exist "$GAUDI_BASH/profiles/default.gaudi-bash"
}

@test "gaudi-bash helpers: profile: an unknown action should fail with the usage" {

	run gbash profile bogus
	assert_failure
	assert_output --partial "Unknown profile action: bogus"
	assert_output --partial "Usage: gbash profile [save|load|list|rm] [name]"
}
