#!/usr/bin/env bats

load ../helper

load ../../lib/composure

cite about param example group

load ../../lib/helpers
load ../../lib/helpers/bash-it
load ../../lib/helpers/components

local_setup () {
  prepare

  # Copy the test fixture to the bash-it folder
  if command -v rsync &> /dev/null
  then
    rsync -a "$BASH_IT/test/fixtures/bash_it/" "$BASH_IT/"
  else
    find "$BASH_IT/test/fixtures/bash_it" \
      -mindepth 1 -maxdepth 1 \
      -exec cp -r {} "$BASH_IT/" \;
  fi
}

# @test "bash-it helpers: _bash-it-component-help: should display components help" {
#   # should fail when no component is passed
#   run _bash-it-component-help
#   assert_failure

#   # should display plugins help
#   run _bash-it-component-help plugin
#   assert_success
#   assert_output --partial "base                  [ ]     miscellaneous tools"

# }

@test "bash-it helpers: components: _bash-it-pluralize-component: should pluralise the argument" {

  run  _bash-it-pluralize-component "alias"
  assert_success
  assert_output "aliases"

  run  _bash-it-pluralize-component "aliases"
  assert_success
  assert_output "aliases"

  run  _bash-it-pluralize-component "plugin"
  assert_success
  assert_output "plugins"

  run  _bash-it-pluralize-component "plugins"
  assert_success
  assert_output "plugins"

  run  _bash-it-pluralize-component "completion"
  assert_success
  assert_output "completions"
}

@test "bash-it helpers: components: _bash-it-singularize-component: should singularize the argument" {

  run  _bash-it-singularize-component "aliases"
  assert_success
  assert_output "alias"

  run  _bash-it-singularize-component "alias"
  assert_success
  assert_output "alias"

  run  _bash-it-singularize-component "plugins"
  assert_success
  assert_output "plugin"

  run  _bash-it-singularize-component "completions"
  assert_success
  assert_output "completion"
}
# @test "bash-it helpers: _bash-it-component-item-is-enabled: should check enabled component" {

#   mkdir -p $BASH_IT/aliases/enabled

#   ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/enabled/150---a.aliases.bash
#   assert_link_exist "$BASH_IT/enabled/150---a.aliases.bash"

#   load "$BASH_IT/bash_it.sh"

#   # run alias test_alias &> /dev/null
#   # assert_success
#   # assert_line -n 0 "alias test_alias='a'"

#   run _bash-it-component-item-is-enabled alias test_alias && echo "test_alias is enabled"
#   assert_success
#   assert_output "test_alias is enabled"

# }

# # @test "bash-it helpers: _bash-it-component-item-is-disabled: should check disabled component" {

# #   mkdir -p $BASH_IT/aliases/enabled

# #   ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/aliases/enabled/150---a.aliases.bash
# #   assert_link_exist "$BASH_IT/aliases/enabled/150---a.aliases.bash"
# #   ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/aliases/enabled/150---b.aliases.bash
# #   assert_link_exist "$BASH_IT/aliases/enabled/150---b.aliases.bash"

# #   # The `test_alias` alias should not exist
# #   run alias test_alias &> /dev/null
# #   assert_failure

# #   load "$BASH_IT/bash_it.sh"

# #   run alias test_alias &> /dev/null
# #   assert_success
# #   assert_line -n 0 "alias test_alias='b'"
# # }


# has_match () {
#   $(_array-contains ${@}) && echo "has" "$1"
# }

# item_enabled () {
#   $(_bash-it-component-item-is-enabled ${@}) && echo "$1" "$2" "is enabled"
# }

# item_disabled () {
#   $(_bash-it-component-item-is-disabled ${@}) && echo "$1" "$2" "is disabled"
# }

# @test "_bash-it-component-item-is-enabled() - for a disabled item" {
#   run item_enabled aliases svn
#   assert_line -n 0 ''
# }

# @test "_bash-it-component-item-is-enabled() - for an enabled/disabled item" {
#   run bash-it enable alias svn
#   assert_line -n 0 '[● ENABLED] alias: svn enabled with priority (150)'

#   run item_enabled alias svn
#   assert_line -n 0 'alias svn is enabled'

#   run bash-it disable alias svn
#   assert_line -n 0 'svn disabled.'

#   run item_enabled alias svn
#   assert_line -n 0 ''
# }

# @test "_bash-it-component-item-is-disabled() - for a disabled item" {
#   run item_disabled alias svn
#   assert_line -n 0 'alias svn is disabled'
# }

# @test "_bash-it-component-item-is-disabled() - for an enabled/disabled item" {
#   run bash-it enable alias svn
#   assert_line -n 0 '[● ENABLED] alias: svn enabled with priority (150)'

#   run item_disabled alias svn
#   assert_line -n 0 ''

#   run bash-it disable alias svn
#   assert_line -n 0 'svn disabled.'

#   run item_disabled alias svn
#   assert_line -n 0 'alias svn is disabled'
# }

# @test "_array-contains() - when match is found, and is the first" {
#   declare -a fruits=(apple pear orange mandarin)
#   run has_match apple "${fruits[@]}"
#   assert_line -n 0 'has apple'
# }

# @test "_array-contains() - when match is found, and is the last" {
#   declare -a fruits=(apple pear orange mandarin)
#   run has_match mandarin "${fruits[@]}"
#   assert_line -n 0 'has mandarin'
# }

# @test "_array-contains() - when match is found, and is in the middle" {
#   declare -a fruits=(apple pear orange mandarin)
#   run has_match pear "${fruits[@]}"
#   assert_line -n 0 'has pear'
# }

# @test "_array-contains() - when match is found, and it has spaces" {
#   declare -a fruits=(apple pear orange mandarin "yellow watermelon")
#   run has_match "yellow watermelon" "${fruits[@]}"
#   assert_line -n 0 'has yellow watermelon'
# }

# @test "_array-contains() - when match is not found" {
#   declare -a fruits=(apple pear orange mandarin)
#   run has_match xyz "${fruits[@]}"
#   assert_line -n 0 ''
# }
