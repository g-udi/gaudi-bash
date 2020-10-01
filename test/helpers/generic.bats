#!/usr/bin/env bats

load ../helper

load ../../lib/helpers/generic

local_setup () {
  setup_test_fixture
}

@test "bash-it helpers: array-contains: should return status 0 if an element is found in array" {
  declare -a fruits=(apple orange pear mandarin)

  run array-contains "pear" "${fruits[@]}"
  assert_success

  run array-contains "apple" "${fruits[@]}"
  assert_success

  run array-contains "mandarin" "${fruits[@]}"
  assert_success

  run array-contains "cucumber" "${fruits[@]}"
  assert_failure
}

@test "bash-it helpers: clean-string: should return expected results" {
  local _test=" test test test "

  # Make sure all leading and trailing whitespaces are trimmed
  run clean-string "$_test" "all" &> /dev/null
  assert_success
  assert_output "test test test"

  # Make sure only leading whitespaces are trimmed
  run clean-string "$_test" "leading" &> /dev/null
  assert_success
  assert_output "test test test "

  # Make sure only trailing whitespaces are trimmed
  run clean-string "$_test" "trailing" &> /dev/null
  assert_success
  assert_output " test test test"

  # Make sure only any whitespaces are trimmed
  run clean-string "$_test" "any" &> /dev/null
  assert_success
  assert_output "testtesttest"
}

@test "bash-it helpers: array-dedupe: should remove duplicates from array and return it sorted" {
  declare -a array_a=(apple orange pear mandarin)
  declare -a array_b=(apple pear apricot cucumber orange)

  run array-dedupe "${array_a[@]}" "${array_b[@]}" &> /dev/null
  assert_success
  assert_output "apple apricot cucumber mandarin orange pear"
}
