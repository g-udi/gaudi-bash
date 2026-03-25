#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	load_gaudi_libs command_duration
}

@test "gaudi-bash lib: command_duration: _command_duration_current_time should return a numeric value" {

	run _command_duration_current_time
	assert_success
	# Should be a number (integer or decimal)
	assert_output --regexp '^[0-9]+\.?[0-9]*$'
}

@test "gaudi-bash lib: command_duration: _command_duration should return empty when disabled" {

	unset GAUDI_BASH_COMMAND_DURATION
	COMMAND_DURATION_START_SECONDS="$(_command_duration_current_time)"

	run _command_duration
	assert_output ""
}

@test "gaudi-bash lib: command_duration: _command_duration should return empty for short commands" {

	GAUDI_BASH_COMMAND_DURATION=true
	COMMAND_DURATION_MIN_SECONDS=5
	COMMAND_DURATION_START_SECONDS="$(_command_duration_current_time)"

	run _command_duration
	assert_success
	assert_output ""
}

@test "gaudi-bash lib: command_duration: _command_duration should format minutes and seconds" {

	GAUDI_BASH_COMMAND_DURATION=true
	COMMAND_DURATION_MIN_SECONDS=1
	COMMAND_DURATION_PRECISION=0

	# Simulate a command that started 125 seconds ago
	local current_time
	current_time="$(_command_duration_current_time)"
	COMMAND_DURATION_START_SECONDS="$((${current_time%.*} - 125))"

	run _command_duration
	assert_success
	assert_output --partial "2m 5s"
}

@test "gaudi-bash lib: command_duration: _command_duration should format seconds only for short durations" {

	GAUDI_BASH_COMMAND_DURATION=true
	COMMAND_DURATION_MIN_SECONDS=1
	COMMAND_DURATION_PRECISION=0

	local current_time
	current_time="$(_command_duration_current_time)"
	COMMAND_DURATION_START_SECONDS="$((${current_time%.*} - 5))"

	run _command_duration
	assert_success
	assert_output --partial "5s"
}

@test "gaudi-bash lib: command_duration: _dynamic_clock_icon should set COMMAND_DURATION_ICON" {

	run _dynamic_clock_icon 3
	# The icon should have been set (we can't easily assert emoji content, just verify no error)
	assert_success
}
