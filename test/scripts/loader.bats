#!/usr/bin/env bats

load ../helper

load ../../lib/composure

cite about param example group

local_setup () {
  prepare

  if command -v rsync &> /dev/null
  then
    rsync -a "$BASH_IT/test/fixtures/bash_it/" "$BASH_IT/components"
  else
    find "$BASH_IT/test/fixtures/bash_it" \
      -mindepth 1 -maxdepth 1 \
      -exec cp -r {} "$BASH_IT/" \;
  fi
}

@test "bash-it loader: load aliases in order" {

  mkdir -p $BASH_IT/components/enabled
  mkdir -p $BASH_IT/components/enabled

  ln -s $BASH_IT/components/plugins/lib/base.plugin.bash $BASH_IT/components/enabled/250___base.plugin.bash
  assert_link_exist "$BASH_IT/components/enabled/250___base.plugin.bash"

  ln -s $BASH_IT/components/aliases/lib/a.aliases.bash $BASH_IT/components/enabled/150___a.aliases.bash
  assert_link_exist "$BASH_IT/components/enabled/150___a.aliases.bash"

  ln -s $BASH_IT/components/aliases/lib/b.aliases.bash $BASH_IT/components/enabled/150___b.aliases.bash
  assert_link_exist "$BASH_IT/components/enabled/150___b.aliases.bash"

  run alias test_alias &> /dev/null
  assert_failure

  load "$BASH_IT/bash_it.sh"

  run alias test_alias &> /dev/null
  assert_success
  assert_line --index 0 "alias test_alias='b'"
}

@test "bash-it loader: load aliases in priority order" {
  mkdir -p $BASH_IT/enabled
  mkdir -p $BASH_IT/enabled

  ln -s $BASH_IT/components/plugins/lib/base.plugin.bash $BASH_IT/components/enabled/250___base.plugin.bash
  assert_link_exist "$BASH_IT/components/enabled/250___base.plugin.bash"

  ln -s $BASH_IT/components/aliases/lib/a.aliases.bash $BASH_IT/components/enabled/175___a.aliases.bash
  assert_link_exist "$BASH_IT/components/enabled/175___a.aliases.bash"

  ln -s $BASH_IT/components/aliases/lib/b.aliases.bash $BASH_IT/components/enabled/150___b.aliases.bash
  assert_link_exist "$BASH_IT/components/enabled/150___b.aliases.bash"

  run alias test_alias &> /dev/null
  assert_failure

  load "$BASH_IT/bash_it.sh"

  run alias test_alias &> /dev/null
  assert_success
  assert_line --index 0 "alias test_alias='a'"
}

@test "bash-it loader: load aliases and plugins in priority order" {
  mkdir -p $BASH_IT/enabled

  ln -s $BASH_IT/components/plugins/lib/base.plugin.bash $BASH_IT/components/enabled/250___base.plugin.bash
  assert_link_exist "$BASH_IT/components/enabled/250___base.plugin.bash"

  ln -s $BASH_IT/components/aliases/lib/a.aliases.bash $BASH_IT/components/enabled/150___a.aliases.bash
  assert_link_exist "$BASH_IT/components/enabled/150___a.aliases.bash"

  ln -s $BASH_IT/components/aliases/lib/b.aliases.bash $BASH_IT/components/enabled/150___b.aliases.bash
  assert_link_exist "$BASH_IT/components/enabled/150___b.aliases.bash"

  ln -s $BASH_IT/components/plugins/lib/c.plugin.bash $BASH_IT/components/enabled/250___c.plugin.bash
  assert_link_exist "$BASH_IT/components/enabled/250___c.plugin.bash"

  run alias test_alias &> /dev/null
  assert_failure

  load "$BASH_IT/bash_it.sh"

  run alias test_alias &> /dev/null
  assert_success
  assert_line --index 0 "alias test_alias='c'"
}

@test "bash-it loader: load aliases, plugins and completions in priority order" {
  mkdir -p $BASH_IT/enabled

  ln -s $BASH_IT/components/plugins/base.plugin.bash $BASH_IT/components/enabled/250___base.plugin.bash
  assert_link_exist "$BASH_IT/components/enabled/250___base.plugin.bash"

  ln -s $BASH_IT/components/aliases/lib/a.aliases.bash $BASH_IT/components/enabled/150___a.aliases.bash
  assert_link_exist "$BASH_IT/components/enabled/150___a.aliases.bash"

  ln -s $BASH_IT/components/aliases/lib/b.aliases.bash $BASH_IT/components/enabled/350___b.completion.bash
  assert_link_exist "$BASH_IT/components/enabled/350___b.completion.bash"

  ln -s $BASH_IT/components/plugins/c.plugin.bash $BASH_IT/components/enabled/250___c.plugin.bash
  assert_link_exist "$BASH_IT/components/enabled/250___c.plugin.bash"

  run alias test_alias &> /dev/null
  assert_failure

  load "$BASH_IT/bash_it.sh"

  run alias test_alias &> /dev/null
  assert_success
  assert_line --index 0 "alias test_alias='b'"
}

@test "bash-it loader: load aliases, plugins and completions in priority order with one alias priority higher than a plugin" {
  mkdir -p $BASH_IT/enabled

  ln -s $BASH_IT/components/plugins/lib/base.plugin.bash $BASH_IT/components/enabled/250___base.plugin.bash
  assert_link_exist "$BASH_IT/components/enabled/250___base.plugin.bash"

  ln -s $BASH_IT/components/aliases/lib/a.aliases.bash $BASH_IT/components/enabled/450___a.aliases.bash
  assert_link_exist "$BASH_IT/components/enabled/450___a.aliases.bash"

  ln -s $BASH_IT/components/aliases/lib/b.aliases.bash $BASH_IT/components/enabled/350___b.completion.bash
  assert_link_exist "$BASH_IT/components/enabled/350___b.completion.bash"

  ln -s $BASH_IT/components/plugins/lib/c.plugin.bash $BASH_IT/components/enabled/950___c.plugin.bash
  assert_link_exist "$BASH_IT/components/enabled/950___c.plugin.bash"

  run alias test_alias &> /dev/null
  assert_failure

  load "$BASH_IT/bash_it.sh"

  run alias test_alias &> /dev/null
  assert_success
  assert_line --index 0 "alias test_alias='c'"
}

@test "bash-it loader: load aliases and plugins in priority order, with one alias higher than plugins" {
  mkdir -p $BASH_IT/enabled

  ln -s $BASH_IT/components/plugins/lib/base.plugin.bash $BASH_IT/components/enabled/250___base.plugin.bash
  assert_link_exist "$BASH_IT/components/enabled/250___base.plugin.bash"

  ln -s $BASH_IT/components/aliases/lib/a.aliases.bash $BASH_IT/components/enabled/350___a.aliases.bash
  assert_link_exist "$BASH_IT/components/enabled/350___a.aliases.bash"

  ln -s $BASH_IT/components/aliases/lib/b.aliases.bash $BASH_IT/components/enabled/150___b.aliases.bash
  assert_link_exist "$BASH_IT/components/enabled/150___b.aliases.bash"

  ln -s $BASH_IT/components/plugins/lib/c.plugin.bash $BASH_IT/components/enabled/250___c.plugin.bash
  assert_link_exist "$BASH_IT/components/enabled/250___c.plugin.bash"

  run alias test_alias &> /dev/null
  assert_failure

  load "$BASH_IT/bash_it.sh"

  run alias test_alias &> /dev/null
  assert_success
  assert_line --index 0 "alias test_alias='a'"
}
