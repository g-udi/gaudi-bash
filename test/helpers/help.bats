#!/usr/bin/env bats

load ../helper
load ../../lib/composure

cite about param example group

load ../../lib/gaudi-bash
load ../../lib/helpers/help


local_setup () {
  prepare
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

  ln -s "$GAUDI_BASH/components/aliases/lib/ag.aliases.bash" "$GAUDI_BASH/components/enabled/150___ag.aliases.bash"
  assert_link_exist "$GAUDI_BASH/components/enabled/150___ag.aliases.bash"

  run __help-list-aliases "$GAUDI_BASH/components/enabled/150___ag.aliases.bash"
  assert_line --index 0 --partial "ag"
}

@test "gaudi-bash-helpers: help: _gaudi-bash-help list aliases with todo.txt-cli aliases enabled" {

  ln -s "$GAUDI_BASH/components/aliases/lib/todo.txt-cli.aliases.bash" "$GAUDI_BASH/components/enabled/150___todo.txt-cli.aliases.bash"
  assert_link_exist "$GAUDI_BASH/components/enabled/150___todo.txt-cli.aliases.bash"

  run __help-list-aliases "$GAUDI_BASH/components/enabled/150___todo.txt-cli.aliases.bash"
  assert_line --index 0 --partial "todo.txt-cli"
}

@test "gaudi-bash-helpers: help: _gaudi-bash-help list aliases with docker-compose aliases enabled" {

  ln -s "$GAUDI_BASH/components/aliases/lib/docker-compose.aliases.bash" "$GAUDI_BASH/components/enabled/150___docker-compose.aliases.bash"
  assert_link_exist "$GAUDI_BASH/components/enabled/150___docker-compose.aliases.bash"

  run __help-list-aliases "$GAUDI_BASH/components/enabled/150___docker-compose.aliases.bash"
  assert_line --index 0 --partial "docker-compose"
}

@test "gaudi-bash-helpers: help: _gaudi-bash-help list aliases with ag aliases enabled in global directory" {

  ln -s "$GAUDI_BASH/components/aliases/lib/ag.aliases.bash" "$GAUDI_BASH/components/enabled/150___ag.aliases.bash"
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
