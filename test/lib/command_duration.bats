#!/usr/bin/env bats
# shellcheck shell=bats
# shellcheck disable=SC2034,SC2030,SC2031

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

@test "gaudi-bash lib: command_duration: the hooks should be registered only once across reloads" {

	local hook
	local -i pre_exec=0 pre_cmd=0

	preexec_functions=(some_other_hook)
	precmd_functions=()

	_gaudi_bash_command_duration_init
	_gaudi_bash_command_duration_init
	_gaudi_bash_command_duration_init

	for hook in "${preexec_functions[@]}"; do
		[[ "$hook" == "_command_duration_pre_exec" ]] && pre_exec+=1
	done
	for hook in "${precmd_functions[@]}"; do
		[[ "$hook" == "_command_duration_pre_cmd" ]] && pre_cmd+=1
	done

	assert_equal "$pre_exec" 1
	assert_equal "$pre_cmd" 1
	assert_equal "${#preexec_functions[@]}" 2
}

@test "gaudi-bash lib: command_duration: nothing is timed before the first command starts" {

	GAUDI_BASH_COMMAND_DURATION=true
	COMMAND_DURATION_MIN_SECONDS=0

	# Loading the library is not a command: the first prompt has no duration to show
	assert_equal "${COMMAND_DURATION_START_SECONDS}" ""
	run _command_duration
	assert_output ""

	_command_duration_pre_exec
	run _command_duration
	assert_output --partial "s"
}
