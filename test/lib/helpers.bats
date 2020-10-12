# #!/usr/bin/env bats

# load ../helper
# load ../../lib/composure

# cite about param example group

# load ../../lib/log
# load ../../lib/search
# load ../../lib/bash-it

# local_setup () {
#   prepare
# }

# @test "helpers: enable the todo.txt-cli aliases through the bash-it function" {
#   run bash-it enable alias "todo.txt-cli"
#   assert_line -n 0 'todo.txt-cli enabled with priority 150.'
#   assert_link_exist "$BASH_IT/enabled/150---todo.txt-cli.aliases.bash"
# }

# @test "helpers: enable the curl aliases" {
#   run _enable-alias "curl"
#   assert_line -n 0 '[● ENABLED] curl enabled with priority 150.'
#   assert_link_exist "$BASH_IT/enabled/150---curl.aliases.bash"
# }

# @test "helpers: enable the apm completion through the bash-it function" {
#   run bash-it enable completion "apm"
#   assert_line -n 0 '[● ENABLED] apm enabled with priority 350.'
#   assert_link_exist "$BASH_IT/enabled/350---apm.completion.bash"
# }

# @test "helpers: enable the brew completion" {
#   run _enable-completion "brew"
#   assert_line -n 0 'brew enabled with priority 375.'
#   assert_link_exist "$BASH_IT/enabled/375---brew.completion.bash"
# }

# @test "helpers: enable the node plugin" {
#   run _enable-plugin "node"
#   assert_line -n 0 '[● ENABLED] node enabled with priority 250.'
#   assert_link_exist "$BASH_IT/enabled/250---node.plugin.bash" "../plugins/available/node.plugin.bash"
# }

# @test "helpers: enable the node plugin through the bash-it function" {
#   run bash-it enable plugin "node"
#   assert_line -n 0 '[● ENABLED] node enabled with priority 250.'
#   assert_link_exist "$BASH_IT/enabled/250---node.plugin.bash"
# }

# @test "helpers: enable the node and nvm plugins through the bash-it function" {
#   run bash-it enable plugin "node" "nvm"
#   assert_line -n 0 'node enabled with priority 250.'
#   assert_line -n 1 'nvm enabled with priority 225.'
#   assert_link_exist "$BASH_IT/enabled/250---node.plugin.bash"
#   assert_link_exist "$BASH_IT/enabled/225---nvm.plugin.bash"
# }

# @test "helpers: enable the foo-unkown and nvm plugins through the bash-it function" {
#   run bash-it enable plugin "foo-unknown" "nvm"
#   assert_line -n 0 'sorry, foo-unknown does not appear to be an available plugin.'
#   assert_line -n 1 'nvm enabled with priority 225.'
#   assert_link_exist "$BASH_IT/enabled/225---nvm.plugin.bash"
# }

# @test "helpers: enable the nvm plugin" {
#   run _enable-plugin "nvm"
#   assert_line -n 0 'nvm enabled with priority 225.'
#   assert_link_exist "$BASH_IT/enabled/225---nvm.plugin.bash"
# }

# @test "helpers: enable an unknown plugin" {
#   run _enable-plugin "unknown-foo"
#   assert_line -n 0 'sorry, unknown-foo does not appear to be an available plugin.'

#   # Check for both old an new structure
#   assert [[ ! -L "$BASH_IT/plugins/enabled/250---unknown-foo.plugin.bash" ]]
#   assert [[ ! -L "$BASH_IT/plugins/enabled/unknown-foo.plugin.bash" ]]

#   assert [[ ! -L "$BASH_IT/enabled/250---unknown-foo.plugin.bash" ]]
#   assert [[ ! -L "$BASH_IT/enabled/unknown-foo.plugin.bash" ]]
# }

# @test "helpers: enable an unknown plugin through the bash-it function" {
#   run bash-it enable plugin "unknown-foo"
#   echo "${lines[@]}"
#   assert_line -n 0 'sorry, unknown-foo does not appear to be an available plugin.'

#   # Check for both old an new structure
#   assert [[ ! -L "$BASH_IT/plugins/enabled/250---unknown-foo.plugin.bash" ]]
#   assert [[ ! -L "$BASH_IT/plugins/enabled/unknown-foo.plugin.bash" ]]

#   assert [[ ! -L "$BASH_IT/enabled/250---unknown-foo.plugin.bash" ]]
#   assert [[ ! -L "$BASH_IT/enabled/unknown-foo.plugin.bash" ]]
# }

# @test "helpers: disable a plugin that is not enabled" {
#   run _disable-plugin "sdkman"
#   assert_line -n 0 'sorry, sdkman does not appear to be an enabled plugin.'
# }

# @test "helpers: enable and disable the nvm plugin" {
#   run _enable-plugin "nvm"
#   assert_line -n 0 'nvm enabled with priority 225.'
#   assert_link_exist "$BASH_IT/enabled/225---nvm.plugin.bash"
#   assert [[ ! -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]]

#   run _disable-plugin "nvm"
#   assert_line -n 0 'nvm disabled.'
#   assert [[ ! -L "$BASH_IT/enabled/225---nvm.plugin.bash" ]]
# }

# @test "helpers: disable the nvm plugin if it was enabled with a priority, but in the component-specific directory" {
#   ln -s $BASH_IT/plugins/available/nvm.plugin.bash $BASH_IT/plugins/enabled/225---nvm.plugin.bash
#   assert_link_exist "$BASH_IT/plugins/enabled/225---nvm.plugin.bash"
#   assert [[ ! -L "$BASH_IT/enabled/225---nvm.plugin.bash" ]]

#   run _disable-plugin "nvm"
#   assert_line -n 0 'nvm disabled.'
#   assert [[ ! -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]]
#   assert [[ ! -L "$BASH_IT/enabled/225---nvm.plugin.bash" ]]
# }

# @test "helpers: disable the nvm plugin if it was enabled without a priority" {
#   ln -s $BASH_IT/plugins/available/nvm.plugin.bash $BASH_IT/plugins/enabled/nvm.plugin.bash
#   assert_link_exist "$BASH_IT/plugins/enabled/nvm.plugin.bash"

#   run _disable-plugin "nvm"
#   assert_line -n 0 'nvm disabled.'
#   assert [[ ! -L "$BASH_IT/plugins/enabled/nvm.plugin.bash" ]]
# }

# @test "helpers: enable the nvm plugin if it was enabled without a priority" {
#   ln -s $BASH_IT/plugins/available/nvm.plugin.bash $BASH_IT/plugins/enabled/nvm.plugin.bash
#   assert_link_exist "$BASH_IT/plugins/enabled/nvm.plugin.bash"

#   run _enable-plugin "nvm"
#   assert_line -n 0 'nvm is already enabled.'
#   assert_link_exist "$BASH_IT/plugins/enabled/nvm.plugin.bash"
#   assert [[ ! -L "$BASH_IT/plugins/enabled/225---nvm.plugin.bash" ]]
#   assert [[ ! -L "$BASH_IT/enabled/225---nvm.plugin.bash" ]]
# }

# @test "helpers: enable the nvm plugin if it was enabled with a priority, but in the component-specific directory" {
#   ln -s $BASH_IT/plugins/available/nvm.plugin.bash $BASH_IT/plugins/enabled/225---nvm.plugin.bash
#   assert_link_exist "$BASH_IT/plugins/enabled/225---nvm.plugin.bash"

#   run _enable-plugin "nvm"
#   assert_line -n 0 'nvm is already enabled.'
#   assert [[ ! -L "$BASH_IT/plugins/enabled/nvm.plugin.bash" ]]
#   assert_link_exist "$BASH_IT/plugins/enabled/225---nvm.plugin.bash"
#   assert [[ ! -L "$BASH_IT/enabled/225---nvm.plugin.bash" ]]
# }

# @test "helpers: enable the nvm plugin twice" {
#   run _enable-plugin "nvm"
#   assert_line -n 0 'nvm enabled with priority 225.'
#   assert_link_exist "$BASH_IT/enabled/225---nvm.plugin.bash"

#   run _enable-plugin "nvm"
#   assert_line -n 0 'nvm is already enabled.'
#   assert_link_exist "$BASH_IT/enabled/225---nvm.plugin.bash"
# }

# @test "helpers: describe the nvm plugin without enabling it" {
#   _bash-it-show plugins | grep "nvm" | grep "\[[ \]"
# }

# @test "helpers: describe the nvm plugin after enabling it" {
#   run _enable-plugin "nvm"
#   assert_line -n 0 '[● ENABLED] nvm enabled with priority 225.'
#   assert_link_exist "$BASH_IT/enabled/225---nvm.plugin.bash"

#   _bash-it-show plugins | grep "nvm" | grep "\[x\]"
# }

# @test "helpers: describe the nvm plugin after enabling it in the old directory" {
#   ln -s $BASH_IT/plugins/available/nvm.plugin.bash $BASH_IT/plugins/enabled/nvm.plugin.bash
#   assert_link_exist "$BASH_IT/plugins/enabled/nvm.plugin.bash"

#   _bash-it-show plugins | grep "nvm" | grep "\[x\]"
# }

# @test "helpers: describe the nvm plugin after enabling it in the old directory with priority" {
#   ln -s $BASH_IT/plugins/available/nvm.plugin.bash $BASH_IT/plugins/enabled/225---nvm.plugin.bash
#   assert_link_exist "$BASH_IT/plugins/enabled/225---nvm.plugin.bash"

#   _bash-it-show plugins | grep "nvm" | grep "\[x\]"
# }

# @test "helpers: describe the todo.txt-cli aliases without enabling them" {
#   run _bash-it-show aliases
#   assert_line "todo.txt-cli          [[ ]]     todo.txt-cli abbreviations"
# }
