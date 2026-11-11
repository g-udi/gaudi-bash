#!/usr/bin/env bats
# shellcheck shell=bats
# shellcheck disable=SC2329,SC2034

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	load_gaudi_libs gaudi-bash
}

assert_sane_defaults() {
	assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/150___gaudi-bash.aliases.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/325___system.completions.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
}

@test "gaudi-bash core: _gaudi-bash-backup should successfully backup enabled components" {

	cd "$GAUDI_BASH"
	./setup.sh --silent

	assert_sane_defaults

	assert_file_not_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run _gaudi-bash-backup

	assert_file_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run cat "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"
	assert_success
	assert_output --partial "gbash enable alias general"
	assert_output --partial "gbash enable plugin base"
	assert_output --partial "gbash enable completion system"
}

@test "gaudi-bash core: _gaudi-bash-backup should overwrite old backed up components" {

	cd "$GAUDI_BASH"
	./setup.sh --silent

	assert_sane_defaults

	assert_file_not_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run _gaudi-bash-backup

	assert_file_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run gbash disable completion git
	run _gaudi-bash-backup

	assert_file_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"
	run cat "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"
	assert_output --partial "gbash enable alias general"
}

@test "gaudi-bash core: _gaudi-bash-restore should successfully restore backed up components" {

	cd "$GAUDI_BASH"
	./setup.sh --silent

	assert_sane_defaults

	assert_file_not_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run _gaudi-bash-backup

	assert_line --index 0 "Backing up alias: gaudi-bash"
	assert_file_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run gbash disable plugins all
	run gbash disable completion all
	run gbash disable aliases all

	assert_file_not_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/150___gaudi-bash.aliases.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/365___alias-completion.plugins.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/325___system.completions.bash"

	run _gaudi-bash-restore

	assert_sane_defaults

}

@test "gaudi-bash core: gbash should reload once after enabling several components" {

	GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1
	_gaudi-bash-reload() { echo "RELOADED"; }

	run gbash enable alias general gaudi-bash
	assert_success
	assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/150___gaudi-bash.aliases.bash"
	assert_equal "$(grep -c "^RELOADED$" <<< "$output")" 1
	# The reload comes last, after every component was handled
	assert_equal "${lines[${#lines[@]} - 1]}" "RELOADED"
}

@test "gaudi-bash core: gbash should reload once after enabling and disabling all components of a type" {

	GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1
	_gaudi-bash-reload() { echo "RELOADED"; }

	run gbash enable completions all
	assert_success
	assert_file_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
	assert_equal "$(grep -c "^RELOADED$" <<< "$output")" 1

	run gbash disable completions all
	assert_success
	assert_file_not_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
	assert_equal "$(grep -c "^RELOADED$" <<< "$output")" 1
}

@test "gaudi-bash core: gbash restore and profile load should reload once" {

	GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1
	_gaudi-bash-reload() { echo "RELOADED"; }

	mkdir -p "$GAUDI_BASH/tmp" "$GAUDI_BASH/profiles"
	printf "%s\n" "gbash enable plugin base" "gbash enable alias general" "gbash enable completion system" > "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"
	printf "%s\n" "plugin base" "alias general" > "$GAUDI_BASH/profiles/test-reload.gaudi-bash"

	run gbash restore
	assert_success
	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/325___system.completions.bash"
	assert_equal "$(grep -c "^RELOADED$" <<< "$output")" 1

	run gbash profile load test-reload
	assert_success
	assert_file_not_exist "$GAUDI_BASH/components/enabled/325___system.completions.bash"
	assert_equal "$(grep -c "^RELOADED$" <<< "$output")" 1

	rm -f "$GAUDI_BASH/profiles/test-reload.gaudi-bash"
}

@test "gaudi-bash core: gbash should not reload when nothing was changed or automatic reload is off" {

	_gaudi-bash-reload() { echo "RELOADED"; }

	GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1
	run gbash show aliases
	refute_output --partial "RELOADED"

	unset GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE
	run gbash enable alias general
	assert_success
	refute_output --partial "RELOADED"
}

@test "gaudi-bash core: enabling a component outside of gbash should still reload right away" {

	GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1
	_gaudi-bash-reload() { echo "RELOADED"; }

	run _gaudi-bash-enable alias general
	assert_success
	assert_equal "$(grep -c "^RELOADED$" <<< "$output")" 1
}

@test "gaudi-bash core: gbash should return the status of the command it ran" {

	run gbash enable alias this-alias-does-not-exist
	assert_failure

	run gbash restore
	assert_failure
	assert_output --partial "No valid backup file found"
}

@test "gaudi-bash core: gbash version should leave the working directories untouched" {

	local previous="$BATS_TEST_TMPDIR/previous" current="$BATS_TEST_TMPDIR/current"

	mkdir -p "$previous" "$current"
	cd "$previous"
	cd "$current"
	previous="$OLDPWD"
	current="$PWD"

	_gaudi-bash-version

	assert_equal "$PWD" "$current"
	assert_equal "$OLDPWD" "$previous"

	run gbash version
	assert_success
	assert_output --partial "Current git SHA:"
}
