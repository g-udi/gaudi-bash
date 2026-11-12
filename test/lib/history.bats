#!/usr/bin/env bats
# shellcheck shell=bats
# shellcheck disable=SC2034,SC2030,SC2031

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	unset GAUDI_BASH_HISTORY HISTSIZE HISTFILESIZE HISTFILE XDG_STATE_HOME
	shopt -u histappend
}

@test "gaudi-bash lib: history: the defaults of Bash are replaced by an unlimited history in its own file" {

	# What an interactive Bash starts with
	HISTSIZE=500
	HISTFILESIZE=500
	HISTFILE="$HOME/.bash_history"

	load_gaudi_libs history

	assert_equal "$HISTSIZE" "-1"
	assert_equal "$HISTFILESIZE" "unlimited"
	assert_equal "$HISTFILE" "$HOME/.local/state/bash/history"
	assert_dir_exist "$HOME/.local/state/bash"
	run shopt -q histappend
	assert_success
}

@test "gaudi-bash lib: history: the history file follows XDG_STATE_HOME" {

	XDG_STATE_HOME="$BATS_TEST_TMPDIR/state"

	load_gaudi_libs history

	assert_equal "$HISTFILE" "$BATS_TEST_TMPDIR/state/bash/history"
	assert_dir_exist "$BATS_TEST_TMPDIR/state/bash"
}

@test "gaudi-bash lib: history: settings you made yourself are kept" {

	HISTSIZE=10000
	HISTFILESIZE=20000
	HISTFILE="$BATS_TEST_TMPDIR/my-history"

	load_gaudi_libs history

	assert_equal "$HISTSIZE" "10000"
	assert_equal "$HISTFILESIZE" "20000"
	assert_equal "$HISTFILE" "$BATS_TEST_TMPDIR/my-history"
}

@test "gaudi-bash lib: history: loading twice changes nothing" {

	HISTSIZE=500
	HISTFILE="$HOME/.bash_history"

	load_gaudi_libs history
	load_gaudi_libs history

	assert_equal "$HISTSIZE" "-1"
	assert_equal "$HISTFILE" "$HOME/.local/state/bash/history"
}

@test "gaudi-bash lib: history: GAUDI_BASH_HISTORY=false keeps the history settings of Bash" {

	GAUDI_BASH_HISTORY=false
	HISTSIZE=500
	HISTFILESIZE=500
	HISTFILE="$HOME/.bash_history"

	load_gaudi_libs history

	assert_equal "$HISTSIZE" "500"
	assert_equal "$HISTFILESIZE" "500"
	assert_equal "$HISTFILE" "$HOME/.bash_history"
	run shopt -q histappend
	assert_failure

	# The helper to list the most used commands is there either way
	run type -t hr
	assert_output "function"
}
