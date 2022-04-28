#!/usr/bin/env bats

load ../helper

load ../../lib/composure

cite about param example group priority

load ../../lib/gaudi-bash
load ../../lib/search

local_setup () {
  prepare

  cd "$GAUDI_BASH"
  ./setup.sh --silent
}

@test "gaudi-bash search: search for a component should return correct results with correct status for enabled ones" {

  run _gaudi-bash-search "plugins" "base" --no-color
  assert_output --partial "plugins:  base ✓  gaudi-bash"
}

@test "gaudi-bash search: single term search should return correct results across all components" {

  run _gaudi-bash-disable completion git &>/dev/null
  run _gaudi-bash-search "git" --no-color

  assert_line --index 0 --regexp "[ \t]+aliases:[ \t]+git[ \t]+gitsvn"
  for plugin in "autojump" "git" "gitstatus" "git-subrepo" "jgitflow" "jump"
  do
    assert_line --index 1 --partial $plugin
  done
  assert_line --index 2 --regexp "[ \t]+completions:[ \t]+git[ \t]+git_extras[ \t]+git_flow[ \t]+git_flow_avh"
}

@test "gaudi-bash search: multi term search should return correct results across all components" {

  run _gaudi-bash-search rails ruby gem bundler rake --no-color
  assert_line --index 0 "      aliases:  bundler   rails  "
  assert_line --index 1 "      plugins:  chruby   ruby  "
  assert_line --index 2 "  completions:  bundler   gem   rake  "
}

@test "gaudi-bash search: search should exclude any results passed with -" {

  run _gaudi-bash-search rails ruby gem bundler rake -chruby --no-color
  assert_line --index 0 "      aliases:  bundler   rails  "
  assert_line --index 1 "      plugins:  ruby  "
  assert_line --index 2 "  completions:  bundler   gem   rake  "
}

@test "gaudi-bash search: search should fully match a search term using @" {

  run _gaudi-bash-search "@git" --no-color
  assert_line --index 0 "      aliases:  git  "
  assert_line --index 1 "      plugins:  git  "
  assert_line --index 2 "  completions:  git ✓ "
}

@test "gaudi-bash search: search should be able to enable/disable search results" {

  set -e
  run _gaudi-bash-search "@git" --enable --no-color
  run _gaudi-bash-search "@git" --no-color
  [[ "${lines[0]}"  =~ "✓" ]]

  run _gaudi-bash-search "@git" --disable --no-color
  run _gaudi-bash-search "@git" --no-color
  assert_line --index 0 "      aliases:  git  "
  assert_line --index 0 "      aliases:  git  "
  assert_line --index 2 "  completions:  git  "
}
