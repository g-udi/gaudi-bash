#!/usr/bin/env bats

load ../helper
load ../../lib/composure

cite about group

load ../../lib/helpers/doctor

local_setup () {
  prepare
}

@test 'bash-it helpers: doctor: _bash-it-doctor should show all logs by default' {
  run _bash-it-doctor
  assert_success
}
