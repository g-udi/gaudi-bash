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

@test "gaudi-bash-helpers: help: should fail for an alias group that does not exist" {

	run _gaudi-bash-help alias INVALID
	assert_failure
}

@test "gaudi-bash-helpers: help: _gaudi-bash-help aliases without any aliases enabled" {

	run _gaudi-bash-help aliases
	refute_output
}

@test "gaudi-bash-helpers: help: _gaudi-bash-help list aliases without any aliases enabled" {

	assert_file_exist "$GAUDI_BASH/components/aliases/lib/ag.aliases.bash"
	run __help-list-aliases "$GAUDI_BASH/components/aliases/lib/ag.aliases.bash"
	assert_success
	assert_line --index 0 --partial "ag"
	assert_output --partial "ag='ag --smart-case"
}

@test "gaudi-bash-helpers: help: _gaudi-bash-help list aliases with ag aliases enabled" {

	run gbash enable alias "ag"
	assert_link_exist "$GAUDI_BASH/components/enabled/150___ag.aliases.bash"

	run __help-list-aliases "$GAUDI_BASH/components/enabled/150___ag.aliases.bash"
	assert_line --index 0 --partial "ag"
}

@test "gaudi-bash-helpers: help: _gaudi-bash-help list aliases with gaudi-bash aliases enabled" {

	run gbash enable alias "gaudi-bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/150___gaudi-bash.aliases.bash"

	run __help-list-aliases "$GAUDI_BASH/components/enabled/150___gaudi-bash.aliases.bash"
	assert_line --index 0 --partial "gaudi-bash"
}

@test "gaudi-bash-helpers: help: _gaudi-bash-help list aliases with docker-compose aliases enabled" {

	run gbash enable alias "docker-compose"
	assert_link_exist "$GAUDI_BASH/components/enabled/150___docker-compose.aliases.bash"

	run __help-list-aliases "$GAUDI_BASH/components/enabled/150___docker-compose.aliases.bash"
	assert_line --index 0 --partial "docker-compose"
}

@test "gaudi-bash-helpers: help: _gaudi-bash-help list aliases from the enabled link" {

	run gbash enable alias "ag"
	assert_link_exist "$GAUDI_BASH/components/enabled/150___ag.aliases.bash"

	run __help-list-aliases "$GAUDI_BASH/components/enabled/150___ag.aliases.bash"
	assert_line --index 0 --partial "ag"
}

@test "gaudi-bash-helpers: help: _gaudi-bash-help aliases with multiple enabled aliases" {

	run gbash enable alias "ag"
	assert_line --index 0 --partial 'enabled with priority'
	assert_link_exist "$GAUDI_BASH/components/enabled/150___ag.aliases.bash"

	run gbash enable plugin "aws"
	assert_line --index 0 --partial 'enabled with priority'
	assert_link_exist "$GAUDI_BASH/components/enabled/250___aws.plugins.bash"

	run _gaudi-bash-help aliases
	assert_line --index 0 --partial "ag"
	assert_line --index 2 "ag='ag --smart-case --pager=\"less -MIRFX'"
}

@test "gaudi-bash-helpers: help: aliases <name> should list only that alias group" {

	run gbash enable alias "ag"
	run gbash enable alias "docker-compose"

	run _gaudi-bash-help aliases ag
	assert_success
	assert_output --partial "ag"
	refute_output --partial "docker-compose"
}

@test "gaudi-bash-helpers: help: aliases <name> should fail for an unknown alias group" {

	run _gaudi-bash-help aliases INVALID
	assert_failure
	assert_output --partial "No aliases named 'INVALID' were found"
}

@test "gaudi-bash-helpers: help: plugins <name> should fail for an unknown plugin" {

	run _gaudi-bash-help plugins INVALID
	assert_failure
	assert_output --partial "No plugin named 'INVALID' was found"
}

@test "gaudi-bash-helpers: help: plugins <name> should point at enable when the plugin is not loaded" {

	run _gaudi-bash-help plugins git
	assert_success
	assert_output --partial "gbash enable plugin git"
}

@test "gaudi-bash-helpers: help: plugins <name> should describe the functions of a loaded plugin" {

	# shellcheck disable=SC1091
	source "$GAUDI_BASH/components/plugins/lib/git.plugins.bash"

	run _gaudi-bash-help plugins git
	assert_success
	assert_line --partial "git_remote"
	refute_output --partial "gbash enable plugin git"
}

@test "gaudi-bash-helpers: help: plugins should group the functions and leave the composure functions alone" {

	local composure_letterpress

	composure_letterpress="$(declare -f _letterpress)"

	# shellcheck disable=SC2329
	a_function_in_a_spaced_group() {
		about 'does something useful'
		group 'my own group'
	}

	# Not on a terminal: the help is printed as is, no pager and no progress note
	run _gaudi-bash-help plugins
	assert_success
	assert_line "my own group"
	assert_line --regexp "^a_function_in_a_spaced_group +does something useful$"
	refute_output --partial "please wait"
	refute_output --partial "gaudi-bash:core"

	run _gaudi-bash-help plugins all
	assert_success
	assert_line "gaudi-bash:core"
	assert_line --regexp "^_gaudi-bash-enable +enable a gaudi-bash component"

	# Nothing is defined or replaced globally while building the help
	_gaudi-bash-help plugins > /dev/null
	run declare -F __letterpress
	assert_failure
	assert_equal "$(declare -f _letterpress)" "$composure_letterpress"
}
