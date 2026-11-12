#!/usr/bin/env bats
# shellcheck shell=bats
# shellcheck disable=SC2016,SC1091,SC2317,SC2031

load "$GAUDI_TEST_DIRECTORY"/helper.bash

# Removes the profile backups that earlier tests left in the test home
__remove_profile_backups() {
	local backup

	for backup in "${HOME:?}/${GAUDI_BASH_PROFILE:?}.bak"*; do
		[[ -e "$backup" ]] && rm -f "$backup"
	done
	return 0
}

# Runs the installer on a home that already holds an installation, with a git that only records how it was called
# $1: the answer given to the installer, nothing can be read when it is left out
__run_installer_again() {
	local fakebin="$BATS_TEST_TMPDIR/fakebin"

	INSTALL_HOME="$BATS_TEST_TMPDIR/install-home"
	GIT_CALLS="$BATS_TEST_TMPDIR/git-calls"

	mkdir -p "$fakebin" "$INSTALL_HOME/.gaudi_bash"
	touch "$INSTALL_HOME/.gaudi_bash/existing-installation" "$GIT_CALLS"

	cat > "$fakebin/git" << 'GIT'
#!/usr/bin/env bash
printf "%s\n" "$*" >> "$GIT_CALLS"
case "$3" in
	describe)
		echo "v9.9.9"
		;;
	rev-list)
		echo "0000000"
		;;
	rev-parse)
		[[ -n "$GIT_SHALLOW" ]] && echo "true"
		;;
	merge-base)
		# Whether the installation already holds the latest release
		[[ -n "$GIT_AHEAD" ]] && exit 0
		exit 1
		;;
	config)
		# The submodule paths of .gitmodules
		printf "%s\n" "submodule.components.path components" "submodule.bin/composure.path bin/composure" "submodule.bin/bats-core.path bin/bats-core"
		;;
esac
exit 0
GIT
	chmod +x "$fakebin/git"

	if [[ $# -gt 0 ]]; then
		run env PATH="$fakebin:$PATH" HOME="$INSTALL_HOME" GIT_CALLS="$GIT_CALLS" "$GAUDI_BASH_ORIGIN/install.sh" --silent --basic <<< "$1"
	else
		run env PATH="$fakebin:$PATH" HOME="$INSTALL_HOME" GIT_CALLS="$GIT_CALLS" "$GAUDI_BASH_ORIGIN/install.sh" --silent --basic < /dev/null
	fi
}

@test "gaudi-bash install: verify that the install script exists" {

	assert_file_exist "$GAUDI_BASH/install.sh"
}

@test "gaudi-bash install: verify that the setup script exists" {

	assert_file_exist "$GAUDI_BASH/setup.sh"
}

@test "gaudi-bash install: run the install script silently by skipping prompts" {

	run "$GAUDI_BASH/setup.sh" --silent
	assert_success
	refute_output
}

@test "gaudi-bash install: run the install script silently and check that config file exists" {

	cd "$GAUDI_BASH"

	"$GAUDI_BASH/setup.sh" --silent
	assert_file_exist "$HOME/$GAUDI_BASH_PROFILE"
}

@test "gaudi-bash install: run the install script silently and enable sane defaults" {

	cd "$GAUDI_BASH"

	"$GAUDI_BASH/setup.sh" --silent

	assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/325___system.completions.bash"
}

@test "gaudi-bash install: run the install script silently and don't modify configs" {
	rm -rf "${HOME:?}/${GAUDI_BASH_PROFILE:?}"

	cd "$GAUDI_BASH"
	"$GAUDI_BASH/setup.sh" --silent --no-modify-config

	assert_file_not_exist "$HOME/${GAUDI_BASH_PROFILE}"
}

@test "gaudi-bash install: setup defaults GAUDI_BASH from the setup script directory" {

	local repo="$GAUDI_BASH"

	run env -u GAUDI_BASH HOME="$HOME" "$repo/setup.sh" --silent --basic
	assert_success

	assert_file_exist "$HOME/$GAUDI_BASH_PROFILE"
	run grep -F "export GAUDI_BASH=\"$repo\"" "$HOME/$GAUDI_BASH_PROFILE"
	assert_success
}

@test "gaudi-bash install: sourced setup resolves the setup script directory" {

	local wrapper="$BATS_TEST_TMPDIR/source-setup.sh"

	cat > "$wrapper" << WRAPPER
#!/usr/bin/env bash
source "$GAUDI_BASH/setup.sh" --silent --basic
WRAPPER
	chmod +x "$wrapper"

	run "$wrapper"
	assert_success

	assert_file_exist "$HOME/$GAUDI_BASH_PROFILE"
	run grep -F "export GAUDI_BASH=\"$GAUDI_BASH\"" "$HOME/$GAUDI_BASH_PROFILE"
	assert_success
}

@test "gaudi-bash install: setup rejects unknown options" {

	run "$GAUDI_BASH/setup.sh" --not-a-real-option
	assert_failure
	assert_output --partial "Unknown argument: --not-a-real-option"
}

@test "gaudi-bash install: installer executes cloned setup" {

	local fakebin="$BATS_TEST_TMPDIR/fakebin"
	# setup.sh writes its own (clean) path into the profile, so the temporary folder is named without a double slash
	local install_home="${BATS_TEST_TMPDIR//\/\///}/install-home"

	mkdir -p "$fakebin" "$install_home"
	cat > "$fakebin/git" << 'GIT'
#!/usr/bin/env bash
if [[ "$1" == "ls-remote" ]]; then
	# The tags of the repository, the highest version first (what --sort=-v:refname gives)
	[[ -n "$GIT_NO_RELEASE" ]] && exit 0
	printf "%s\t%s\n" "1111111" "refs/tags/v9.9.9" "0000000" "refs/tags/v9.9.8"
	exit 0
fi
if [[ "$1" == "clone" ]]; then
	printf "%s\n" "$*" > "$GIT_CLONE_CALL"
	destination=""
	for arg in "$@"; do
		destination="$arg"
	done

	mkdir -p "$destination"
	tar -C "$GAUDI_BASH_ORIGIN" \
		--exclude='.git' \
		--exclude='components/enabled' \
		-cf - . | tar -C "$destination" -xf -
	exit 0
fi
printf "%s\n" "$*" >> "$GIT_CLONE_CALL.other"

exit 1
GIT
	chmod +x "$fakebin/git"

	run env PATH="$fakebin:$PATH" HOME="$install_home" GIT_CLONE_CALL="$BATS_TEST_TMPDIR/git-clone-call" "$GAUDI_BASH_ORIGIN/install.sh" --silent --basic
	assert_success

	# The latest release is cloned; the clone leaves the git submodules to setup.sh, which only fetches the ones gaudi-bash runs on
	run cat "$BATS_TEST_TMPDIR/git-clone-call"
	assert_output "clone --depth=1 --branch v9.9.9 https://github.com/g-udi/gaudi-bash.git $install_home/.gaudi_bash"

	assert_file_exist "$install_home/.gaudi_bash/setup.sh"
	assert_file_exist "$install_home/$GAUDI_BASH_PROFILE"
	run grep -F "export GAUDI_BASH=\"$install_home/.gaudi_bash\"" "$install_home/$GAUDI_BASH_PROFILE"
	assert_success

	# A clone of a tag only tracks that tag, the branches are tracked for `gbash update dev`
	run cat "$BATS_TEST_TMPDIR/git-clone-call.other"
	assert_line "-C $install_home/.gaudi_bash remote set-branches origin *"

	# Without a release the main branch is installed
	rm -rf "$install_home/.gaudi_bash"
	run env PATH="$fakebin:$PATH" HOME="$install_home" GIT_NO_RELEASE=1 GIT_CLONE_CALL="$BATS_TEST_TMPDIR/git-clone-call" "$GAUDI_BASH_ORIGIN/install.sh" --silent --basic
	assert_success
	run cat "$BATS_TEST_TMPDIR/git-clone-call"
	assert_output "clone --depth=1 https://github.com/g-udi/gaudi-bash.git $install_home/.gaudi_bash"
}

@test "gaudi-bash install: verify that a backup file is created" {

	local original="$BATS_TEST_TMPDIR/original-profile"

	cd "$GAUDI_BASH" || exit

	__remove_profile_backups
	echo "test file content" > "$HOME/$GAUDI_BASH_PROFILE"
	cp "$HOME/$GAUDI_BASH_PROFILE" "$original"

	"$GAUDI_BASH/setup.sh" --silent

	assert_file_exist "$HOME/$GAUDI_BASH_PROFILE"
	assert_file_exist "$HOME/$GAUDI_BASH_PROFILE.bak"

	# The backup is the profile as it was, byte for byte (cmp is available everywhere, md5sum is not)
	run cmp "$original" "$HOME/$GAUDI_BASH_PROFILE.bak"
	assert_success
}

@test "gaudi-bash install: a silent setup never overwrites an existing backup" {

	local -a backups

	cd "$GAUDI_BASH" || exit

	__remove_profile_backups
	echo "the original profile" > "$HOME/$GAUDI_BASH_PROFILE.bak"
	echo "a profile changed after the first setup" > "$HOME/$GAUDI_BASH_PROFILE"

	"$GAUDI_BASH/setup.sh" --silent

	assert_equal "$(< "$HOME/$GAUDI_BASH_PROFILE.bak")" "the original profile"

	# The profile that was about to be replaced is kept in a timestamped backup
	backups=("$HOME/$GAUDI_BASH_PROFILE.bak."*)
	assert_equal "${#backups[@]}" 1
	assert_equal "$(< "${backups[0]}")" "a profile changed after the first setup"
}

@test "gaudi-bash install: running the silent setup again keeps the backup and adds no other" {

	local -a backups

	cd "$GAUDI_BASH" || exit

	__remove_profile_backups
	echo "the original profile" > "$HOME/$GAUDI_BASH_PROFILE"

	"$GAUDI_BASH/setup.sh" --silent
	"$GAUDI_BASH/setup.sh" --silent
	"$GAUDI_BASH/setup.sh" --silent

	assert_equal "$(< "$HOME/$GAUDI_BASH_PROFILE.bak")" "the original profile"

	backups=("$HOME/$GAUDI_BASH_PROFILE.bak"*)
	assert_equal "${#backups[@]}" 1
	assert_equal "$(grep -c "gaudi_bash.sh" "$HOME/$GAUDI_BASH_PROFILE")" 1
}

@test "gaudi-bash install: the profile template loads gaudi-bash from a quoted path inside its markers" {

	cd "$GAUDI_BASH" || exit

	"$GAUDI_BASH/setup.sh" --silent

	run grep -Fx 'source "$GAUDI_BASH/gaudi_bash.sh"' "$HOME/$GAUDI_BASH_PROFILE"
	assert_success
	run grep -Fxc "# >>> gaudi-bash >>>" "$HOME/$GAUDI_BASH_PROFILE"
	assert_output "1"
	run grep -Fxc "# <<< gaudi-bash <<<" "$HOME/$GAUDI_BASH_PROFILE"
	assert_output "1"
}

@test "gaudi-bash install: appending the template to a profile is idempotent" {

	local profile="$HOME/$GAUDI_BASH_PROFILE"

	# Asking for the usage defines the setup functions without running the setup
	source "$GAUDI_BASH/setup.sh" --help > /dev/null || true

	printf "%s\n" "export MY_SETTING=1" > "$profile"

	run _write_profile_template append
	assert_success
	assert_output --partial "has been added"

	run _write_profile_template append
	assert_success
	assert_output --partial "already loaded"

	assert_equal "$(grep -Fxc "# >>> gaudi-bash >>>" "$profile")" 1
	assert_equal "$(grep -c "gaudi_bash.sh" "$profile")" 1
	assert_equal "$(head -n 1 "$profile")" "export MY_SETTING=1"

	# A profile written by an older version has no markers but already loads gaudi-bash
	printf "%s\n" "export MY_SETTING=1" 'source $GAUDI_BASH/gaudi_bash.sh' > "$profile"

	run _write_profile_template append
	assert_output --partial "already loaded"
	assert_equal "$(wc -l < "$profile" | tr -d ' ')" 2
}

@test "gaudi-bash install: a silent setup fails and says why when a required file is missing" {

	rm "$GAUDI_BASH/template/bash_profile.template.bash"
	__remove_profile_backups
	echo "untouched profile" > "$HOME/$GAUDI_BASH_PROFILE"

	run "$GAUDI_BASH/setup.sh" --silent
	assert_failure
	assert_output --partial "Error: Missing profile template"

	assert_equal "$(< "$HOME/$GAUDI_BASH_PROFILE")" "untouched profile"
}

@test "gaudi-bash install: installer stops when it is run again without an answer" {

	__run_installer_again
	assert_failure
	assert_output --partial "You already have gaudi-bash installed"
	assert_output --partial "leaving the existing installation untouched"

	assert_file_exist "$INSTALL_HOME/.gaudi_bash/existing-installation"
	assert_equal "$(< "$GIT_CALLS")" ""
}

@test "gaudi-bash install: installer stops when it is run again with an answer that is not y or n" {

	__run_installer_again "maybe"
	assert_failure
	assert_output --partial "leaving the existing installation untouched"

	assert_file_exist "$INSTALL_HOME/.gaudi_bash/existing-installation"
	assert_equal "$(< "$GIT_CALLS")" ""
}

@test "gaudi-bash install: installer updates the existing installation with fetch and checkout" {

	__run_installer_again "n"
	assert_success

	assert_file_exist "$INSTALL_HOME/.gaudi_bash/existing-installation"

	run cat "$GIT_CALLS"
	assert_line "-C $INSTALL_HOME/.gaudi_bash fetch origin --tags"
	assert_line "-C $INSTALL_HOME/.gaudi_bash checkout v9.9.9"
	assert_line "-C $INSTALL_HOME/.gaudi_bash submodule update --init --recursive"
	refute_output --partial "pull"
	refute_output --partial "unshallow"
}

@test "gaudi-bash install: installer update completes the history of a shallow clone first" {

	GIT_SHALLOW=1 __run_installer_again "n"
	assert_success

	run cat "$GIT_CALLS"
	assert_line --index 1 "-C $INSTALL_HOME/.gaudi_bash fetch --unshallow origin"
	assert_line "-C $INSTALL_HOME/.gaudi_bash checkout v9.9.9"
}

@test "gaudi-bash install: installer update never moves an installation back that is ahead of the latest release" {

	GIT_AHEAD=1 __run_installer_again "n"
	assert_success
	assert_output --partial "already holds v9.9.9"

	run cat "$GIT_CALLS"
	refute_output --partial "checkout"
	assert_line "-C $INSTALL_HOME/.gaudi_bash submodule update --init --recursive"
}

@test "gaudi-bash install: installer update only fetches the submodules gaudi-bash runs on" {

	# The updated version brings the helper that knows which submodules these are
	mkdir -p "$BATS_TEST_TMPDIR/install-home/.gaudi_bash/lib/helpers"
	cp "$GAUDI_BASH_ORIGIN/lib/helpers/updater.bash" "$BATS_TEST_TMPDIR/install-home/.gaudi_bash/lib/helpers/updater.bash"

	__run_installer_again "n"
	assert_success

	run cat "$GIT_CALLS"
	assert_line "-C $INSTALL_HOME/.gaudi_bash checkout v9.9.9"
	assert_line "-C $INSTALL_HOME/.gaudi_bash submodule update --init --recursive -- components bin/composure"
	assert_line "-C $INSTALL_HOME/.gaudi_bash submodule update --recursive"
	refute_line "-C $INSTALL_HOME/.gaudi_bash submodule update --init --recursive"
	refute_output --partial "bin/bats-core"
}

@test "gaudi-bash install: setup works on the installation it is part of, whatever GAUDI_BASH says" {

	local other="$BATS_TEST_TMPDIR/other-installation"

	mkdir -p "$other"

	# A shell that loaded another installation exports its GAUDI_BASH
	run env GAUDI_BASH="$other" "$GAUDI_BASH/setup.sh" --silent
	assert_success

	run grep -F "export GAUDI_BASH=\"$GAUDI_BASH\"" "$HOME/$GAUDI_BASH_PROFILE"
	assert_success
	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_dir_not_exist "$other/components"
}

@test "gaudi-bash install: setup never reloads the profile, also when started from a gaudi-bash shell" {

	echo 'echo "PROFILE WAS SOURCED" >&2' > "$HOME/$GAUDI_BASH_PROFILE"
	__remove_profile_backups

	# What a shell running gaudi-bash exports
	run env GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE=1 GAUDI_BASH_PROFILE="$GAUDI_BASH_PROFILE" "$GAUDI_BASH/setup.sh" --silent --no-modify-config
	assert_success
	refute_output --partial "PROFILE WAS SOURCED"
	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
}

@test "gaudi-bash install: setup rewrites the absolute links of an older version as relative ones" {

	ln -s "$GAUDI_BASH/components/plugins/lib/git.plugins.bash" "$GAUDI_BASH/components/enabled/250___git.plugins.bash"

	run "$GAUDI_BASH/setup.sh" --silent --basic --no-modify-config
	assert_success

	assert_equal "$(readlink "$GAUDI_BASH/components/enabled/250___git.plugins.bash")" "../plugins/lib/git.plugins.bash"
}

@test "gaudi-bash install: _read_input gives up when there is no terminal to ask on" {

	# perl starts Bash in a session of its own, which has no terminal (/dev/tty can not be opened)
	# shellcheck disable=SC2016
	run perl -MPOSIX -e 'if (fork) { wait; exit($? >> 8) } setsid(); exec @ARGV' \
		bash -c 'source "$GAUDI_BASH/lib/helpers/utils.bash"; _read_input "Sure?"; echo "status: $? reply: [$REPLY]"' < /dev/null
	assert_success
	assert_output "status: 1 reply: []"
}

@test "gaudi-bash install: setup stops instead of asking forever when there is no terminal" {

	echo "untouched profile" > "$HOME/$GAUDI_BASH_PROFILE"
	__remove_profile_backups

	run perl -MPOSIX -e 'if (fork) { wait; exit($? >> 8) } setsid(); exec @ARGV' "$GAUDI_BASH/setup.sh" --basic < /dev/null
	assert_failure
	assert_output --partial "No answer could be read (there is no terminal), run this script with --silent or --no-modify-config"

	assert_equal "$(< "$HOME/$GAUDI_BASH_PROFILE")" "untouched profile"
}
