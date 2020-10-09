#!/usr/bin/env bats

load ../helper

load ../../lib/composure

cite about group

load ../../lib/bash-it
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

@test "bash-it helpers: _bash-it-disable: should disable all plugins" {
  run _bash-it-enable plugins "all"
  local available=$(find $BASH_IT/components/plugins -name *.plugins.bash | wc -l | xargs)
  local enabled=$(find $BASH_IT/components/enabled -name [0-9]*.plugins.bash | wc -l | xargs)
  assert_equal "$available" "$enabled"

  run _bash-it-enable alias "ag"
  assert_file_exist "$BASH_IT/components/enabled/150___ag.aliases.bash"

  run _bash-it-disable plugins "all"
  enabled=$(find $BASH_IT/components/enabled -name [0-9]*.plugins.bash | wc -l | xargs)
  assert_equal "0" "$enabled"
  assert_link_exist "$BASH_IT/components/enabled/150___ag.aliases.bash"
}

@test "bash-it helpers: _bash-it-disable: should disable all plugins with priority" {
  local enabled

  ln -s $BASH_IT/components/plugins/nvm.plugins.bash $BASH_IT/components/enabled/250___nvm.plugins.bash
  assert_file_exist "$BASH_IT/components/enabled/250___nvm.plugins.bash"

  ln -s $BASH_IT/components/plugins/node.plugins.bash $BASH_IT/components/enabled/250___node.plugins.bash
  assert_file_exist "$BASH_IT/components/enabled/250___node.plugins.bash"

  enabled=$(find $BASH_IT/components/enabled -name *.plugins.bash | wc -l | xargs)
  assert_equal "2" "$enabled"

  run _bash-it-enable alias "ag"
  assert_file_exist "$BASH_IT/components/enabled/150___ag.aliases.bash"

  run _bash-it-disable plugins "all"
  enabled=$(find $BASH_IT/components/enabled -name *.plugins.bash | wc -l | xargs)
  assert_equal "0" "$enabled"
  assert_file_exist "$BASH_IT/components/enabled/150___ag.aliases.bash"
}
