#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash
load "$GAUDI_BASH"/lib/composure.bash

cite about param example group priority

load "$GAUDI_BASH"/lib/gaudi-bash.bash
load "$GAUDI_BASH"/lib/helpers/doctor.bash

local_setup() {
	prepare

	cd "$GAUDI_BASH" || exit
	./setup.sh --silent
	load "$GAUDI_BASH"/gaudi_bash.sh
}

@test "gaudi-bash helpers: doctor: _gaudi-bash-doctor should show all logs by default" {

	run _gaudi-bash-doctor
	assert_success
	assert_output --partial "[ DEBUG ] [CORE] Loading library: log"
	assert_output --partial "[ WARNING ] [LOADER] completion already loaded"
}

@test "gaudi-bash helpers: doctor: _gaudi-bash-doctor should show only warning logs" {

	run _gaudi-bash-doctor warning
	assert_success
	refute_output --partial "[ DEBUG ] [CORE] Loading library: log"
	assert_output --partial "[ WARNING ] [LOADER] completion already loaded"
}

@test "gaudi-bash helpers: doctor: _gaudi-bash-doctor should only error logs" {

	run _gaudi-bash-doctor errors
	assert_success
	refute_output
}
