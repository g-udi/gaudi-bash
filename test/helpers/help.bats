#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	load_gaudi_libs gaudi-bash help
}

@test "gaudi-bash-helpers: help: should show default help menu if no valid argument was passed" {

	run _gaudi-bash-help INVALID
	assert_success
	assert_line --index 0 --partial "provides a solid framework for using, developing and maintaining shell scripts and custom commands for your daily work"
}

@test "gaudi-bash-helpers: help: should show default help menu if no valid alias was passed" {

	run _gaudi-bash-help alias INVALID
	assert_failure
}

@test "gaudi-bash-helpers: help: should successfully show help for a specific alias passed as an argument" {

	run _gaudi-bash-help aliases "ag"
	assert_line --index 0 --partial "ag='ag --smart-case --pager=\"less -MIRFX'"
}

@test "gaudi-bash-helpers: help: _gaudi-bash-help aliases without any aliases enabled" {

	run _gaudi-bash-help aliases
	refute_output
}

@test "gaudi-bash-helpers: help: _gaudi-bash-help list aliases without any aliases enabled" {

	run __help-list-aliases "$GAUDI_BASH/aliases/available/ag.aliases.bash"
	assert_line --index 0 --partial "ag"
}

@test "gaudi-bash-helpers: help: _gaudi-bash-help list aliases with ag aliases enabled" {

	run gaudi-bash enable alias "ag"
	assert_link_exist "$GAUDI_BASH/components/enabled/150___ag.aliases.bash"

	run __help-list-aliases "$GAUDI_BASH/components/enabled/150___ag.aliases.bash"
	assert_line --index 0 --partial "ag"
}
 
@test "gaudi-bash-helpers: help: _gaudi-bash-help list aliases with gaudi-bash aliases enabled" {

	run gaudi-bash enable alias "gaudi-bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/150___gaudi-bash.aliases.bash"

	run __help-list-aliases "$GAUDI_BASH/components/enabled/150___gaudi-bash.aliases.bash"
	assert_line --index 0 --partial "gaudi-bash"
}

@test "gaudi-bash-helpers: help: _gaudi-bash-help list aliases with docker-compose aliases enabled" {

	run gaudi-bash enable alias "docker-compose"
	assert_link_exist "$GAUDI_BASH/components/enabled/150___docker-compose.aliases.bash"

	run __help-list-aliases "$GAUDI_BASH/components/enabled/150___docker-compose.aliases.bash"
	assert_line --index 0 --partial "docker-compose"
}

@test "gaudi-bash-helpers: help: _gaudi-bash-help list aliases with ag aliases enabled in global directory" {

	run gaudi-bash enable alias "ag"
	assert_link_exist "$GAUDI_BASH/components/enabled/150___ag.aliases.bash"

	run __help-list-aliases "$GAUDI_BASH/components/enabled/150___ag.aliases.bash"
	assert_line --index 0 --partial "ag"
}

@test "gaudi-bash-helpers: help: _gaudi-bash-help aliases with multiple enabled aliases" {

	run gaudi-bash enable alias "ag"
	assert_line --index 0 --partial 'enabled with priority'
	assert_link_exist "$GAUDI_BASH/components/enabled/150___ag.aliases.bash"

	run gaudi-bash enable plugin "aws"
	assert_line --index 0 --partial 'enabled with priority'
	assert_link_exist "$GAUDI_BASH/components/enabled/250___aws.plugins.bash"

	run _gaudi-bash-help aliases
	assert_line --index 0 --partial "ag"
	assert_line --index 2 "ag='ag --smart-case --pager=\"less -MIRFX'"
}
