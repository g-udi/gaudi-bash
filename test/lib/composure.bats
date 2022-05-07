#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

load "$GAUDI_BASH"/lib/composure.bash

cite about param example group priority

@test "gaudi-bash lib: composure: composure_keywords()" {

	run _composure_keywords
	assert_output "about author example group param version"
}
