#!/usr/bin/env bats

load ../helper
load ../../lib/composure

cite about param example group

load ../../lib/bash-it
load ../../lib/helpers/doctor

local_setup () {
  prepare

  cd "$BASH_IT"
  ./setup.sh --silent
  load "$BASH_IT"/bash_it.sh
}

@test "bash-it helpers: doctor: _bash-it-doctor should show all logs by default" {

  run _bash-it-doctor
  assert_success
  assert_output --partial "[ DEBUG ] [CORE] Loading library: log"
  assert_output --partial "[ WARNING ] [LOADER] completion already loaded"
}

@test "bash-it helpers: doctor: _bash-it-doctor should show only warning logs" {

  run _bash-it-doctor warning
  assert_success
  refute_output --partial "[ DEBUG ] [CORE] Loading library: log"
  assert_output --partial "[ WARNING ] [LOADER] completion already loaded"
}

@test "bash-it helpers: doctor: _bash-it-doctor should only error logs" {

  run _bash-it-doctor errors
  assert_success
  refute_output
}
