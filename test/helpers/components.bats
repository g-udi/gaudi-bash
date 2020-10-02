# #!/usr/bin/env bats

# load ../helper

# load ../../lib/composure

# cite about param example group

# load ../../lib/helpers
# load ../../lib/helpers/bash-it
# load ../../lib/helpers/components

# local_setup () {
#   setup_test_fixture

#   # Copy the test fixture to the bash-it folder
#   if command -v rsync &> /dev/null
#   then
#     rsync -a "$BASH_IT/test/fixtures/bash_it/" "$BASH_IT/"
#   else
#     find "$BASH_IT/test/fixtures/bash_it" \
#       -mindepth 1 -maxdepth 1 \
#       -exec cp -r {} "$BASH_IT/" \;
#   fi
# }

# # echo "AAAAAA" >&2
# # _bash-it-component-help plugin
# # _bash-it-component-help alias >&2

# # _bash-it-component-help plugin >&2

# @test "bash-it helpers: _bash-it-component-help: should display components help" {
#   # should fail when no component is passed
#   run _bash-it-component-help
#   assert_failure

#   # should display plugins help
#   run _bash-it-component-help plugin
#   assert_success
#   assert_output --partial "base                  [ ]     miscellaneous tools"

# }

# @test "bash-it helpers: _bash-it-pluralize-component: should pluralise the argument" {

#   run  _bash-it-pluralize-component "alias"
#   assert_success
#   assert_output "aliases"

#   run  _bash-it-pluralize-component "plugin"
#   assert_success
#   assert_output "plugins"

#   run  _bash-it-pluralize-component "completion"
#   assert_success
#   assert_output "completions"
# }

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
