#!/usr/bin/env bats

load ../helper
load ../../lib/composure

cite about param example group priority

load ../../lib/gaudi-bash
load ../../lib/search
load ../../lib/helpers/utils
load ../../lib/helpers/components
load ../../lib/helpers/search

local_setup () {
  prepare
}

@test "gaudi-bash helpers: search: _gaudi-bash-rewind should successfully rewind the output by N chars" {

  run _gaudi-bash-rewind
  assert_success

  run printf "AAA$(_gaudi-bash-rewind 2)AA"
  assert_success
  assert_output "AAA[2DAA"

  run printf "AAA$(_gaudi-bash-rewind 2)AAA"
  assert_success
  assert_output "AAA[2DAAA"
}
