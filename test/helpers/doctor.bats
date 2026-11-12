#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	load_gaudi_libs gaudi-bash doctor

	"$GAUDI_BASH/setup.sh" --silent
	load "$GAUDI_BASH"/gaudi_bash.sh
}

@test "gaudi-bash helpers: doctor: _gaudi-bash-doctor should reload the profile showing all logs by default" {

	run gbash doctor
	assert_success
	assert_output --partial "[ DEBUG ]"
	assert_output --partial "Loading"
	assert_output --partial "gaudi-bash reloaded from $HOME/$GAUDI_BASH_PROFILE"
}

@test "gaudi-bash helpers: doctor: _gaudi-bash-doctor should leave the debug logs out for warnings and errors" {

	run _gaudi-bash-doctor warnings
	assert_success
	refute_output --partial "[ DEBUG ]"
	assert_output --partial "gaudi-bash reloaded from"

	run _gaudi-bash-doctor errors
	assert_success
	refute_output --partial "[ DEBUG ]"
	assert_output --partial "gaudi-bash reloaded from"
}

@test "gaudi-bash helpers: doctor: _gaudi-bash-doctor should reject an unknown log level" {

	# shellcheck disable=SC2329
	_gaudi-bash-reload() { echo "RELOADED"; }

	run gbash doctor bogus
	assert_failure
	assert_output --partial "Unknown log level: bogus"
	assert_output --partial "Usage: gbash doctor [errors|warnings|all]"
	refute_output --partial "RELOADED"
}

@test "gaudi-bash helpers: doctor: _gaudi-bash-doctor should reload with the requested log level" {

	# shellcheck disable=SC2329
	_gaudi-bash-reload() { echo "LEVEL=${GAUDI_BASH_LOG_LEVEL}"; }

	run gbash doctor errors
	assert_success
	assert_output "LEVEL=${GAUDI_BASH_LOG_LEVEL_ERROR}"

	run gbash doctor warnings
	assert_output "LEVEL=${GAUDI_BASH_LOG_LEVEL_WARNING}"

	run gbash doctor all
	assert_output "LEVEL=${GAUDI_BASH_LOG_LEVEL_ALL}"

	run gbash doctor
	assert_output "LEVEL=${GAUDI_BASH_LOG_LEVEL_ALL}"
}

@test "gaudi-bash helpers: doctor: _gaudi-bash-doctor should leave a GAUDI_BASH_LOG_LEVEL of your own as it was" {

	# shellcheck disable=SC2329
	_gaudi-bash-reload() { return 0; }

	export GAUDI_BASH_LOG_LEVEL="${GAUDI_BASH_LOG_LEVEL_WARNING}"
	gbash doctor errors
	assert_equal "$GAUDI_BASH_LOG_LEVEL" "${GAUDI_BASH_LOG_LEVEL_WARNING}"

	gbash doctor bogus > /dev/null || true
	assert_equal "$GAUDI_BASH_LOG_LEVEL" "${GAUDI_BASH_LOG_LEVEL_WARNING}"

	unset GAUDI_BASH_LOG_LEVEL
	gbash doctor all
	assert_equal "${GAUDI_BASH_LOG_LEVEL-not set}" "not set"
}
