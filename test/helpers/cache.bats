#!/usr/bin/env bats

load ../helper
load ../../lib/composure

cite about param example group

load ../../lib/helpers/components
load ../../lib/helpers/cache

local_setup () {
  prepare
}

@test "bash-it helpers: cache: _bash-it-component-cache-add should fail if no component type was passed" {

  run _bash-it-component-cache-add
  assert_failure
}

@test "bash-it helpers: cache: _bash-it-component-cache-add should return a new cache file in /tmp directory for a singular component" {

  run _bash-it-component-cache-add alias
  assert_success
  assert_output "$HOME/.bash_it/tmp/cache/alias"
}

@test "bash-it helpers: cache: _bash-it-component-cache-add should return a new cache file in /tmp directory" {

  run _bash-it-component-cache-add plugins
  assert_success
  assert_output "$HOME/.bash_it/tmp/cache/plugins"
}

@test "bash-it helpers: cache: _bash-it-component-cache-add should create a cache folder" {

  run _bash-it-component-cache-add plugins
  assert_success
  assert_output "$HOME/.bash_it/tmp/cache/plugins"
  assert_dir_exist "$HOME/.bash_it/tmp/cache"
}

@test "bash-it helpers: cache: _bash-it-component-cache-clean should clear the cache folder" {

  _plugins_cache=$(_bash-it-component-cache-add plugins)
  _aliases_cache=$(_bash-it-component-cache-add aliases)

  touch "${_plugins_cache}"
  touch "${_aliases_cache}"

  assert_file_exist "$HOME/.bash_it/tmp/cache/plugins"
  assert_file_exist "$HOME/.bash_it/tmp/cache/aliases"

  _bash-it-component-cache-clean
  assert_dir_exist "$HOME/.bash_it/tmp/cache"
  assert_file_not_exist "$HOME/.bash_it/tmp/cache/plugins"
  assert_file_not_exist "$HOME/.bash_it/tmp/cache/aliases"
}
