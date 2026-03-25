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

@test "gaudi-bash helpers: cache: _gaudi-bash-component-cache-add should return a new cache file in cache directory for a singular component" {

	run _gaudi-bash-component-cache-add alias
	assert_success
	assert_output "$GAUDI_BASH_CACHE_DIR/alias"
}

@test "gaudi-bash helpers: cache: _gaudi-bash-component-cache-add should return a new cache file in cache directory" {

	run _gaudi-bash-component-cache-add plugins
	assert_success
	assert_output "$GAUDI_BASH_CACHE_DIR/plugins"
}

@test "gaudi-bash helpers: cache: _gaudi-bash-component-cache-add should create a cache folder" {

	run _gaudi-bash-component-cache-add plugins
	assert_success
	assert_output "$GAUDI_BASH_CACHE_DIR/plugins"
	assert_dir_exist "$GAUDI_BASH_CACHE_DIR"
}

@test "gaudi-bash helpers: cache: _gaudi-bash-component-cache-clean should clear the cache folder" {

	_plugins_cache=$(_gaudi-bash-component-cache-add plugins)
	_aliases_cache=$(_gaudi-bash-component-cache-add aliases)

	touch "${_plugins_cache}"
	touch "${_aliases_cache}"

	assert_file_exist "$GAUDI_BASH_CACHE_DIR/plugins"
	assert_file_exist "$GAUDI_BASH_CACHE_DIR/aliases"

	_gaudi-bash-component-cache-clean
	assert_dir_exist "$GAUDI_BASH_CACHE_DIR"
	assert_file_not_exist "$GAUDI_BASH_CACHE_DIR/plugins"
	assert_file_not_exist "$GAUDI_BASH_CACHE_DIR/aliases"
}
