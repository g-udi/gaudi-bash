#!/usr/bin/env bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

load "$GAUDI_BASH"/lib/composure.bash

cite about param example group priority

load "$GAUDI_BASH"/lib/gaudi-bash.bash
load "$GAUDI_BASH"/lib/search.bash

local_setup() {
	prepare

	cd "$GAUDI_BASH" || exit
	./setup.sh --silent
}

@test "gaudi-bash search: search should not return anything for unknown components" {

	run _gaudi-bash-search-component "plugins" "UNKOWN" --no-color
	assert_failure
	run _gaudi-bash-search-component "aliases" "UNKOWN" --no-color
	assert_failure
	run _gaudi-bash-search-component "completions" "UNKOWN" --no-color
	assert_failure
	run _gaudi-bash-search "UNKOWN" --no-color
	assert_failure
}

@test "gaudi-bash search: search for a specific component should return only relevant results" {

	run _gaudi-bash-search "ruby" --plugin --no-color
	assert_line --index 0 "plugins:	chruby	ruby	"

	run _gaudi-bash-search "ruby" --a --no-color
	assert_line --index 0 "aliases:	bundler	"

	run _gaudi-bash-search "apm" -c --no-color
	assert_line --index 0 "completions:	apm	"
}

@test "gaudi-bash search: search for a specific component should return fail if no relevant results found" {

	run _gaudi-bash-search "ruby" --plugin --no-color
	assert_line --index 0 "plugins:	chruby	ruby	"

	run _gaudi-bash-search "ruby" -c --no-color
	assert_failure
}

@test "gaudi-bash search: search for a component should return correct results with correct status for enabled ones" {

	run _gaudi-bash-search "base" --plugin --no-color
	assert_line --index 0 "plugins:	base ✓	"

	run _gaudi-bash-search "ruby" --plugin --no-color
	assert_line --index 0 "plugins:	chruby	ruby	"

	run _gaudi-bash-enable completion apm &> /dev/null
	run _gaudi-bash-search "apm" -c --no-color

	assert_line --index 0 "completions:	apm ✓	"

}

@test "gaudi-bash search: single term search should return correct results across all components" {

	run _gaudi-bash-disable completion git &> /dev/null
	run _gaudi-bash-search "git" --no-color

	assert_line --index 0 "aliases:	git	gitsvn	"
	for plugin in "autojump" "git" "gitstatus" "git-subrepo" "jgitflow" "jump"; do
		assert_line --index 1 --partial $plugin
	done
	assert_line --index 2 "completions:	git	git_extras	git_flow	git_flow_avh	"
}

@test "gaudi-bash search: multi term search should return correct results across all components" {

	run _gaudi-bash-search rails ruby gem bundler rake --no-color
	assert_line --index 0 "aliases:	bundler	rails	"
	assert_line --index 1 "plugins:	chruby	ruby	"
	assert_line --index 2 "completions:	bundler	gem	rake	"
}

@test "gaudi-bash search: search should exclude any results passed with -" {

	run _gaudi-bash-search rails ruby gem bundler rake -chruby --no-color
	assert_line --index 0 "aliases:	bundler	rails	"
	assert_line --index 1 "plugins:	ruby	"
	assert_line --index 2 "completions:	bundler	gem	rake	"
}

@test "gaudi-bash search: search should fully match a search term using @" {

	run _gaudi-bash-search "@git" --no-color
	assert_line --index 0 "aliases:	git	"
	assert_line --index 1 "plugins:	git	"
	assert_line --index 2 "completions:	git ✓	"
}
