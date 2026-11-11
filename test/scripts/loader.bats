#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {

	if command -v rsync &> /dev/null; then
		rsync -a "$GAUDI_BASH/test/fixtures/gaudi_bash/" "$GAUDI_BASH/components"
	else
		find "$GAUDI_BASH/test/fixtures/gaudi_bash" \
			-mindepth 1 -maxdepth 1 \
			-exec cp -r {} "$GAUDI_BASH/" \;
	fi
}

@test "gaudi-bash loader: load aliases in order" {

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

@test "gaudi-bash loader: finalize hooks should run after all components are loaded" {

	ln -s "$GAUDI_BASH/components/plugins/lib/base.plugin.bash" "$GAUDI_BASH/components/enabled/250___base.plugin.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/250___base.plugin.bash"

	ln -s "$GAUDI_BASH/components/plugins/lib/d.plugins.bash" "$GAUDI_BASH/components/enabled/250___d.plugins.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/250___d.plugins.bash"

	load "$GAUDI_BASH/gaudi_bash.sh"

	# Verify the plugin was loaded
	run alias test_finalize_hook &> /dev/null
	assert_success

	# Verify the finalize hook ran
	assert [ "${GAUDI_FINALIZE_HOOK_RAN}" == "true" ]
}

@test "gaudi-bash loader: load aliases and plugins in priority order, with one alias higher than plugins" {

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

@test "gaudi-bash loader: load local custom scripts from multiple custom paths" {
	local custom_one custom_two
	custom_one="${BATS_TEST_TMPDIR}/custom-one"
	custom_two="${BATS_TEST_TMPDIR}/custom-two"
	mkdir -p "$custom_one" "$custom_two"

	cat > "$custom_one/100-local.aliases.bash" << 'CUSTOM'
alias local_custom_one='echo one'
CUSTOM

	cat > "$custom_two/200-local.aliases.bash" << 'CUSTOM'
alias local_custom_two='echo two'
CUSTOM

	export GAUDI_BASH_CUSTOM_PATHS="${custom_one}:${custom_two}"

	run alias local_custom_one &> /dev/null
	assert_failure
	run alias local_custom_two &> /dev/null
	assert_failure

	load "$GAUDI_BASH/gaudi_bash.sh"

	run alias local_custom_one &> /dev/null
	assert_success
	assert_line --index 0 "alias local_custom_one='echo one'"

	run alias local_custom_two &> /dev/null
	assert_success
	assert_line --index 0 "alias local_custom_two='echo two'"
}

@test "gaudi-bash loader: every library is named once in the ordered list of gaudi_bash.sh" {

	local lib expected="" listed

	for lib in "$GAUDI_BASH"/lib/*.bash; do
		lib="${lib##*/}"
		# The theme is loaded last, on its own
		[[ "$lib" == "appearance.bash" ]] && continue
		expected+="${lib%.bash}"$'\n'
	done

	listed="$(sed -n 's/^for _gaudi_bash_lib in \(composure colors log .*\); do$/\1/p' "$GAUDI_BASH/gaudi_bash.sh" | tr ' ' '\n' | sort)"

	assert_equal "$listed" "$(printf "%s" "$expected" | sort)"
}

@test "gaudi-bash loader: every library is loaded once" {

	local lib

	# Each library of the test copy counts how many times it is sourced
	for lib in composure colors log gaudi-bash search; do
		printf "\n%s\n" "GAUDI_TEST_LIB_LOADS=\"\${GAUDI_TEST_LIB_LOADS:-} ${lib}\"" >> "$GAUDI_BASH/lib/${lib}.bash"
	done

	load "$GAUDI_BASH/gaudi_bash.sh"

	assert_equal "$GAUDI_TEST_LIB_LOADS" " composure colors log gaudi-bash search"

	# The log colors are set in that single pass, the colors being loaded before the logging
	assert_equal "$GAUDI_BASH_LOG_ERROR_COLOR" "$RED"
}
