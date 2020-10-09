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
