#!/usr/bin/env bats

load ../helper

load ../../lib/composure

cite about group

load ../../lib/helpers
load ../../lib/helpers/cache
load ../../lib/helpers/components
load ../../lib/helpers/utils
load ../../lib/helpers/disabler

local_setup () {
  prepare
}

@test "bash-it helpers: _bash-it-disable: should fail if no valid component type was passed" {
  run _bash-it-disable
  assert_failure
  assert_output --partial "Please enter a valid component to disable"
}

@test "bash-it helpers: _bash-it-disable: should fail if no valid component was passed" {
  run _bash-it-disable plugin
  assert_failure
  assert_output --partial "Please enter a valid plugin(s) to disable"
}

@test "bash-it helpers: _bash-it-disable: should fail if component was not found" {
  run _bash-it-disable plugin INVALID
  assert_failure
  assert_output --partial "INVALID"
  assert_output --partial "does not appear to be an enabled plugin"
}

@test "bash-it helpers: _bash-it-disable: should successfully disable a component" {
  run _bash-it-disable plugin base
  assert_failure
  assert_output -p "does not appear to be an enabled plugin"
  assert_file_not_exist "$BASH_IT/components/disabled/250___base.plugins.bash"
}

@test "bash-it helpers: _bash-it-disable: should display appropriate message when trying to disable an already disabled component" {
  run _bash-it-enable plugin base
  assert_success
  assert_file_exist "$BASH_IT/components/enabled/250___base.plugins.bash"
  run _bash-it-disable plugin base
  assert_output --partial "DISABLED"
  assert_file_not_exist "$BASH_IT/components/disabled/250___base.plugins.bash"
}

@test "bash-it helpers: _bash-it-disable: should run the component disable function if it exists" {

  base_on_disable () {
    echo "callback"
  }

  run _bash-it-enable plugin base
  assert_success
  assert_file_exist "$BASH_IT/components/enabled/250___base.plugins.bash"
  run _bash-it-disable plugin base
  assert_output --partial "DISABLED"
  assert_output --partial "callback"
  assert_file_not_exist "$BASH_IT/components/disabled/250___base.plugins.bash"
}


