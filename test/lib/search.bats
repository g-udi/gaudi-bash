#!/usr/bin/env bats

load ../helper

load ../../lib/composure

cite about param example group

load ../../lib/bash-it
load ../../lib/search

local_setup () {
  prepare

  cd "$BASH_IT"
  ./setup.sh --silent
}

@test "bash-it search: search for a component should return correct results with correct status for enabled ones" {

  run _bash-it-search "plugins" "base" --no-color
  assert_output -p "plugins:  base ✓  bash-it"
}

@test "bash-it search: single term search should return correct results across all components" {

  run _bash-it-disable completion git &>/dev/null
  run _bash-it-search "git" --no-color

  assert_line -n 0 -e "[ \t]+aliases:[ \t]+git[ \t]+gitsvn"
  for plugin in "autojump" "git" "gitstatus" "git-subrepo" "jgitflow" "jump"
  do
    assert_line -n 1 -p $plugin
  done
  assert_line -n 2 -e "[ \t]+completions:[ \t]+git[ \t]+git_extras[ \t]+git_flow[ \t]+git_flow_avh"
}

@test "bash-it search: multi term search should return correct results across all components" {

  run _bash-it-search rails ruby gem bundler rake --no-color
  assert_line -n 0 "      aliases:  bundler   rails  "
  assert_line -n 1 "      plugins:  chruby   ruby  "
  assert_line -n 2 "  completions:  bundler   gem   rake  "
}

@test "bash-it search: search should exclude any results passed with -" {

  run _bash-it-search rails ruby gem bundler rake -chruby --no-color
  assert_line -n 0 "      aliases:  bundler   rails  "
  assert_line -n 1 "      plugins:  ruby  "
  assert_line -n 2 "  completions:  bundler   gem   rake  "
}

@test "bash-it search: search should fully match a search term using @" {

  run _bash-it-search "@git" --no-color
  assert_line -n 0 "      aliases:  git  "
  assert_line -n 1 "      plugins:  git  "
  assert_line -n 2 "  completions:  git ✓ "
}

@test "bash-it search: search should be able to enable/disable search results" {

  set -e
  run _bash-it-search "@git" --enable --no-color
  run _bash-it-search "@git" --no-color
  [[ "${lines[0]}"  =~ "✓" ]]

  run _bash-it-search "@git" --disable --no-color
  run _bash-it-search "@git" --no-color
  assert_line -n 0 "      aliases:  git  "
  assert_line -n 0 "      aliases:  git  "
  assert_line -n 2 "  completions:  git  "
}
