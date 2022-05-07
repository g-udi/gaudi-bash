#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

load "$GAUDI_BASH"/lib/composure.bash

cite about param example group priority

local_setup() {
	prepare

	if command -v rsync &> /dev/null; then
		rsync -a "$GAUDI_BASH/test/fixtures/gaudi_bash/" "$GAUDI_BASH/components"
	else
		find "$GAUDI_BASH/test/fixtures/gaudi_bash" \
			-mindepth 1 -maxdepth 1 \
			-exec cp -r {} "$GAUDI_BASH/" \;
	fi
}

@test "gaudi-bash loader: load aliases in order" {

	mkdir -p "$GAUDI_BASH"/components/enabled
	mkdir -p "$GAUDI_BASH"/components/enabled

	ln -s "$GAUDI_BASH/components/plugins/lib/base.plugin.bash" "$GAUDI_BASH/components/enabled/250___base.plugin.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/250___base.plugin.bash"

	ln -s "$GAUDI_BASH/components/aliases/lib/a.aliases.bash" "$GAUDI_BASH/components/enabled/150___a.aliases.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/150___a.aliases.bash"

	ln -s "$GAUDI_BASH/components/aliases/lib/b.aliases.bash" "$GAUDI_BASH/components/enabled/150___b.aliases.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/150___b.aliases.bash"

	run alias test_alias &> /dev/null
	assert_failure

	load "$GAUDI_BASH/gaudi_bash.sh"

	run alias test_alias &> /dev/null
	assert_success
	assert_line --index 0 "alias test_alias='b'"
}

@test "gaudi-bash loader: load aliases in priority order" {
	mkdir -p "$GAUDI_BASH"/enabled
	mkdir -p "$GAUDI_BASH"/enabled

	ln -s "$GAUDI_BASH/components/plugins/lib/base.plugin.bash" "$GAUDI_BASH/components/enabled/250___base.plugin.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/250___base.plugin.bash"

	ln -s "$GAUDI_BASH/components/aliases/lib/a.aliases.bash" "$GAUDI_BASH/components/enabled/175___a.aliases.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/175___a.aliases.bash"

	ln -s "$GAUDI_BASH/components/aliases/lib/b.aliases.bash" "$GAUDI_BASH/components/enabled/150___b.aliases.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/150___b.aliases.bash"

	run alias test_alias &> /dev/null
	assert_failure

	load "$GAUDI_BASH/gaudi_bash.sh"

	run alias test_alias &> /dev/null
	assert_success
	assert_line --index 0 "alias test_alias='a'"
}

@test "gaudi-bash loader: load aliases and plugins in priority order" {
	mkdir -p "$GAUDI_BASH"/enabled

	ln -s "$GAUDI_BASH/components/plugins/lib/base.plugin.bash" "$GAUDI_BASH/components/enabled/250___base.plugin.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/250___base.plugin.bash"

	ln -s "$GAUDI_BASH/components/aliases/lib/a.aliases.bash" "$GAUDI_BASH/components/enabled/150___a.aliases.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/150___a.aliases.bash"

	ln -s "$GAUDI_BASH/components/aliases/lib/b.aliases.bash" "$GAUDI_BASH/components/enabled/150___b.aliases.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/150___b.aliases.bash"

	ln -s "$GAUDI_BASH/components/plugins/lib/c.plugins.bash" "$GAUDI_BASH/components/enabled/250___c.plugins.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/250___c.plugins.bash"

	run alias test_alias &> /dev/null
	assert_failure

	load "$GAUDI_BASH/gaudi_bash.sh"

	run alias test_alias &> /dev/null
	assert_success
	assert_line --index 0 "alias test_alias='c'"
}

@test "gaudi-bash loader: load aliases, plugins and completions in priority order" {
	mkdir -p "$GAUDI_BASH"/enabled

	ln -s "$GAUDI_BASH/components/plugins/base.plugin.bash" "$GAUDI_BASH/components/enabled/250___base.plugin.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/250___base.plugin.bash"

	ln -s "$GAUDI_BASH/components/aliases/lib/a.aliases.bash" "$GAUDI_BASH/components/enabled/150___a.aliases.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/150___a.aliases.bash"

	ln -s "$GAUDI_BASH/components/aliases/lib/b.aliases.bash" "$GAUDI_BASH/components/enabled/350___b.completion.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/350___b.completion.bash"

	ln -s "$GAUDI_BASH/components/plugins/c.plugins.bash" "$GAUDI_BASH/components/enabled/250___c.plugins.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/250___c.plugins.bash"

	run alias test_alias &> /dev/null
	assert_failure

	load "$GAUDI_BASH/gaudi_bash.sh"

	run alias test_alias &> /dev/null
	assert_success
	assert_line --index 0 "alias test_alias='b'"
}

@test "gaudi-bash loader: load aliases, plugins and completions in priority order with one alias priority higher than a plugin" {
	mkdir -p "$GAUDI_BASH"/enabled

	ln -s "$GAUDI_BASH/components/plugins/lib/base.plugin.bash" "$GAUDI_BASH/components/enabled/250___base.plugin.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/250___base.plugin.bash"

	ln -s "$GAUDI_BASH/components/aliases/lib/a.aliases.bash" "$GAUDI_BASH/components/enabled/450___a.aliases.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/450___a.aliases.bash"

	ln -s "$GAUDI_BASH/components/aliases/lib/b.aliases.bash" "$GAUDI_BASH/components/enabled/350___b.completion.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/350___b.completion.bash"

	ln -s "$GAUDI_BASH/components/plugins/lib/c.plugins.bash" "$GAUDI_BASH/components/enabled/950___c.plugins.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/950___c.plugins.bash"

	run alias test_alias &> /dev/null
	assert_failure

	load "$GAUDI_BASH/gaudi_bash.sh"

	run alias test_alias &> /dev/null
	assert_success
	assert_line --index 0 "alias test_alias='c'"
}

@test "gaudi-bash loader: load aliases and plugins in priority order, with one alias higher than plugins" {
	mkdir -p "$GAUDI_BASH"/enabled

	ln -s "$GAUDI_BASH/components/plugins/lib/base.plugin.bash" "$GAUDI_BASH/components/enabled/250___base.plugin.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/250___base.plugin.bash"

	ln -s "$GAUDI_BASH/components/aliases/lib/a.aliases.bash" "$GAUDI_BASH/components/enabled/350___a.aliases.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/350___a.aliases.bash"

	ln -s "$GAUDI_BASH/components/aliases/lib/b.aliases.bash" "$GAUDI_BASH/components/enabled/150___b.aliases.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/150___b.aliases.bash"

	ln -s "$GAUDI_BASH/components/plugins/lib/c.plugins.bash" "$GAUDI_BASH/components/enabled/250___c.plugins.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/250___c.plugins.bash"

	run alias test_alias &> /dev/null
	assert_failure

	load "$GAUDI_BASH/gaudi_bash.sh"

	run alias test_alias &> /dev/null
	assert_success
	assert_line --index 0 "alias test_alias='a'"
}
