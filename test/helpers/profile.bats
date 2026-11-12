#!/usr/bin/env bats
# shellcheck shell=bats
# shellcheck disable=SC2329,SC2317,SC2030,SC2031

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

@test "gaudi-bash helpers: profile: rm should remove a profile" {

	mkdir -p "$GAUDI_BASH/profiles"
	printf "%s\n" "plugin base" > "$GAUDI_BASH/profiles/test-setup.gaudi-bash"

	run gbash profile rm test-setup
	assert_success
	assert_file_not_exist "$GAUDI_BASH/profiles/test-setup.gaudi-bash"

	run gbash profile rm test-setup
	assert_failure
	assert_output --partial "not found"
}

@test "gaudi-bash helpers: profile: a profile name can not leave the profiles folder" {

	local name

	for name in "../escaped" "sub/dir" "with space"; do
		run gbash profile save "$name"
		assert_failure
		assert_output --partial "A profile name can only hold letters, digits, '_' and '-'"

		run gbash profile load "$name"
		assert_failure
		run gbash profile rm "$name"
		assert_failure
	done

	assert_file_not_exist "$GAUDI_BASH/escaped.gaudi-bash"
}

@test "gaudi-bash helpers: profile: load should change nothing when the profile names a component that does not exist" {

	mkdir -p "$GAUDI_BASH/profiles"
	printf "%s\n" "plugin base" "plugin this-plugin-does-not-exist" > "$GAUDI_BASH/profiles/test-missing-component.gaudi-bash"

	run _gaudi-bash-enable plugin git

	run gbash profile load test-missing-component
	assert_failure
	assert_output --partial "Unknown component"
	assert_output --partial "line 2"
	refute_output --partial "loaded successfully"

	assert_file_exist "$GAUDI_BASH/components/enabled/250___git.plugins.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
}

@test "gaudi-bash helpers: profile: load should accept any whitespace between the type and the name" {

	mkdir -p "$GAUDI_BASH/profiles"
	printf "%s\n" "plugin  base" "alias	general" > "$GAUDI_BASH/profiles/test-spaces.gaudi-bash"

	run gbash profile load test-spaces
	assert_success
	assert_output --partial "loaded successfully"

	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
}

@test "gaudi-bash helpers: profile: load should fail when a component could not be enabled" {

	mkdir -p "$GAUDI_BASH/profiles"
	printf "%s\n" "plugin base" > "$GAUDI_BASH/profiles/test-setup.gaudi-bash"

	# shellcheck disable=SC2329
	ln() { return 1; }

	run gbash profile load test-setup
	assert_failure
	assert_output --partial "loaded only in part"
	refute_output --partial "loaded successfully"
}

@test "gaudi-bash helpers: profile: an unknown action should fail with the usage" {

	run gbash profile bogus
	assert_failure
	assert_output --partial "Unknown profile action: bogus"
	assert_output --partial "Usage: gbash profile [save|load|list|rm] [name]"
}
