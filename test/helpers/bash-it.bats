#!/usr/bin/env bats

load ../helper
load ../../lib/composure

cite about param example group

load ../../lib/helpers/bash-it
load ../../lib/helpers/components
load ../../lib/helpers/utils
load ../../lib/helpers/cache

export BASH_IT_DESCRIPTION_MIN_LINE_COUNT=10

local_setup () {
  prepare
}

# Returns true if the no. lines for description is more than the BASH_IT_DESCRIPTION_MIN_LINE_COUNT
_check-results-count () {
  [[ $(_bash-it-describe "$1" "$2" | grep "^.*$" -c) -gt $BASH_IT_DESCRIPTION_MIN_LINE_COUNT ]] && return 0
  return 1
}

@test "bash-it helpers: _bash-it-describe: should fail if no valid component was passed" {

  run _bash-it-describe plugins
  assert_success

  run _bash-it-describe
  assert_failure

  run _bash-it-describe INVALID
  assert_failure

  run _bash-it-describe completion
  assert_success
}

@test "bash-it helpers: _bash-it-describe: should fail if no valid mode was passed" {

  run _bash-it-describe plugins
  assert_success

  run _bash-it-describe plugins INVALID
  assert_failure

  run _bash-it-describe plugins all
  assert_success

  run _bash-it-describe completion enabled
  assert_success
}

@test "bash-it helpers: _bash-it-describe: should display proper table headers" {

  # Should display plugins help (we are piping to sed to remove redundant white spaces for consistency)
  _get-description-header () {
    echo "$(_bash-it-describe "$1")" | head -n 2 | sed "s/  */ /g"
  }

  # Make sure the columns headers are capitalized
  run _get-description-header plugin
  assert_success
  assert_line --index 0 "Plugin Enabled? Description"
  refute_line --index 0 "plugin Enabled? Description"

  run _get-description-header plugins
  assert_line --index 0 "Plugin Enabled? Description"
  refute_line --index 0 "plugin Enabled? Description"

  run _get-description-header aliases
  assert_success
  assert_line --index 0 "Alias Enabled? Description"
  refute_line --index 0 "alias Enabled? Description"
}

@test "bash-it helpers: _bash-it-describe: should display a component name and description" {
  run _bash-it-describe plugins
  assert_success
  assert_output -p "base"
  assert_output -p "miscellaneous tools"
}

@test "bash-it helpers: _bash-it-describe: should list all plugins (enabled/disabled)" {

  run _check-results-count plugins
  assert_success

  run _check-results-count plugin all
  assert_success

  run bash-it disable plugins all
  run _check-results-count plugins
  assert_success
}

@test "bash-it helpers: _bash-it-describe: should list all aliases (enabled/disabled)" {

  run _check-results-count aliases
  assert_success
  run _check-results-count alias all
  assert_success

  run bash-it disable all
  run _check-results-count aliases
  assert_success
}


@test "bash-it helpers: _bash-it-describe: should list all completions (enabled/disabled)" {

  run _check-results-count completion
  assert_success
  run _check-results-count completions all
  assert_success

  run bash-it disable all
  run _check-results-count completions
  assert_success
}

@test "bash-it helpers: _bash-it-describe: should list only enabled plugins" {

  run _check-results-count plugins enabled
  assert_failure
}

@test "bash-it helpers: _bash-it-describe: should list only enabled aliases" {

  run _check-results-count aliases enabled
  assert_failure
}


@test "bash-it helpers: _bash-it-describe: should list only enabled completions" {

  run _check-results-count completion enabled
  assert_failure
}
