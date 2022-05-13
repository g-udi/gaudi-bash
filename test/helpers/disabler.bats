#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	load_gaudi_libs gaudi-bash cache components utils disabler
}

# @test "gaudi-bash helpers: _gaudi-bash-disable: should fail if no valid component type was passed" {

# 	run _gaudi-bash-disable
# 	assert_failure
# 	assert_output --partial "Please enter a valid component to disable"
# }

# @test "gaudi-bash helpers: _gaudi-bash-disable: should fail if no valid component was passed" {

# 	run _gaudi-bash-disable plugin
# 	assert_failure
# 	assert_output --partial "Please enter a valid"
# 	assert_output --partial "to disable"
# }

# @test "gaudi-bash helpers: _gaudi-bash-disable: should fail if component was not found" {

# 	run _gaudi-bash-disable plugin INVALID
# 	assert_failure
# 	assert_output --partial "INVALID"
# 	assert_output --partial "does not appear to be an enabled"
# }

# @test "gaudi-bash helpers: _gaudi-bash-disable: should successfully disable a component" {

# 	run _gaudi-bash-disable plugin base
# 	assert_failure
# 	assert_output --partial "does not appear to be an enabled"
# 	assert_file_not_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
# }

# @test "gaudi-bash helpers: _gaudi-bash-disable: should display appropriate message when trying to disable an already disabled component" {

# 	run _gaudi-bash-enable plugin base
# 	assert_success
# 	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"

# 	run _gaudi-bash-disable plugin base
# 	assert_output --partial "disabled"
# 	assert_file_not_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
# }

# @test "gaudi-bash helpers: _gaudi-bash-disable: should run the component disable function if it exists" {

# 	base_on_disable() {
# 		echo "callback"
# 	}

# 	run _gaudi-bash-enable plugin base
# 	assert_success
# 	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"

# 	run _gaudi-bash-disable plugin base
# 	assert_output --partial "disabled"
# 	assert_output --partial "callback"
# 	assert_file_not_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
# }

@test "gaudi-bash helpers: _gaudi-bash-disable: should disable multiple components passed" {

	run _gaudi-bash-enable plugin "nvm" "node"
	assert_line --index 0 --partial "enabled with priority"
	assert_line --index 1 --partial "enabled with priority"

	assert_link_exist "$GAUDI_BASH/components/enabled/250___node.plugins.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/250___nvm.plugins.bash"

	run _gaudi-bash-disable plugin "nvm" "node"
	assert_link_not_exist "$GAUDI_BASH/components/enabled/250___node.plugins.bash"
	assert_link_not_exist "$GAUDI_BASH/components/enabled/250___nvm.plugins.bash"
}

# @test "gaudi-bash helpers: _gaudi-bash-disable: should disable all plugins" {

# 	local available enabled

# 	run _gaudi-bash-enable plugins "all"
# 	available=$(find "$GAUDI_BASH/components/plugins/lib" -name "*.plugins.bash" | wc -l | xargs)
# 	enabled=$(find "$GAUDI_BASH/components/enabled" -name "[0-9]*.plugins.bash" | wc -l | xargs)
# 	assert_equal "$available" "$enabled"

# 	run _gaudi-bash-enable alias "ag"
# 	assert_file_exist "$GAUDI_BASH/components/enabled/150___ag.aliases.bash"

# 	run _gaudi-bash-disable plugins "all"
# 	enabled=$(find "$GAUDI_BASH/components/enabled" -name "[0-9]*.plugins.bash" | wc -l | xargs)
# 	assert_equal "0" "$enabled"
# 	assert_link_exist "$GAUDI_BASH/components/enabled/150___ag.aliases.bash"
# }

# @test "gaudi-bash helpers: _gaudi-bash-disable: should disable all plugins with priority" {

# 	local enabled

# 	ln -s "$GAUDI_BASH/components/plugins/lib/nvm.plugins.bash" "$GAUDI_BASH/components/enabled/250___nvm.plugins.bash"
# 	assert_file_exist "$GAUDI_BASH/components/enabled/250___nvm.plugins.bash"

# 	ln -s "$GAUDI_BASH/components/plugins/lib/node.plugins.bash" "$GAUDI_BASH/components/enabled/250___node.plugins.bash"
# 	assert_file_exist "$GAUDI_BASH/components/enabled/250___node.plugins.bash"

# 	enabled=$(find "$GAUDI_BASH/components/enabled" -name "*.plugins.bash" | wc -l | xargs)
# 	assert_equal "2" "$enabled"

# 	run _gaudi-bash-enable alias "ag"
# 	assert_file_exist "$GAUDI_BASH/components/enabled/150___ag.aliases.bash"

# 	run _gaudi-bash-disable plugins "all"
# 	enabled=$(find "$GAUDI_BASH/components/enabled" -name "*.plugins.bash" | wc -l | xargs)
# 	assert_equal "0" "$enabled"
# 	assert_file_exist "$GAUDI_BASH/components/enabled/150___ag.aliases.bash"
# }

# @test "gaudi-bash helpers: _gaudi-bash-enable: should handle properly disabling a set of mixed existing and non-existing components" {

# 	run gaudi-bash enable plugin "node"
# 	assert_line --index 0 -p "enabled with priority"

# 	run gaudi-bash disable plugin node INVALID nvm
# 	assert_line --index 0 -p "disabled"
# 	assert_line --index 1 -p "does not appear to be an enabled"
# 	assert_line --index 2 -p "does not appear to be an enabled"

# 	assert_link_not_exist "$GAUDI_BASH/components/enabled/250___node.plugins.bash"
# 	assert_link_not_exist "$GAUDI_BASH/components/enabled/250___nvm.plugins.bash"
# }
