#!/usr/bin/env bats
# shellcheck shell=bats
# shellcheck disable=SC2031,SC2016,SC2030

load "$GAUDI_TEST_DIRECTORY"/helper.bash

# The uninstall script deletes the installation and edits the profile, so it only ever runs here
# against a throwaway installation directory in a throwaway home
local_setup() {
	UNINSTALL_HOME="$BATS_TEST_TMPDIR/home"
	UNINSTALL_TARGET="$UNINSTALL_HOME/.gaudi_bash"
	UNINSTALL_PROFILE="$UNINSTALL_HOME/$GAUDI_BASH_PROFILE"

	mkdir -p "$UNINSTALL_TARGET"
	touch "$UNINSTALL_TARGET/gaudi_bash.sh"
}

# Runs the uninstall script the way a user would from a shell that never loaded gaudi-bash (e.g., zsh):
# GAUDI_BASH_PROFILE is not set and nothing can be typed in
__uninstall() {
	run env -u GAUDI_BASH_PROFILE -u GAUDI_BASH HOME="$UNINSTALL_HOME" bash "$GAUDI_BASH/uninstall.sh" "$@" < /dev/null
}

__write_installed_profile() {
	printf "%s\n" \
		"export BEFORE=1" \
		"# >>> gaudi-bash >>>" \
		"export GAUDI_BASH=\"$UNINSTALL_TARGET\"" \
		'source "$GAUDI_BASH/gaudi_bash.sh"' \
		"# <<< gaudi-bash <<<" \
		"export AFTER=1" > "$UNINSTALL_PROFILE"
}

@test "gaudi-bash uninstall: verify that the uninstall script exists" {

	assert_file_exist "$GAUDI_BASH/uninstall.sh"
}

@test "gaudi-bash uninstall: remove only the gaudi-bash block from the profile" {

	local installed_profile

	__write_installed_profile
	installed_profile="$(< "$UNINSTALL_PROFILE")"

	__uninstall
	assert_success

	assert_dir_not_exist "$UNINSTALL_TARGET"
	assert_equal "$(< "$UNINSTALL_PROFILE")" "export BEFORE=1
export AFTER=1"

	# The profile as it was before is kept aside
	assert_equal "$(< "$UNINSTALL_PROFILE.uninstall")" "$installed_profile"
}

@test "gaudi-bash uninstall: use GAUDI_BASH and GAUDI_BASH_PROFILE when they are set" {

	local target="$BATS_TEST_TMPDIR/custom-location"

	mkdir -p "$target"
	touch "$target/gaudi_bash.sh"
	UNINSTALL_PROFILE="$UNINSTALL_HOME/.custom_profile"
	__write_installed_profile

	run env GAUDI_BASH="$target" GAUDI_BASH_PROFILE=".custom_profile" HOME="$UNINSTALL_HOME" bash "$GAUDI_BASH/uninstall.sh" < /dev/null
	assert_success

	assert_dir_not_exist "$target"
	assert_dir_exist "$UNINSTALL_TARGET"
	run grep -c "gaudi" "$UNINSTALL_PROFILE"
	assert_output "0"
}

@test "gaudi-bash uninstall: keep the backup and the current profile when restoring was not confirmed" {

	__write_installed_profile
	echo "the original profile" > "$UNINSTALL_PROFILE.bak"

	__uninstall
	assert_success
	assert_output --partial "The backup taken at installation was kept"

	assert_dir_not_exist "$UNINSTALL_TARGET"
	assert_equal "$(< "$UNINSTALL_PROFILE.bak")" "the original profile"
	assert_equal "$(< "$UNINSTALL_PROFILE")" "export BEFORE=1
export AFTER=1"
}

@test "gaudi-bash uninstall: restore the backup when asked to" {

	__write_installed_profile
	echo "the original profile" > "$UNINSTALL_PROFILE.bak"

	__uninstall --restore-backup
	assert_success

	assert_dir_not_exist "$UNINSTALL_TARGET"
	assert_file_not_exist "$UNINSTALL_PROFILE.bak"
	assert_file_not_exist "$UNINSTALL_PROFILE.uninstall"
	assert_equal "$(< "$UNINSTALL_PROFILE")" "the original profile"
}

@test "gaudi-bash uninstall: change nothing when the backup to restore does not exist" {

	local installed_profile

	__write_installed_profile
	installed_profile="$(< "$UNINSTALL_PROFILE")"

	__uninstall --restore-backup
	assert_failure
	assert_output --partial "nothing was changed"

	assert_dir_exist "$UNINSTALL_TARGET"
	assert_equal "$(< "$UNINSTALL_PROFILE")" "$installed_profile"
}

@test "gaudi-bash uninstall: remove the line that loads gaudi-bash from a profile without markers" {

	printf "%s\n" \
		"export BEFORE=1" \
		"export GAUDI_BASH=\"$UNINSTALL_TARGET\"" \
		'source $GAUDI_BASH/gaudi_bash.sh' \
		"export AFTER=1" > "$UNINSTALL_PROFILE"

	__uninstall
	assert_success

	assert_dir_not_exist "$UNINSTALL_TARGET"
	assert_equal "$(< "$UNINSTALL_PROFILE")" "export BEFORE=1
export GAUDI_BASH=\"$UNINSTALL_TARGET\"
export AFTER=1"
	assert_file_exist "$UNINSTALL_PROFILE.uninstall"
}

@test "gaudi-bash uninstall: leave a profile that does not load gaudi-bash as it is" {

	echo "export UNRELATED=1" > "$UNINSTALL_PROFILE"

	__uninstall
	assert_success

	assert_dir_not_exist "$UNINSTALL_TARGET"
	assert_equal "$(< "$UNINSTALL_PROFILE")" "export UNRELATED=1"
	assert_file_not_exist "$UNINSTALL_PROFILE.uninstall"
}

@test "gaudi-bash uninstall: remove the installation when there is no profile" {

	__uninstall
	assert_success

	assert_dir_not_exist "$UNINSTALL_TARGET"
	assert_file_not_exist "$UNINSTALL_PROFILE"
	assert_file_not_exist "$UNINSTALL_HOME/.uninstall"
}

@test "gaudi-bash uninstall: change nothing when the profile can not be determined" {

	local installed_profile

	__write_installed_profile
	installed_profile="$(< "$UNINSTALL_PROFILE")"

	run env -u GAUDI_BASH_PROFILE -u GAUDI_BASH HOME="$UNINSTALL_HOME" bash -c 'script="$1"; shift; OSTYPE=""; . "$script"' _ "$GAUDI_BASH/uninstall.sh" < /dev/null
	assert_failure
	assert_output --partial "Could not determine which Bash profile loads gaudi-bash"

	assert_dir_exist "$UNINSTALL_TARGET"
	assert_equal "$(< "$UNINSTALL_PROFILE")" "$installed_profile"
}

@test "gaudi-bash uninstall: refuse to remove a directory that is not a gaudi-bash installation" {

	local installed_profile target="$BATS_TEST_TMPDIR/not-gaudi-bash"

	mkdir -p "$target"
	touch "$target/precious-file"
	__write_installed_profile
	installed_profile="$(< "$UNINSTALL_PROFILE")"

	run env -u GAUDI_BASH_PROFILE GAUDI_BASH="$target" HOME="$UNINSTALL_HOME" bash "$GAUDI_BASH/uninstall.sh" < /dev/null
	assert_failure
	assert_output --partial "does not look like a gaudi-bash installation"

	assert_file_exist "$target/precious-file"
	assert_equal "$(< "$UNINSTALL_PROFILE")" "$installed_profile"
}

@test "gaudi-bash uninstall: change nothing when called with an unknown option" {

	__write_installed_profile

	__uninstall --force
	assert_failure
	assert_output --partial "Usage: uninstall.sh"

	assert_dir_exist "$UNINSTALL_TARGET"
	assert_file_not_exist "$UNINSTALL_PROFILE.uninstall"
}

@test "gaudi-bash uninstall: the script can be sourced and returns its status" {

	__write_installed_profile

	run env -u GAUDI_BASH_PROFILE -u GAUDI_BASH HOME="$UNINSTALL_HOME" bash -c 'script="$1"; shift; . "$script" < /dev/null; echo "status: $?"' _ "$GAUDI_BASH/uninstall.sh"
	assert_success
	assert_output --partial "status: 0"
	assert_dir_not_exist "$UNINSTALL_TARGET"
}

@test "gaudi-bash uninstall: remove the cache and say where the command history is" {

	__write_installed_profile
	mkdir -p "$UNINSTALL_HOME/.cache/gaudi-bash" "$UNINSTALL_HOME/.cache/other" "$UNINSTALL_HOME/.local/state/bash"
	touch "$UNINSTALL_HOME/.cache/gaudi-bash/plugins-descriptions" "$UNINSTALL_HOME/.local/state/bash/history"

	run env -u GAUDI_BASH_PROFILE -u GAUDI_BASH -u XDG_CACHE_HOME -u XDG_STATE_HOME HOME="$UNINSTALL_HOME" bash "$GAUDI_BASH/uninstall.sh" < /dev/null
	assert_success
	assert_output --partial "kept your command history in $UNINSTALL_HOME/.local/state/bash/history"

	assert_dir_not_exist "$UNINSTALL_HOME/.cache/gaudi-bash"
	assert_dir_exist "$UNINSTALL_HOME/.cache/other"
	assert_file_exist "$UNINSTALL_HOME/.local/state/bash/history"
}

@test "gaudi-bash uninstall: the messages are colored with the colors of the installation" {

	__write_installed_profile
	mkdir -p "$UNINSTALL_TARGET/lib"
	printf "%s\n" 'GREEN="<green>"' 'NC="<nc>"' > "$UNINSTALL_TARGET/lib/colors.bash"

	__uninstall
	assert_success
	assert_output --partial "<green>un-installation finished successfully! Sorry to see you go!<nc>"
	refute_output --partial "kept your command history"
}
