setup () {
  export TEST_MAIN_DIR="${BATS_TEST_DIRNAME}/.."
  export TEST_DEPS_DIR="${TEST_DEPS_DIR-${TEST_MAIN_DIR}/..}"

  load "${TEST_DEPS_DIR}/bats-support/load.bash"
  load '../load'
}
