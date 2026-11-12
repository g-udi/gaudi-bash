#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	load_gaudi_libs gaudi-bash cache components utils enabler
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should fail if no valid component type was passed" {

	run _gaudi-bash-enable
	assert_failure
	assert_output "Please enter a valid component to enable"
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should fail if no valid component was passed" {

	run _gaudi-bash-enable plugin
	assert_failure
	assert_output --partial "Please enter a valid plugin(s) to enable"
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should fail if component was not found" {

	run _gaudi-bash-enable plugin INVALID
	assert_failure
	assert_output --partial "does not appear to be an available"
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should successfully enable a component" {

	run _gaudi-bash-enable plugin base
	assert_success
	assert_output --partial "enabled with priority"
	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should display appropriate message when trying to enable an already enabled component" {

	run _gaudi-bash-enable plugin base
	assert_success
	run _gaudi-bash-enable plugin base
	assert_output --partial "is already enabled"
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should respect custom priority defined in component" {

	run _gaudi-bash-enable plugin alias-completion
	assert_success
	assert_output --partial "enabled with priority"
	assert_file_exist "$GAUDI_BASH/components/enabled/365___alias-completion.plugins.bash"
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should enable multiple components passed" {

	run gbash enable plugin "node" "nvm"
	assert_line --index 0 --partial "enabled with priority"
	assert_line --index 1 --partial "enabled with priority"
	assert_link_exist "$GAUDI_BASH/components/enabled/250___node.plugins.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/250___nvm.plugins.bash"
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should enable all plugins" {

	local available enabled

	run _gaudi-bash-enable plugins "all"
	assert_success
	refute_output --partial "all"
	available=$(find "$GAUDI_BASH"/components/plugins/lib -name "*.plugins.bash" | wc -l | xargs)
	enabled=$(find "$GAUDI_BASH"/components/enabled -name "[0-9]*.plugins.bash" | wc -l | xargs)
	assert_equal "$available" "$enabled"
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should handle properly enabling a set of mixed existing and non-existing components" {

	run gbash enable plugin "node"
	assert_line --index 0 --partial "enabled with priority"

	run gbash enable plugin node INVALID nvm
	assert_failure
	assert_line --index 0 --partial "is already enabled"
	assert_line --index 1 --partial "does not appear to be an available"
	assert_line --index 2 --partial "enabled with priority"

	assert_link_exist "$GAUDI_BASH/components/enabled/250___node.plugins.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/250___nvm.plugins.bash"
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should fail and say so when the component can not be linked" {

	# shellcheck disable=SC2329
	ln() { return 1; }

	run _gaudi-bash-enable plugin base
	assert_failure
	assert_output --partial "Could not enable"
	refute_output --partial "enabled with priority"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should link the component with a relative path" {

	run _gaudi-bash-enable plugin base
	assert_success

	run readlink "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_output "../plugins/lib/base.plugins.bash"

	# The link still works after the installation was moved
	mv "$GAUDI_BASH" "$BATS_TEST_TMPDIR/moved"
	assert_file_exist "$BATS_TEST_TMPDIR/moved/components/enabled/250___base.plugins.bash"
	mv "$BATS_TEST_TMPDIR/moved" "$GAUDI_BASH"
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should link a component again when its link points to a missing file" {

	ln -s "/this/installation/was/moved/base.plugins.bash" "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"

	run _gaudi-bash-enable plugin base
	assert_success
	refute_output --partial "is already enabled"
	assert_output --partial "enabled with priority"
	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
}

@test "gaudi-bash helpers: _gaudi-bash-enable: should take a name as it is typed, not as a pattern" {

	run _gaudi-bash-enable plugin "*"
	assert_failure
	assert_output --partial "does not appear to be an available"

	run _gaudi-bash-enable plugin "100%s"
	assert_failure
	assert_output --partial "100%s"

	run find "$GAUDI_BASH/components/enabled" -name "*.bash"
	assert_output ""
}

@test "gaudi-bash helpers: _gaudi-bash-migrate-enabled-links: should rewrite absolute and broken links as relative ones" {

	local enabled="$GAUDI_BASH/components/enabled"
	local elsewhere="$BATS_TEST_TMPDIR/elsewhere.aliases.bash"

	touch "$elsewhere"
	# What older versions made: an absolute link to the component
	ln -s "$GAUDI_BASH/components/plugins/lib/base.plugins.bash" "$enabled/250___base.plugins.bash"
	# The link of an installation that was moved
	ln -s "/old/place/components/aliases/lib/general.aliases.bash" "$enabled/150___general.aliases.bash"
	# A link that is fine already
	ln -s "../completions/lib/git.completions.bash" "$enabled/350___git.completions.bash"
	# A link somebody made on purpose to a file outside the installation
	ln -s "$elsewhere" "$enabled/150___git.aliases.bash"
	# A broken link without a component of that name
	ln -s "/old/place/gone.plugins.bash" "$enabled/250___gone.plugins.bash"

	run gbash migrate
	assert_success
	assert_line "migrated 250___base.plugins.bash -> ../plugins/lib/base.plugins.bash"
	assert_line "migrated 150___general.aliases.bash -> ../aliases/lib/general.aliases.bash"
	assert_line --partial "250___gone.plugins.bash points to a missing file"
	assert_line --partial "gbash disable plugin gone"
	refute_output --partial "git.completions"
	refute_output --partial "git.aliases"

	assert_equal "$(readlink "$enabled/250___base.plugins.bash")" "../plugins/lib/base.plugins.bash"
	assert_equal "$(readlink "$enabled/150___general.aliases.bash")" "../aliases/lib/general.aliases.bash"
	assert_equal "$(readlink "$enabled/350___git.completions.bash")" "../completions/lib/git.completions.bash"
	assert_equal "$(readlink "$enabled/150___git.aliases.bash")" "$elsewhere"
	assert_file_exist "$enabled/250___base.plugins.bash"
	assert_file_exist "$enabled/150___general.aliases.bash"

	# A second run has nothing left to do
	run gbash disable plugin gone
	run gbash migrate
	assert_success
	assert_output "Nothing to migrate, every enabled component is linked with a relative path"
}
