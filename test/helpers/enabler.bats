#!/usr/bin/env bats

load ../helper

load ../../lib/composure

cite about param example group priority

load ../../lib/gaudi-bash
load ../../lib/helpers/cache
load ../../lib/helpers/components
load ../../lib/helpers/utils
load ../../lib/helpers/enabler

local_setup () {
  prepare
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should fail if no valid component type was passed" {

  run _gaudi-bash-enable
  assert_failure
  assert_output "Please enter a valid component to enable"
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should fail if no valid component was passed" {

  run _gaudi-bash-enable plugin
  assert_failure
  assert_output --partial "Please enter a valid plugin(s) to enable"
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should fail if component was not found" {

  run _gaudi-bash-enable plugin INVALID
  assert_failure
  assert_output --partial "does not appear to be an available"
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should successfully enable a component" {

  run _gaudi-bash-enable plugin base
  assert_success
  assert_output --partial "enabled with priority"
  assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should display appropriate message when trying to enable an already enabled component" {

  run _gaudi-bash-enable plugin base
  assert_success
  run _gaudi-bash-enable plugin base
  assert_output --partial "is already enabled"
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should respect custom priority defined in component" {

  run _gaudi-bash-enable plugin alias-completion
  assert_success
  assert_output --partial "enabled with priority"
  assert_file_exist "$GAUDI_BASH/components/enabled/365___alias-completion.plugins.bash"
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should enable multiple components passed" {

  run gaudi-bash enable plugin "node" "nvm"
  assert_line --index 0 --partial "enabled with priority"
  assert_line --index 1 --partial "enabled with priority"
  assert_link_exist "$GAUDI_BASH/components/enabled/250___node.plugins.bash"
  assert_link_exist "$GAUDI_BASH/components/enabled/250___nvm.plugins.bash"
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should enable all plugins" {

  local available enabled

  run _gaudi-bash-enable plugins "all"
  available=$(find $GAUDI_BASH/components/plugins/lib -name *.plugins.bash | wc -l | xargs)
  enabled=$(find $GAUDI_BASH/components/enabled -name [0-9]*.plugins.bash | wc -l | xargs)
  assert_equal "$available" "$enabled"
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should handle properly enabling a set of mixed existing and non-existing components" {

  run gaudi-bash enable plugin "node"
  assert_line --index 0 --partial "enabled with priority"

  run gaudi-bash enable plugin node INVALID nvm
  assert_line --index 0 --partial "is already enabled"
  assert_line --index 1 --partial "does not appear to be an available"
  assert_line --index 2 --partial "enabled with priority"

  assert_link_exist "$GAUDI_BASH/components/enabled/250___node.plugins.bash"
  assert_link_exist "$GAUDI_BASH/components/enabled/250___nvm.plugins.bash"
}
