#!/usr/bin/env bats

load ../helper

load ../../lib/composure

cite about group

load ../../lib/bash-it
load ../../lib/helpers/cache
load ../../lib/helpers/components
load ../../lib/helpers/utils
load ../../lib/helpers/enabler

local_setup () {
  prepare
}

@test "bash-it helpers: _bash-it-enable: should fail if no valid component type was passed" {
  run _bash-it-enable
  assert_failure
  assert_output --partial "Please enter a valid component to enable"
}

@test "bash-it helpers: _bash-it-enable: should fail if no valid component was passed" {
  run _bash-it-enable plugin
  assert_failure
  assert_output --partial "Please enter a valid plugin(s) to enable"
}

@test "bash-it helpers: _bash-it-enable: should fail if component was not found" {
  run _bash-it-enable plugin INVALID
  assert_failure
  assert_output --partial "INVALID"
  assert_output --partial "does not appear to be an available plugin"
}

@test "bash-it helpers: _bash-it-enable: should successfully enable a component" {
  run _bash-it-enable plugin base
  assert_success
  assert_output -p "base enabled"
  assert_file_exist "$BASH_IT/components/enabled/250___base.plugins.bash"
}

@test "bash-it helpers: _bash-it-enable: should display appropriate message when trying to enable an already enabled component" {
  run _bash-it-enable plugin base
  assert_success
  run _bash-it-enable plugin base
  assert_output --partial "base is already enabled"
}

@test "bash-it helpers: _bash-it-enable: should respect custom priority defined in component" {
  run _bash-it-enable plugin alias-completion
  assert_success
  assert_output -p "alias-completion enabled"
  assert_file_exist "$BASH_IT/components/enabled/365___alias-completion.plugins.bash"
}

@test "bash-it helpers: _bash-it-enable: should enable multiple components passed" {
  run _bash-it-enable plugin "node" "nvm"
  assert_line -n 0 -p 'node enabled with priority'
  assert_line -n 1 -p 'nvm enabled with priority'
  assert_link_exist "$BASH_IT/components/enabled/250___node.plugins.bash"
  assert_link_exist "$BASH_IT/components/enabled/225___nvm.plugins.bash"
}

@test "bash-it helpers: _bash-it-enable: should enable all plugins" {

  local available enabled

  run _bash-it-enable plugins "all"

  available=$(find $BASH_IT/components/plugins -name *.plugins.bash | wc -l | xargs)
  enabled=$(find $BASH_IT/components/enabled -name [0-9]*.plugins.bash | wc -l | xargs)

  assert_equal "$available" "$enabled"
}
