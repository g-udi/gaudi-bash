#!/usr/bin/env bats
# shellcheck shell=bats
# shellcheck disable=SC2329,SC2030,SC2031

load "$GAUDI_TEST_DIRECTORY"/helper.bash

# Writes a component that only exists for these tests
# $1: type (aliases, plugins, completions), $2: name, $3: description
__fixture_component() {
	local about="about-${1%s}"

	[[ "$1" == "aliases" ]] && about="about-alias"
	printf "%s\n" "# shellcheck shell=bash" "cite $about" "$about '$3'" > "$GAUDI_BASH/components/$1/lib/$2.$1.bash"
}

local_setup() {
	load_gaudi_libs gaudi-bash search

	# The search runs on components made for these tests, so the expectations do not depend on the real component lists
	rm -f "$GAUDI_BASH"/components/{aliases,plugins,completions}/lib/*.bash

	__fixture_component aliases bundler "ruby bundler shortcuts"
	__fixture_component aliases git "common git abbreviations"
	__fixture_component aliases gitsvn "git svn bridge abbreviations"
	__fixture_component aliases rails "rails framework for ruby"

	__fixture_component plugins base "miscellaneous tools"
	__fixture_component plugins chruby "load chruby, a ruby version switcher"
	__fixture_component plugins docker "helpers to easily manage docker containers"
	__fixture_component plugins git "git helper functions"
	__fixture_component plugins ruby "ruby and rubygems helpers"
	__fixture_component plugins zoxide "a smarter cd command"

	__fixture_component completions gem "rubygems completion"
	__fixture_component completions git "git completion"
	__fixture_component completions go "go completion"
	__fixture_component completions rake "rake completion"
}

@test "gaudi-bash search: search should not return anything for unknown components" {

	run _gaudi-bash-search-component "plugins" "UNKNOWN" --no-color
	assert_failure
	run _gaudi-bash-search-component "aliases" "UNKNOWN" --no-color
	assert_failure
	run _gaudi-bash-search-component "completions" "UNKNOWN" --no-color
	assert_failure
}

@test "gaudi-bash search: search should fail and say so when nothing matches" {

	run _gaudi-bash-search "UNKNOWN" --no-color
	assert_failure
	assert_output "No components match your search"

	run _gaudi-bash-search "zoxide" --completion --no-color
	assert_failure
	assert_output "No components match your search"
}

@test "gaudi-bash search: search should succeed when only one of the component types has a match" {

	# Only a plugin matches: the last type searched (completions) has nothing
	run _gaudi-bash-search "zoxide" --no-color
	assert_success
	assert_output "plugins:	zoxide	"

	run _gaudi-bash-search "bundler" --no-color
	assert_success
	assert_output "aliases:	bundler	"
}

@test "gaudi-bash search: search for a specific component should return only relevant results" {

	run _gaudi-bash-search "ruby" --plugin --no-color
	assert_success
	assert_output "plugins:	chruby	ruby	"

	run _gaudi-bash-search "ruby" -a --no-color
	assert_output "aliases:	bundler	rails	"

	run _gaudi-bash-search "go" -c --no-color
	assert_output "completions:	go	"
}

@test "gaudi-bash search: search for a component should return correct results with correct status for enabled ones" {

	run _gaudi-bash-enable plugin base
	run _gaudi-bash-search "base" --plugin --no-color
	assert_line --index 0 "plugins:	base ✓	"

	run _gaudi-bash-search "ruby" --plugin --no-color
	assert_line --index 0 "plugins:	chruby	ruby	"

	run _gaudi-bash-enable completion go
	run _gaudi-bash-search "go" -c --no-color
	assert_line --index 0 "completions:	go ✓	"
}

@test "gaudi-bash search: single term search should return correct results across all components" {

	run _gaudi-bash-search "git" --no-color
	assert_success
	assert_line --index 0 "aliases:	git	gitsvn	"
	assert_line --index 1 "plugins:	git	"
	assert_line --index 2 "completions:	git	"
}

@test "gaudi-bash search: multi term search should return correct results across all components" {

	run _gaudi-bash-search ruby rake --no-color
	assert_line --index 0 "aliases:	bundler	rails	"
	assert_line --index 1 "plugins:	chruby	ruby	"
	assert_line --index 2 "completions:	gem	rake	"
}

@test "gaudi-bash search: search should exclude any results passed with -" {

	run _gaudi-bash-search ruby rake -chruby -gem --no-color
	assert_line --index 0 "aliases:	bundler	rails	"
	assert_line --index 1 "plugins:	ruby	"
	assert_line --index 2 "completions:	rake	"
}

@test "gaudi-bash search: search should fully match a search term using @" {

	run _gaudi-bash-enable completion git
	run _gaudi-bash-search "@git" --no-color
	assert_line --index 0 "aliases:	git	"
	assert_line --index 1 "plugins:	git	"
	assert_line --index 2 "completions:	git ✓	"

	run _gaudi-bash-search "g" -c --no-color
	assert_line --index 0 "completions:	gem	git ✓	go	"

	run _gaudi-bash-search "@go" -c --no-color
	assert_line --index 0 "completions:	go	"
}

@test "gaudi-bash search: search should not return words of the show usage text as components" {

	# "easily" is part of the usage text printed under the `gbash show` table, only the docker plugin is described with it
	run _gaudi-bash-search "easily" --no-color
	assert_success
	assert_output "plugins:	docker	"
}

@test "gaudi-bash search: search should use every term, also when the first one is empty" {

	run _gaudi-bash-search "" "ruby" --plugin --no-color
	assert_line --index 0 "plugins:	chruby	ruby	"
}

@test "gaudi-bash search: the search help names components that exist" {

	local name

	run _gaudi-bash-search --help
	assert_success
	assert_output --partial "gbash search [-|@]term1"

	# The examples of the help (and of the comment above the function) are about the components gaudi-bash ships
	for name in chruby-auto git_flow_avh; do
		run grep -c "$name" "$GAUDI_BASH/lib/search.bash"
		assert_output "0"
	done
}

@test "gaudi-bash search: search --enable and --disable should act in the current shell and reload once" {

	GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1
	_gaudi-bash-reload() { echo "RELOADED"; }

	run _gaudi-bash-search "@git" "@ruby" --plugin --enable --no-color
	assert_success
	assert_file_exist "$GAUDI_BASH/components/enabled/250___git.plugins.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/250___ruby.plugins.bash"
	assert_equal "$(grep -c "^RELOADED$" <<< "$output")" 1
	assert_line "plugins:	git ✓	ruby ✓	"

	# The disable callback of a plugin has to run in the shell the search was started from
	git_on_disable() { GAUDI_TEST_GIT_DISABLED=true; }

	_gaudi-bash-search "@git" --plugin --disable --no-color > /dev/null
	assert_file_not_exist "$GAUDI_BASH/components/enabled/250___git.plugins.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/250___ruby.plugins.bash"
	assert_equal "${GAUDI_TEST_GIT_DISABLED:-}" "true"
	assert_equal "$GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE" 1
}
