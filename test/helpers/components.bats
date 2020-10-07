#!/usr/bin/env bats

load ../helper

load ../../lib/composure

cite about param example group

load ../../lib/helpers
load ../../lib/helpers/components
load ../../lib/helpers/cache

local_setup () {
  prepare
}

@test "bash-it helpers: components: _bash-it-pluralize-component: should pluralize the argument" {

  run  _bash-it-pluralize-component "alias"
  assert_success
  assert_output "aliases"

  run  _bash-it-pluralize-component "aliases"
  assert_success
  assert_output "aliases"

  run  _bash-it-pluralize-component "plugin"
  assert_success
  assert_output "plugins"

  run  _bash-it-pluralize-component "plugins"
  assert_success
  assert_output "plugins"

  run  _bash-it-pluralize-component "completion"
  assert_success
  assert_output "completions"
}

@test "bash-it helpers: components: _bash-it-singularize-component: should singularize the argument" {

  run  _bash-it-singularize-component "aliases"
  assert_success
  assert_output "alias"

  run  _bash-it-singularize-component "alias"
  assert_success
  assert_output "alias"

  run  _bash-it-singularize-component "plugins"
  assert_success
  assert_output "plugin"

  run  _bash-it-singularize-component "completions"
  assert_success
  assert_output "completion"
}

@test "bash-it helpers: _bash-it-component-help: should fail if no component was passed" {
  # should fail when no component is passed
  run _bash-it-component-help
  assert_failure
}

@test "bash-it helpers: _bash-it-component-help: should fail if no valid component was passed" {
  # should fail when no component is passed
  run _bash-it-component-help INVALID
  assert_failure
}

@test "bash-it helpers: _bash-it-component-help: should create cache file for component on the first run" {
  _bash-it-component-cache-clean
  assert_file_not_exist "$HOME/.bash_it/tmp/cache/plugins"
  run _bash-it-component-help plugin
  assert_file_exist "$HOME/.bash_it/tmp/cache/plugins"
}

@test "bash-it helpers: _bash-it-component-help: should display plugins help" {

  run _bash-it-component-help plugin
  assert_success
  assert_output --partial "alias-completion"
  assert_output --partial "git helper function"
  assert_output --partial "autojump"
  refute_output --partial "FAIL"

  run _bash-it-component-help plugins
  assert_success
  assert_output --partial "alias-completion"
}

@test "bash-it helpers: _bash-it-component-help: should display a plugin help passed as the second param" {
  run _bash-it-component-help plugin base
  assert_success
  assert_line --partial "base"
  assert_output --partial "miscellaneous tools"
}

@test "bash-it helpers: _bash-it-component-help: should fail if the plugin passed as the second param doesn't exist" {
  run _bash-it-component-help plugin FAIL
  assert_failure
}

@test "bash-it helpers: _bash-it-component-help: should display aliases help" {
  run _bash-it-component-help alias osx
  assert_success
  assert_output --partial "osx"
  assert_output --partial "osx-specific aliases"
}

@test "bash-it helpers: _bash-it-component-help: should display an alias help passed as the second param" {
  run _bash-it-component-help plugin base
  assert_success
  assert_line --partial "base"
  assert_output --partial "miscellaneous tools"
}

@test "bash-it helpers: _bash-it-component-help: should fail if the alias passed as the second param doesn't exist" {
  run _bash-it-component-help aliases FAIL
  assert_failure
}

@test "bash-it helpers: _bash-it-component-help: should display completions help" {
  run _bash-it-component-help completions
  assert_success
  assert_output --partial "bash-it"
  assert_output --partial "git"
  assert_output --partial "install and run python applications in isolated environments"
  refute_output --partial "FAIL"

  run _bash-it-component-help aliases
  assert_success
  assert_output --partial "bash-it"
}

@test "bash-it helpers: _bash-it-component-help: should display a completion help passed as the second param" {
  run _bash-it-component-help completion pipx
  assert_success
  assert_output --partial "pipx"
  assert_output --partial "install and run python applications in isolated environments"
}

@test "bash-it helpers: _bash-it-component-help: should fail if the completion passed as the second param doesn't exist" {
  run _bash-it-component-help completions FAIL
  assert_failure
}

@test "bash-it helpers: _bash-it-component-list: should fail if the no component was passed" {
  run _bash-it-component-list
  assert_failure
}

@test "bash-it helpers: _bash-it-component-list: should fail if the an invalid component was passed" {
  run _bash-it-component-list INVALID
  assert_failure
}

@test "bash-it helpers: _bash-it-component-list: should show a list of components (as an array)" {
  run _bash-it-component-list plugins
  assert_success

  # Check if the output is an array and the first element matched the alias-completion plugin
  IFS=', ' read -r -a array <<< "$output"
  run echo "${array[0]-not array}"
  assert_output "alias-completion"
}

@test "bash-it helpers: _bash-it-component-list-matching: should fail if the no component was passed" {
  run _bash-it-component-list-matching
  assert_failure
}

@test "bash-it helpers: _bash-it-component-list-matching: should fail if the an invalid component was passed" {
  run _bash-it-component-list-matching INVALID
  assert_failure
}

@test "bash-it helpers: _bash-it-component-list-matching: should fail if no valid match was found" {
  run _bash-it-component-list-matching plugin NO_MATCH
  assert_failure
}

@test "bash-it helpers: _bash-it-component-list-matching: should show a list of matched components (as an array)" {
  run _bash-it-component-list-matching plugins base
  assert_success

  # Check if the output is an array and the first element matched the alias-completion plugin
  IFS=', ' read -r -a array <<< "$output"
  run echo "${array[0]-not array}"
  assert_output "base"

  # Check the output array length
  run echo "${#array[@]}"
  assert_output 1

  run _bash-it-component-list-matching plugins node
  assert_success

  # Check if the output is an array and the first element matched the alias-completion plugin
  IFS=', ' read -r -a array <<< "$output"
  run echo "${array[0]-not array}"
  assert_output "node"
}

@test "bash-it helpers: _bash-it-component-list-enabled: should fail if the no component was passed" {
  run _bash-it-component-list-enabled
  assert_failure
}

@test "bash-it helpers: _bash-it-component-list-enabled: should fail if the no valid component was passed" {
  run _bash-it-component-list-enabled INVALID
  assert_failure
}

@test "bash-it helpers: _bash-it-component-list-enabled: should return a list of enabled components" {
  run _bash-it-component-list-enabled plugins
  assert_success

  # Check if the output is an array and the first element matched the alias-completion plugin
  IFS=', ' read -r -a array <<< "$output"
  run echo "${array[0]-not array}"
  assert_output "alias-completion"
  run echo "${array[1]-not array}"
  assert_output "base"
}

@test "bash-it helpers: _bash-it-component-list-disabled: should fail if the no component was passed" {
  run _bash-it-component-list-disabled
  assert_failure
}

@test "bash-it helpers: _bash-it-component-list-disabled: should fail if the no valid component was passed" {
  run _bash-it-component-list-disabled INVALID
  assert_failure
}

@test "bash-it helpers: _bash-it-component-list-disabled: should return a list of disabled components" {
  run _bash-it-component-list-disabled plugins
  assert_success

  # Check if the output is an array and the first element matched the alias-completion plugin
  IFS=', ' read -r -a array <<< "$output"
  run echo "${array[0]-not array}"
  refute_output "alias-completion"
  run echo "${array[0]-not array}"
  assert_output "autojump"
}

@test "bash-it helpers: _bash-it-component-item-is-enabled: should fail if the no component was passed" {
  run _bash-it-component-item-is-enabled
  assert_failure
}

@test "bash-it helpers: _bash-it-component-item-is-enabled: should fail if the no valid component was passed" {
  run _bash-it-component-item-is-enabled INVALID
  assert_failure
}

@test "bash-it helpers: _bash-it-component-item-is-enabled: should fail if the item passed is not enabled" {
  run _bash-it-component-item-is-enabled plugin git
  assert_failure
}

@test "bash-it helpers: _bash-it-component-item-is-enabled: should succeed if the item passed is enabled" {
  run _bash-it-component-item-is-enabled plugin base
  assert_success
}

@test "bash-it helpers: _bash-it-component-item-is-enabled: should check enabled component" {

  run _bash-it-component-item-is-enabled plugin git
  assert_failure

  run _bash-it-enable plugin git
  assert_success
  run _bash-it-component-item-is-enabled plugin git
  assert_success
}

@test "bash-it helpers: _bash-it-component-item-is-disabled: should fail if the no component was passed" {
  run _bash-it-component-item-is-disabled
  assert_failure
}

@test "bash-it helpers: _bash-it-component-item-is-disabled: should fail if the no valid component was passed" {
  run _bash-it-component-item-is-disabled INVALID
  assert_failure
}

@test "bash-it helpers: _bash-it-component-item-is-disabled: should fail if the item passed is not disabled" {
  run _bash-it-component-item-is-disabled plugin base
  assert_failure
}

@test "bash-it helpers: _bash-it-component-item-is-disabled: should succeed if the item passed is disabled" {
  run _bash-it-component-item-is-disabled plugin git
  assert_success
}

@test "bash-it helpers: _bash-it-component-item-is-disabled: should check disabled component" {

  run _bash-it-component-item-is-disabled plugin git
  assert_success

  run _bash-it-enable plugin git
  assert_success
  run _bash-it-component-item-is-disabled plugin git
  assert_failure
}
