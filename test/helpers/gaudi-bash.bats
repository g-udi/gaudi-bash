#!/usr/bin/env bats
# shellcheck shell=bats

load ../helper
load ../../lib/composure

cite about param example group priority

load ../../lib/gaudi-bash
load ../../lib/helpers/components
load ../../lib/helpers/utils
load ../../lib/helpers/cache

export GAUDI_BASH_DESCRIPTION_MIN_LINE_COUNT=10

local_setup() {
	prepare
}

# Returns true if the no. lines for description is more than the GAUDI_BASH_DESCRIPTION_MIN_LINE_COUNT
_check-results-count() {
	[[ $(_gaudi-bash-describe "$1" "$2" | grep "^.*$" -c) -gt $GAUDI_BASH_DESCRIPTION_MIN_LINE_COUNT ]] && return 0
	return 1
}

@test "gaudi-bash helpers: _gaudi-bash-describe: should fail if no valid component was passed" {

	run _gaudi-bash-describe plugins
	assert_success

	run _gaudi-bash-describe
	assert_failure

	run _gaudi-bash-describe INVALID
	assert_failure

	run _gaudi-bash-describe completion
	assert_success
}

@test "gaudi-bash helpers: _gaudi-bash-describe: should fail if no valid mode was passed" {

	run _gaudi-bash-describe plugins
	assert_success

	run _gaudi-bash-describe plugins INVALID
	assert_failure

	run _gaudi-bash-describe plugins all
	assert_success

	run _gaudi-bash-describe completion enabled
	assert_success
}

@test "gaudi-bash helpers: _gaudi-bash-describe: should display proper table headers" {

	# Should display plugins help (we are piping to sed to remove redundant white spaces for consistency)
	_get-description-header() {
		_gaudi-bash-describe "$1" | head -n 2 | sed 's/  */ /g'
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

@test "gaudi-bash helpers: _gaudi-bash-describe: should display a component name and description" {
	run _gaudi-bash-describe plugins
	assert_success
	assert_output --partial "base"
	assert_output --partial "miscellaneous tools"
}

@test "gaudi-bash helpers: _gaudi-bash-describe: should list all plugins (enabled/disabled)" {

	run _check-results-count plugins
	assert_success

	run _check-results-count plugin all
	assert_success

	run gaudi-bash disable plugins all
	run _check-results-count plugins
	assert_success
}

@test "gaudi-bash helpers: _gaudi-bash-describe: should list all aliases (enabled/disabled)" {

	run _check-results-count aliases
	assert_success
	run _check-results-count alias all
	assert_success

	run gaudi-bash disable all
	run _check-results-count aliases
	assert_success
}

@test "gaudi-bash helpers: _gaudi-bash-describe: should list all completions (enabled/disabled)" {

	run _check-results-count completion
	assert_success
	run _check-results-count completions all
	assert_success

	run gaudi-bash disable all
	run _check-results-count completions
	assert_success
}

@test "gaudi-bash helpers: _gaudi-bash-describe: should list only enabled plugins" {

	run _check-results-count plugins enabled
	assert_failure
}

@test "gaudi-bash helpers: _gaudi-bash-describe: should list only enabled aliases" {

	run _check-results-count aliases enabled
	assert_failure
}

@test "gaudi-bash helpers: _gaudi-bash-describe: should list only enabled completions" {

	run _check-results-count completion enabled
	assert_failure
}
