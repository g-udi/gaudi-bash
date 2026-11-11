#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	load_gaudi_libs log utils
}

@test "gaudi-bash helpers: utils: _is_function: should return a success status if the passed argument is a function" {

	test_function() {
		echo "I am a test!"
	}

	run _is_function test_function
	assert_success
}

@test "gaudi-bash helpers: utils: _is_function: should return a fail status if the passed argument is not a function" {

	run _is_function "I am a test!"
	assert_failure
}

@test "gaudi-bash helpers: utils: _command_exists function exists" {

	run type -a _command_exists &> /dev/null
	assert_success
}

@test "gaudi-bash helpers: utils: _command_exists function positive test ls" {

	run _command_exists ls
	assert_success
}

@test "gaudi-bash helpers: utils: _command_exists function negative test" {

	run _command_exists __addfkds_dfdsjdf
	assert_failure
}

@test "gaudi-bash helpers: utils: _binary_exists function positive test" {

	run type -a _binary_exists &> /dev/null
	assert_success
}

@test "gaudi-bash helpers: utils: _command_exists function negative test with a default message" {

	run _command_exists a
	assert_failure
}

@test "gaudi-bash helpers: utils: _command_exists function negative test with a custom message" {

	run _command_exists a "this function doesn't exist"
	assert_failure
}

@test "gaudi-bash helpers: utils: _array-contains: should be successful if an element is found in array" {

	declare -a fruits=(apple orange pear mandarin)

	run _array-contains "pear" "${fruits[@]}"
	assert_success

	run _array-contains "apple" "${fruits[@]}"
	assert_success

	run _array-contains "mandarin" "${fruits[@]}"
	assert_success
}

@test "gaudi-bash helpers: utils: _array-contains: should be successful if an element that has spaces is found in array" {

	declare -a fruits=(apple orange pear mandarin "yellow melon")

	run _array-contains "yellow melon" "${fruits[@]}"
	assert_success
}

@test "gaudi-bash helpers: utils: _array-contains: should fail if an element is not found in array" {

	declare -a fruits=(apple orange pear mandarin)

	run _array-contains "cucumber" "${fruits[@]}"
	assert_failure

	run _array-contains "APPLE" "${fruits[@]}"
	assert_failure
}

@test "gaudi-bash helpers: utils: _clean-string: should trim all whitespace" {

	local _test=" test test test "

	run _clean-string "$_test" "any" &> /dev/null
	assert_success
	assert_output "testtesttest"
}

@test "gaudi-bash helpers: utils: _clean-string: should trim trailing whitespace" {

	local _test=" test test test "

	run _clean-string "$_test" "trailing" &> /dev/null
	assert_success
	assert_output " test test test"
}

@test "gaudi-bash helpers: utils: _clean-string: should trim leading and trailing spaces" {

	local _test=" test test test "

	run _clean-string "$_test" "all" &> /dev/null
	assert_success
	assert_output "test test test"
}

@test "gaudi-bash helpers: utils: _clean-string: should trim leading spaces" {

	local _test=" test test test "

	run _clean-string "$_test" "leading" &> /dev/null
	assert_success
	assert_output "test test test "
}

@test "gaudi-bash helpers: utils: _array-dedupe: should remove duplicates from array and return it sorted" {

	declare -a array_a=(apple orange pear mandarin)
	declare -a array_b=(apple pear apricot cucumber orange)

	run _array-dedupe "${array_a[@]}" "${array_b[@]}" &> /dev/null
	assert_success
	assert_output "apple apricot cucumber mandarin orange pear"
}

@test "gaudi-bash helpers: utils: _binary_exists: a function is not a binary" {

	__gaudi_test_only_function() { :; }

	run _binary_exists ls
	assert_success
	run _binary_exists __gaudi_test_only_function
	assert_failure
}

@test "gaudi-bash helpers: utils: host contract: the names components rely on are defined" {

	assert_equal "$GAUDI_HOST_NAME" "gaudi-bash"
	assert_equal "$GAUDI_HOST_COMMAND" "gbash"
	assert_equal "$GAUDI_HOST_HOME" "$GAUDI_BASH"
	run type -t _gaudi_host_setting
	assert_output "function"
}

@test "gaudi-bash helpers: utils: host contract: the sed in-place arguments follow the framework's" {

	load_gaudi_libs generic utils
	assert_equal "${#GAUDI_HOST_SED_I_PARAMETERS[@]}" "${#GAUDI_BASH_SED_I_PARAMETERS[@]}"
	assert_equal "${GAUDI_HOST_SED_I_PARAMETERS[0]}" "-i"
}

@test "gaudi-bash helpers: utils: _gaudi_host_setting: reads GAUDI_<name>, then GAUDI_BASH_<name>" {

	unset GAUDI_HTTP_PROXY GAUDI_BASH_HTTP_PROXY
	run _gaudi_host_setting HTTP_PROXY
	assert_success
	assert_output ""

	# shellcheck disable=SC2034 # read by name inside _gaudi_host_setting
	GAUDI_BASH_HTTP_PROXY="http://bash:1"
	run _gaudi_host_setting HTTP_PROXY
	assert_output "http://bash:1"

	# shellcheck disable=SC2034
	GAUDI_HTTP_PROXY="http://neutral:2"
	run _gaudi_host_setting HTTP_PROXY
	assert_output "http://neutral:2"
}

@test "gaudi-bash helpers: utils: _gaudi_host_setting: refuses anything that is not a setting name" {

	# shellcheck disable=SC2016 # the expansion must reach the function unexpanded
	run _gaudi_host_setting 'X:-$(echo injected)'
	assert_failure
	assert_output ""
	run _gaudi_host_setting ""
	assert_failure
}

@test "gaudi-bash helpers: utils: _homebrew-check: sets the prefix under both names, calling brew once" {

	mkdir -p "$BATS_TEST_TMPDIR/bin"
	cat > "$BATS_TEST_TMPDIR/bin/brew" << BREW
#!/bin/sh
echo called >>"$BATS_TEST_TMPDIR/brew.calls"
echo /fake/homebrew
BREW
	chmod +x "$BATS_TEST_TMPDIR/bin/brew"
	local PATH="$BATS_TEST_TMPDIR/bin:/usr/bin:/bin"
	unset GAUDI_HOST_HOMEBREW_PREFIX GAUDI_BASH_HOMEBREW_PREFIX

	_homebrew-check
	_homebrew-check
	assert_equal "$GAUDI_HOST_HOMEBREW_PREFIX" "/fake/homebrew"
	assert_equal "$GAUDI_BASH_HOMEBREW_PREFIX" "/fake/homebrew"
	run cat "$BATS_TEST_TMPDIR/brew.calls"
	assert_output "called"
}

@test "gaudi-bash helpers: utils: _homebrew-check: fails and clears the prefix without brew" {

	local PATH="/usr/bin:/bin"
	GAUDI_HOST_HOMEBREW_PREFIX="/stale"
	GAUDI_BASH_HOMEBREW_PREFIX="/stale"

	run _homebrew-check
	assert_failure
	_homebrew-check || true
	assert_equal "$GAUDI_HOST_HOMEBREW_PREFIX" ""
	assert_equal "$GAUDI_BASH_HOMEBREW_PREFIX" ""
}
