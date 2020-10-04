#!/usr/bin/env bats

load ../helper

load ../../lib/composure

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

# @test "core: verify that the test fixture is available" {
#   assert_file_exist "$BASH_IT/aliases/available/a.aliases.bash"
#   assert_file_exist "$BASH_IT/aliases/available/b.aliases.bash"
# }

# @test "core: load aliases in order" {

#   mkdir -p $BASH_IT/enabled
#   mkdir -p $BASH_IT/enabled

#   ln -s $BASH_IT/plugins/available/base.plugin.bash "$BASH_IT/enabled/250|base.plugin.bash"
#   assert_link_exist "$BASH_IT/enabled/250|base.plugin.bash"

#   ln -s $BASH_IT/aliases/available/a.aliases.bash "$BASH_IT/enabled/150|a.aliases.bash"
#   assert_link_exist "$BASH_IT/enabled/150|a.aliases.bash"

#   ln -s $BASH_IT/aliases/available/b.aliases.bash "$BASH_IT/enabled/150|b.aliases.bash"
#   assert_link_exist "$BASH_IT/enabled/150|b.aliases.bash"

#   # The `test_alias` alias should not exist
#   run alias test_alias &> /dev/null
#   assert_failure

#   load "$BASH_IT/bash_it.sh"

#   run alias test_alias &> /dev/null
#   assert_success
#   assert_line -n 0 "alias test_alias='b'"
# }

# @test "core: load aliases in priority order" {
#   mkdir -p $BASH_IT/enabled
#   mkdir -p $BASH_IT/enabled

#   ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/enabled/250|base.plugin.bash
#   assert_link_exist "$BASH_IT/enabled/250|base.plugin.bash"

#   ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/enabled/175|a.aliases.bash
#   assert_link_exist "$BASH_IT/enabled/175|a.aliases.bash"

#   ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/enabled/150|b.aliases.bash
#   assert_link_exist "$BASH_IT/enabled/150|b.aliases.bash"

#   # The `test_alias` alias should not exist
#   run alias test_alias &> /dev/null
#   assert_failure

#   load "$BASH_IT/bash_it.sh"

#   run alias test_alias &> /dev/null
#   assert_success
#   assert_line -n 0 "alias test_alias='a'"
# }

# @test "core: load aliases and plugins in priority order" {
#   mkdir -p $BASH_IT/enabled

#   ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/enabled/250|base.plugin.bash
#   assert_link_exist "$BASH_IT/enabled/250|base.plugin.bash"

#   ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/enabled/150|a.aliases.bash
#   assert_link_exist "$BASH_IT/enabled/150|a.aliases.bash"

#   ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/enabled/150|b.aliases.bash
#   assert_link_exist "$BASH_IT/enabled/150|b.aliases.bash"

#   ln -s $BASH_IT/plugins/available/c.plugin.bash $BASH_IT/enabled/250|c.plugin.bash
#   assert_link_exist "$BASH_IT/enabled/250|c.plugin.bash"

#   # The `test_alias` alias should not exist
#   run alias test_alias &> /dev/null
#   assert_failure

#   load "$BASH_IT/bash_it.sh"

#   run alias test_alias &> /dev/null
#   assert_success
#   assert_line -n 0 "alias test_alias='c'"
# }

# @test "core: load aliases, plugins and completions in priority order" {
#   mkdir -p $BASH_IT/enabled

#   ln -s $BASH_IT/plugins/available/base.plugin.bash "$BASH_IT/enabled/250|base.plugin.bash"
#   assert_link_exist "$BASH_IT/enabled/250|base.plugin.bash"

#   ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/enabled/150|a.aliases.bash
#   assert_link_exist "$BASH_IT/enabled/150|a.aliases.bash"

#   ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/enabled/350|b.completion.bash
#   assert_link_exist "$BASH_IT/enabled/350|b.completion.bash"

#   ln -s $BASH_IT/plugins/available/c.plugin.bash $BASH_IT/enabled/250|c.plugin.bash
#   assert_link_exist "$BASH_IT/enabled/250|c.plugin.bash"

#   # The `test_alias` alias should not exist
#   run alias test_alias &> /dev/null
#   assert_failure

#   load "$BASH_IT/bash_it.sh"

#   run alias test_alias &> /dev/null
#   assert_success
#   # "b" wins since completions are loaded last in the old directory structure
#   assert_line -n 0 "alias test_alias='b'"
# }

# @test "core: load aliases, plugins and completions in priority order, even if the priority says otherwise" {
#   mkdir -p $BASH_IT/enabled

#   ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/enabled/250|base.plugin.bash
#   assert_link_exist "$BASH_IT/enabled/250|base.plugin.bash"

#   ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/enabled/450|a.aliases.bash
#   assert_link_exist "$BASH_IT/enabled/450|a.aliases.bash"

#   ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/enabled/350|b.completion.bash
#   assert_link_exist "$BASH_IT/enabled/350|b.completion.bash"

#   ln -s $BASH_IT/plugins/available/c.plugin.bash $BASH_IT/enabled/950|c.plugin.bash
#   assert_link_exist "$BASH_IT/enabled/950|c.plugin.bash"

#   # The `test_alias` alias should not exist
#   run alias test_alias &> /dev/null
#   assert_failure

#   load "$BASH_IT/bash_it.sh"

#   run alias test_alias &> /dev/null
#   assert_success
#   # "b" wins since completions are loaded last in the old directory structure
#   assert_line -n 0 "alias test_alias='b'"
# }

# @test "core: load aliases and plugins in priority order, with one alias higher than plugins" {
#   mkdir -p $BASH_IT/enabled

#   ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/enabled/250|base.plugin.bash
#   assert_link_exist "$BASH_IT/enabled/250|base.plugin.bash"

#   ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/enabled/350|a.aliases.bash
#   assert_link_exist "$BASH_IT/enabled/350|a.aliases.bash"

#   ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/enabled/150|b.aliases.bash
#   assert_link_exist "$BASH_IT/enabled/150|b.aliases.bash"

#   ln -s $BASH_IT/plugins/available/c.plugin.bash $BASH_IT/enabled/250|c.plugin.bash
#   assert_link_exist "$BASH_IT/enabled/250|c.plugin.bash"

#   # The `test_alias` alias should not exist
#   run alias test_alias &> /dev/null
#   assert_failure

#   load "$BASH_IT/bash_it.sh"

#   run alias test_alias &> /dev/null
#   assert_success
#   # This will be c, loaded from the c plugin, since the individual directories
#   # are loaded one by one.
#   assert_line -n 0 "alias test_alias='c'"
# }

@test "core: koko" {

  bash-it enable plugin base &> /dev/null
  assert_success
  bash-it enable plugin base >&2
ls "$BASH_IT/enabled"  >&2
  assert_link_exist "$BASH_IT/enabled/250|base.plugin.bash"
}
