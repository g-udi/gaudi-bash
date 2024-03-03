# #!/usr/bin/env bats
# # shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	load_gaudi_libs gaudi-bash components cache

	"$GAUDI_BASH"/setup.sh --silent
}

@test "gaudi-bash helpers: components: components: __check-function-parameters: should success when passing a valid component" {

	run __check-function-parameters "plugin"
	assert_success

	run __check-function-parameters "plugins"
	assert_success

	run __check-function-parameters "aliases"
	assert_success
}

@test "gaudi-bash helpers: components: components: __check-function-parameters: should fail when passing an invalid component" {

	run __check-function-parameters "pl"
	assert_failure

	run __check-function-parameters "pluginsss"
	assert_failure
}

@test "gaudi-bash helpers: components: components: _gaudi-bash-pluralize-component: should pluralize the argument" {

	run _gaudi-bash-pluralize-component "alias"
	assert_success
	assert_output "aliases"

	run _gaudi-bash-pluralize-component "aliases"
	assert_success
	assert_output "aliases"

	run _gaudi-bash-pluralize-component "plugin"
	assert_success
	assert_output "plugins"

	run _gaudi-bash-pluralize-component "plugins"
	assert_success
	assert_output "plugins"

	run _gaudi-bash-pluralize-component "completion"
	assert_success
	assert_output "completions"
}

@test "gaudi-bash helpers: components: components: _gaudi-bash-singularize-component: should singularize the argument" {

	run _gaudi-bash-singularize-component "aliases"
	assert_success
	assert_output "alias"

	run _gaudi-bash-singularize-component "alias"
	assert_success
	assert_output "alias"

	run _gaudi-bash-singularize-component "plugins"
	assert_success
	assert_output "plugin"

	run _gaudi-bash-singularize-component "completions"
	assert_success
	assert_output "completion"
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-help: should fail if no component was passed" {

	run _gaudi-bash-component-help
	assert_failure
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-help: should fail if no valid component was passed" {

	run _gaudi-bash-component-help INVALID
	assert_failure
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-help: should create cache file for component on the first run" {
	_gaudi-bash-component-cache-clean
	assert_file_not_exist "$GAUDI_BASH/tmp/cache/plugins"

	run _gaudi-bash-component-help plugin
	assert_file_exist "$GAUDI_BASH/tmp/cache/plugins"
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-help: should display plugins help" {

	run _gaudi-bash-component-help plugin
	assert_success
	assert_output --partial "alias-completion"
	assert_output --partial "Git helper function"
	assert_output --partial "autojump"
	refute_output --partial "FAIL"

	run _gaudi-bash-component-help plugins
	assert_success
	assert_output --partial "alias-completion"
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-help: should display a plugin help passed as the second param" {

	run _gaudi-bash-component-help plugin base
	assert_success
	assert_line --partial "base"
	assert_output --partial "Miscellaneous tools"
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-help: should fail if the plugin passed as the second param doesn't exist" {

	run _gaudi-bash-component-help plugin FAIL
	assert_failure
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-help: should display aliases help" {

	run _gaudi-bash-component-help alias osx
	assert_success
	assert_output --partial "osx"
	assert_output --partial "OSX specific aliases"
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-help: should display an alias help passed as the second param" {

	run _gaudi-bash-component-help plugin base
	assert_success
	assert_line --partial "base"
	assert_output --partial "Miscellaneous tools"
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-help: should fail if the alias passed as the second param doesn't exist" {

	run _gaudi-bash-component-help aliases FAIL
	assert_failure
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-help: should display completions help" {

	run _gaudi-bash-component-help completions
	assert_success
	assert_output --partial "gaudi-bash"
	assert_output --partial "git"
	assert_output --partial "Python pip package manager bash completions"
	refute_output --partial "FAIL"

	run _gaudi-bash-component-help aliases
	assert_success
	assert_output --partial "gaudi-bash"
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-help: should display a completion help passed as the second param" {

	run _gaudi-bash-component-help completion pip
	assert_success
	assert_output --partial "pip"
	assert_output --partial "Python pip package manager bash completions"
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-help: should fail if the completion passed as the second param doesn't exist" {

	run _gaudi-bash-component-help completions FAIL
	assert_failure
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-list: should fail if the no component was passed" {

	run _gaudi-bash-component-list
	assert_failure
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-list: should fail if the an invalid component was passed" {

	run _gaudi-bash-component-list INVALID
	assert_failure
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-list: should show a list of components (as an array)" {

	run _gaudi-bash-component-list plugins
	assert_success
	IFS=', ' read -r -a array <<< "$output"
	run echo "${array[0]-not array}"
	assert_output "alias-completion"
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-list-matching: should fail if the no component was passed" {

	run _gaudi-bash-component-list-matching
	assert_failure
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-list-matching: should fail if the an invalid component was passed" {

	run _gaudi-bash-component-list-matching INVALID
	assert_failure
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-list-matching: should fail if no valid match was found" {

	run _gaudi-bash-component-list-matching plugin NO_MATCH
	assert_failure
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-list-matching: should show a list of matched components (as an array)" {

	run _gaudi-bash-component-list-matching plugins base
	assert_success
	IFS=', ' read -r -a array <<< "$output"
	run echo "${array[0]-not array}"
	assert_output "base"

	run echo "${#array[@]}"
	assert_output 1

	run _gaudi-bash-component-list-matching plugins node
	assert_success
	IFS=', ' read -r -a array <<< "$output"
	run echo "${array[0]-not array}"
	assert_output "node"
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-list-enabled: should fail if the no component was passed" {

	run _gaudi-bash-component-list-enabled
	assert_failure
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-list-enabled: should fail if the no valid component was passed" {

	run _gaudi-bash-component-list-enabled INVALID
	assert_failure
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-list-enabled: should return a list of enabled components" {

	run _gaudi-bash-component-list-enabled plugins
	assert_success
	IFS=', ' read -r -a array <<< "$output"

	run echo "${array[0]-not array}"
	assert_output "alias-completion"

	run echo "${array[1]-not array}"
	assert_output "base"
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-list-disabled: should fail if the no component was passed" {

	run _gaudi-bash-component-list-disabled
	assert_failure
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-list-disabled: should fail if the no valid component was passed" {
	run _gaudi-bash-component-list-disabled INVALID
	assert_failure
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-list-disabled: should return a list of disabled components" {

	run _gaudi-bash-component-list-disabled plugins
	assert_success
	IFS=', ' read -r -a array <<< "$output"

	run echo "${array[0]-not array}"
	refute_output "alias-completion"

	run echo "${array[0]-not array}"
	assert_output "autojump"
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-item-is-enabled: should fail if the no component was passed" {

	run _gaudi-bash-component-item-is-enabled
	assert_failure
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-item-is-enabled: should fail if the no valid component was passed" {

	run _gaudi-bash-component-item-is-enabled INVALID
	assert_failure
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-item-is-enabled: should fail if the item passed is not enabled" {

	run _gaudi-bash-component-item-is-enabled plugin git
	assert_failure
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-item-is-enabled: should succeed if the item passed is enabled" {

	run _gaudi-bash-component-item-is-enabled plugin base
	assert_success
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-item-is-enabled: should check enabled component" {

	run _gaudi-bash-component-item-is-enabled plugin git
	assert_failure

	run _gaudi-bash-enable plugin git
	assert_success

	run _gaudi-bash-component-item-is-enabled plugin git
	assert_success
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-item-is-disabled: should fail if the no component was passed" {

	run _gaudi-bash-component-item-is-disabled
	assert_failure
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-item-is-disabled: should fail if the no valid component was passed" {

	run _gaudi-bash-component-item-is-disabled INVALID
	assert_failure
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-item-is-disabled: should fail if the item passed is not disabled" {

	run _gaudi-bash-component-item-is-disabled plugin base
	assert_failure
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-item-is-disabled: should succeed if the item passed is disabled" {

	run _gaudi-bash-component-item-is-disabled plugin git
	assert_success
}

@test "gaudi-bash helpers: components: _gaudi-bash-component-item-is-disabled: should check disabled component" {

	run _gaudi-bash-component-item-is-disabled plugin git
	assert_success

	run _gaudi-bash-enable plugin git
	assert_success

	run _gaudi-bash-component-item-is-disabled plugin git
	assert_failure
}
