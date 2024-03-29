#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	load_gaudi_libs components cache
}

@test "gaudi-bash helpers: cache: _gaudi-bash-component-cache-add should fail if no component type was passed" {

	run _gaudi-bash-component-cache-add
	assert_failure
}

@test "gaudi-bash helpers: cache: _gaudi-bash-component-cache-add should return a new cache file in /tmp directory for a singular component" {

	run _gaudi-bash-component-cache-add alias
	assert_success
	assert_output "$GAUDI_BASH/tmp/cache/alias"
}

@test "gaudi-bash helpers: cache: _gaudi-bash-component-cache-add should return a new cache file in /tmp directory" {

	run _gaudi-bash-component-cache-add plugins
	assert_success
	assert_output "$GAUDI_BASH/tmp/cache/plugins"
}

@test "gaudi-bash helpers: cache: _gaudi-bash-component-cache-add should create a cache folder" {

	run _gaudi-bash-component-cache-add plugins
	assert_success
	assert_output "$GAUDI_BASH/tmp/cache/plugins"
	assert_dir_exist "$GAUDI_BASH/tmp/cache"
}

@test "gaudi-bash helpers: cache: _gaudi-bash-component-cache-clean should clear the cache folder" {

	_plugins_cache=$(_gaudi-bash-component-cache-add plugins)
	_aliases_cache=$(_gaudi-bash-component-cache-add aliases)

	touch "${_plugins_cache}"
	touch "${_aliases_cache}"

	assert_file_exist "$GAUDI_BASH/tmp/cache/plugins"
	assert_file_exist "$GAUDI_BASH/tmp/cache/aliases"

	_gaudi-bash-component-cache-clean
	assert_dir_exist "$GAUDI_BASH/tmp/cache"
	assert_file_not_exist "$GAUDI_BASH/tmp/cache/plugins"
	assert_file_not_exist "$GAUDI_BASH/tmp/cache/aliases"
}
