#!/usr/bin/env bats

load ../helper

load ../../lib/composure

cite about group

load ../../lib/helpers
load ../../lib/helpers/cache
load ../../lib/helpers/components
load ../../lib/helpers/utils
load ../../lib/helpers/enabler

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

@test "bash-it helpers: _bash-it-enable: verify that the test fixture is available" {
  assert_file_exist "$BASH_IT/aliases/a.aliases.bash"
  assert_file_exist "$BASH_IT/aliases/b.aliases.bash"
}

@test "bash-it helpers: _bash-it-enable: should fail if no valid component type was passed" {
  run _bash-it-enable
  assert_failure
  assert_output --partial "Please enter a valid component to enable"
}

@test "bash-it helpers: _bash-it-enable: should fail if no valid component was passed" {
  run _bash-it-enable plugin
  assert_failure
  assert_output --partial "Please enter a valid plugin(s) to enable"
}

@test "bash-it helpers: _bash-it-enable: should fail if component was not found" {
  run _bash-it-enable plugin INVALID
  assert_failure
  assert_output --partial "INVALID"
  assert_output --partial "does not appear to be an available plugin"
}

@test "bash-it helpers: _bash-it-enable: should display appropriate message when trying to enable an already enabled component" {
  run _bash-it-enable plugin base
  assert_success
  assert_output --partial "base is already enabled"
  assert_file_exist "$BASH_IT/components/enabled/250___base.plugins.bash"
}

# @test "bash-it helpers: _bash-it-enable: should successfully enable a component" {
#   run _bash-it-enable plugin git
#   assert_success
#   assert_output --partial "git enabled with priority (250)"
#   assert_file_exist "$BASH_IT/components/enabled/250___git.plugins.bash"
#   run _bash-it-disable git
# }

# @test "core: load aliases in order" {

#   mkdir -p $BASH_IT/enabled
#   mkdir -p $BASH_IT/enabled

#   ln -s $BASH_IT/plugins/available/base.plugin.bash "$BASH_IT/enabled/250___base.plugin.bash"
#   assert_link_exist "$BASH_IT/enabled/250___base.plugin.bash"

#   ln -s $BASH_IT/aliases/available/a.aliases.bash "$BASH_IT/enabled/150___a.aliases.bash"
#   assert_link_exist "$BASH_IT/enabled/150___a.aliases.bash"

#   ln -s $BASH_IT/aliases/available/b.aliases.bash "$BASH_IT/enabled/150___b.aliases.bash"
#   assert_link_exist "$BASH_IT/enabled/150___b.aliases.bash"

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

#   ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/enabled/250___base.plugin.bash
#   assert_link_exist "$BASH_IT/enabled/250___base.plugin.bash"

#   ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/enabled/175___a.aliases.bash
#   assert_link_exist "$BASH_IT/enabled/175___a.aliases.bash"

#   ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/enabled/150___b.aliases.bash
#   assert_link_exist "$BASH_IT/enabled/150___b.aliases.bash"

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

#   ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/enabled/250___base.plugin.bash
#   assert_link_exist "$BASH_IT/enabled/250___base.plugin.bash"

#   ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/enabled/150___a.aliases.bash
#   assert_link_exist "$BASH_IT/enabled/150___a.aliases.bash"

#   ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/enabled/150___b.aliases.bash
#   assert_link_exist "$BASH_IT/enabled/150___b.aliases.bash"

#   ln -s $BASH_IT/plugins/available/c.plugin.bash $BASH_IT/enabled/250___c.plugin.bash
#   assert_link_exist "$BASH_IT/enabled/250___c.plugin.bash"

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

#   ln -s $BASH_IT/plugins/available/base.plugin.bash "$BASH_IT/enabled/250___base.plugin.bash"
#   assert_link_exist "$BASH_IT/enabled/250___base.plugin.bash"

#   ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/enabled/150___a.aliases.bash
#   assert_link_exist "$BASH_IT/enabled/150___a.aliases.bash"

#   ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/enabled/350___b.completion.bash
#   assert_link_exist "$BASH_IT/enabled/350___b.completion.bash"

#   ln -s $BASH_IT/plugins/available/c.plugin.bash $BASH_IT/enabled/250___c.plugin.bash
#   assert_link_exist "$BASH_IT/enabled/250___c.plugin.bash"

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

#   ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/enabled/250___base.plugin.bash
#   assert_link_exist "$BASH_IT/enabled/250___base.plugin.bash"

#   ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/enabled/450___a.aliases.bash
#   assert_link_exist "$BASH_IT/enabled/450___a.aliases.bash"

#   ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/enabled/350___b.completion.bash
#   assert_link_exist "$BASH_IT/enabled/350___b.completion.bash"

#   ln -s $BASH_IT/plugins/available/c.plugin.bash $BASH_IT/enabled/950___c.plugin.bash
#   assert_link_exist "$BASH_IT/enabled/950___c.plugin.bash"

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

#   ln -s $BASH_IT/plugins/available/base.plugin.bash $BASH_IT/enabled/250___base.plugin.bash
#   assert_link_exist "$BASH_IT/enabled/250___base.plugin.bash"

#   ln -s $BASH_IT/aliases/available/a.aliases.bash $BASH_IT/enabled/350___a.aliases.bash
#   assert_link_exist "$BASH_IT/enabled/350___a.aliases.bash"

#   ln -s $BASH_IT/aliases/available/b.aliases.bash $BASH_IT/enabled/150___b.aliases.bash
#   assert_link_exist "$BASH_IT/enabled/150___b.aliases.bash"

#   ln -s $BASH_IT/plugins/available/c.plugin.bash $BASH_IT/enabled/250___c.plugin.bash
#   assert_link_exist "$BASH_IT/enabled/250___c.plugin.bash"

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
