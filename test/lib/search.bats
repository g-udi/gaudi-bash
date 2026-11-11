#!/usr/bin/env bats
# shellcheck shell=bats
# shellcheck disable=SC2329,SC2030,SC2031

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	load_gaudi_libs gaudi-bash search

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
}

@test "gaudi-bash search: search for a specific component should return only relevant results" {

	run _gaudi-bash-search "ruby" --plugin --no-color
	assert_line --index 0 "plugins:	chruby	rails	rbenv	ruby	rvm	"

	run _gaudi-bash-search "ruby" -a --no-color
	assert_line --index 0 "aliases:	bundler	rails	"

	run _gaudi-bash-search "go" -c --no-color
	assert_line --index 0 "completions:	cargo	gcloud	go	"

}

@test "gaudi-bash search: search for a specific component should return fail if no relevant results found" {

	run _gaudi-bash-search "ruby" --plugin --no-color
	assert_line --index 0 "plugins:	chruby	rails	rbenv	ruby	rvm	"

}

@test "gaudi-bash search: search for a component should return correct results with correct status for enabled ones" {

	run _gaudi-bash-search "base" --plugin --no-color
	assert_line --index 0 "plugins:	base ✓	"

	run _gaudi-bash-search "ruby" --plugin --no-color
	assert_line --index 0 "plugins:	chruby	rails	rbenv	ruby	rvm	"

	run _gaudi-bash-enable completion go &> /dev/null
	run _gaudi-bash-search "go" -c --no-color

	assert_line --index 0 "completions:	cargo	gcloud	go ✓	"

}

@test "gaudi-bash search: single term search should return correct results across all components" {

	run _gaudi-bash-disable completion git &> /dev/null
	run _gaudi-bash-search "git" --no-color

	assert_line --index 0 "aliases:	git	gitsvn	"
	for plugin in "autojump" "git" "gitstatus" "git-subrepo" "jgitflow" "jump"; do
		assert_line --index 1 --partial $plugin
	done
	assert_line --index 2 "completions:	git	git_flow	github-cli	hub	virsh	"
}

@test "gaudi-bash search: multi term search should return correct results across all components" {

	run _gaudi-bash-search rails ruby gem bundler rake --no-color
	assert_line --index 0 "aliases:	bundler	rails	"
	assert_line --index 1 "plugins:	chruby	goenv	pyenv	rails	rbenv	ruby	rvm	"
	assert_line --index 2 "completions:	bundler	gem	rake	"
}

@test "gaudi-bash search: search should exclude any results passed with -" {

	run _gaudi-bash-search rails ruby gem bundler rake -chruby --no-color
	assert_line --index 0 "aliases:	bundler	rails	"
	assert_line --index 1 "plugins:	goenv	pyenv	rails	rbenv	ruby	rvm	"
	assert_line --index 2 "completions:	bundler	gem	rake	"
}

@test "gaudi-bash search: search should fully match a search term using @" {

	run _gaudi-bash-enable completion git &> /dev/null
	run _gaudi-bash-search "@git" --no-color
	assert_line --index 0 "aliases:	git	"
	assert_line --index 1 "plugins:	git	"
	assert_line --index 2 "completions:	git ✓	"

	run _gaudi-bash-search "go" -c --no-color
	assert_line --index 0 "completions:	cargo	gcloud	go	"

	run _gaudi-bash-search "@go" -c --no-color
	assert_line --index 0 "completions:	go	"
}

@test "gaudi-bash search: search should not return words of the show usage text as components" {

	# "easily" is part of the usage text printed under the `gbash show` table, only the docker plugin is described with it
	run _gaudi-bash-search "easily" --no-color
	assert_output "plugins:	docker	"
}

@test "gaudi-bash search: search should use every term, also when the first one is empty" {

	run _gaudi-bash-search "" "ruby" --plugin --no-color
	assert_line --index 0 "plugins:	chruby	rails	rbenv	ruby	rvm	"
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
