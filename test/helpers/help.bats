#!/usr/bin/env bats

load ../helper
load ../../lib/composure

cite about param example group

load ../../lib/bash-it
load ../../lib/helpers/help


local_setup () {
  prepare
}

@test "bash-it-helpers: help: should show default help menu if no valid argument was passed" {

  run _bash-it-help INVALID
  assert_success
  assert_line --index 0 --partial "provides a solid framework for using, developing and maintaining shell scripts and custom commands for your daily work"
}

@test "bash-it-helpers: help: should show default help menu if no valid alias was passed" {

  run _bash-it-help alias INVALID
  assert_failure
}

@test "bash-it-helpers: help: should successfully show help for a specific alias passed as an argument" {

  run _bash-it-help aliases "ag"
  assert_line --index 0 --partial "ag='ag --smart-case --pager=\"less -MIRFX'"
}

@test "bash-it-helpers: help: _bash-it-help aliases without any aliases enabled" {

  run _bash-it-help aliases
  refute_output
}

@test "bash-it-helpers: help: _bash-it-help list aliases without any aliases enabled" {

  run __help-list-aliases "$BASH_IT/aliases/available/ag.aliases.bash"
  assert_line --index 0 --partial "ag"
}

@test "bash-it-helpers: help: _bash-it-help list aliases with ag aliases enabled" {

  ln -s "$BASH_IT/components/aliases/ag.aliases.bash" "$BASH_IT/components/enabled/150___ag.aliases.bash"
  assert_link_exist "$BASH_IT/components/enabled/150___ag.aliases.bash"

  run __help-list-aliases "$BASH_IT/components/enabled/150___ag.aliases.bash"
  assert_line --index 0 --partial "ag"
}

@test "bash-it-helpers: help: _bash-it-help list aliases with todo.txt-cli aliases enabled" {

  ln -s "$BASH_IT/components/aliases/todo.txt-cli.aliases.bash" "$BASH_IT/components/enabled/150___todo.txt-cli.aliases.bash"
  assert_link_exist "$BASH_IT/components/enabled/150___todo.txt-cli.aliases.bash"

  run __help-list-aliases "$BASH_IT/components/enabled/150___todo.txt-cli.aliases.bash"
  assert_line --index 0 --partial "todo.txt-cli"
}

@test "bash-it-helpers: help: _bash-it-help list aliases with docker-compose aliases enabled" {

  ln -s "$BASH_IT/components/aliases/docker-compose.aliases.bash" "$BASH_IT/components/enabled/150___docker-compose.aliases.bash"
  assert_link_exist "$BASH_IT/components/enabled/150___docker-compose.aliases.bash"

  run __help-list-aliases "$BASH_IT/components/enabled/150___docker-compose.aliases.bash"
  assert_line --index 0 --partial "docker-compose"
}

@test "bash-it-helpers: help: _bash-it-help list aliases with ag aliases enabled in global directory" {

  ln -s "$BASH_IT/components/aliases/ag.aliases.bash" "$BASH_IT/components/enabled/150___ag.aliases.bash"
  assert_link_exist "$BASH_IT/components/enabled/150___ag.aliases.bash"

  run __help-list-aliases "$BASH_IT/components/enabled/150___ag.aliases.bash"
  assert_line --index 0 --partial "ag"
}

@test "bash-it-helpers: help: _bash-it-help aliases with multiple enabled aliases" {

  run bash-it enable alias "ag"
  assert_line --index 0 --partial 'enabled with priority'
  assert_link_exist "$BASH_IT/components/enabled/150___ag.aliases.bash"

  run bash-it enable plugin "aws"
  assert_line --index 0 --partial 'enabled with priority'
  assert_link_exist "$BASH_IT/components/enabled/250___aws.plugins.bash"

  run _bash-it-help aliases
  assert_line --index 0 --partial "ag"
  assert_line --index 2 "ag='ag --smart-case --pager=\"less -MIRFX'"
}
