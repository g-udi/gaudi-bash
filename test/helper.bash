#!/usr/bin/env bash
# shellcheck shell=bash

function load_gaudi_libs() {
	local component lib
	for lib in "$@"; do
		component=$(find "${GAUDI_BASH}/lib" -type f -iname "${lib}.bash")
		load "$component"
	done
	return 0
}

# Copies the gaudi-bash files under test into the test installation (everything but git's own folder, the vendored
# dependencies and the components, which the tests get from GAUDI_BASH_ORIGIN)
sync_gaudi_test_install() {
	(
		cd "${GAUDI_BASH_ORIGIN}" \
			&& tar \
				--exclude='.git' \
				--exclude='bin' \
				--exclude='components' \
				-cf - .
	) | (
		cd "${GAUDI_BASH}" \
			&& tar -xf -
	)
}

# Makes the test installation: a copy of the files in a temporary folder, which is a git repository of its own
# (`gbash version` asks git about it). Nothing is ever written to the repository the tests are started from.
make_gaudi_test_install() {
	mkdir -p "${GAUDI_BASH}"
	sync_gaudi_test_install

	if [[ ! -d "${GAUDI_BASH}/.git" ]]; then
		git -C "${GAUDI_BASH}" init -q -b main
		git -C "${GAUDI_BASH}" remote add origin "https://github.com/g-udi/gaudi-bash.git"
		git -C "${GAUDI_BASH}" commit -q --allow-empty -m "gaudi-bash test installation"
	fi
}

function setup() {

	# Keep git away from the configuration of the machine (the user's is out of reach: HOME is a temporary folder)
	export GIT_CONFIG_NOSYSTEM=1
	# Every test gets a cache of its own, nothing is shared between tests or kept between runs
	export XDG_CACHE_HOME="${BATS_TEST_TMPDIR?}/cache"

	# Every test starts from the same profile (a fixture), never from the profile of the machine running the tests
	cp "${GAUDI_TEST_DIRECTORY?}/fixtures/home/profile.bash" "$HOME/$GAUDI_BASH_PROFILE"
	# This sets up a local test fixture, i.e. a completely fresh and isolated gaudi-bash directory. This is done to avoid messing with your own gaudi-bash source directory.
	make_gaudi_test_install

	# Ensure clean runtime state for each test
	rm -rf "$GAUDI_BASH/tmp" "$GAUDI_BASH/profiles"
	mkdir -p "$GAUDI_BASH/components/enabled"

	cp -r "$GAUDI_BASH_ORIGIN/components/aliases" "$GAUDI_BASH/components/aliases"
	cp -r "$GAUDI_BASH_ORIGIN/components/plugins" "$GAUDI_BASH/components/plugins"
	cp -r "$GAUDI_BASH_ORIGIN/components/completions" "$GAUDI_BASH/components/completions"
	cp -r "$GAUDI_BASH_ORIGIN/components/themes" "$GAUDI_BASH/components/themes"

	local_setup
}

function setup_file() {

	# export *everything* to subshells, needed to support tests
	set -a

	# Load the BATS modules we use:
	load "${GAUDI_TEST_DEPS_DIR}/bats-support/load.bash"
	load "${GAUDI_TEST_DEPS_DIR}/bats-assert/load.bash"
	load "${GAUDI_TEST_DEPS_DIR}/bats-file/load.bash"

	# Clear any inherited environment: the gaudi-bash settings of the shell the tests are started from
	# (GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE, GAUDI_BASH_LOG_LEVEL, GAUDI_BASH_THEME, ...) must not
	# reach the tests. Only what test/run sets for the tests is kept.
	local variable
	# shellcheck disable=SC2034 # avoid possible invalid reference:
	XDG_DUMMY="" GAUDI_BASH_DUMMY="" GAUDI_HOST_DUMMY="" COMMAND_DURATION_DUMMY=""
	for variable in "${!XDG_@}" "${!GAUDI_BASH_@}" "${!GAUDI_HOST_@}" "${!COMMAND_DURATION_@}"; do
		case "$variable" in
			GAUDI_BASH_DIR | GAUDI_BASH_ORIGIN | GAUDI_BASH_PROFILE) ;;
			*) unset "$variable" ;;
		esac
	done
	unset GIT_HOSTING NGINX_PATH IRC_CLIENT TODO SCM_CHECK GAUDI_LOG_DISABLE_COLOR
	unset HISTFILE HISTSIZE HISTFILESIZE

	# Some tools, e.g. `git` use configuration files from the $HOME directory,
	# which interferes with our tests. The only way to keep `git` from doing
	# this seems to set HOME explicitly to a separate location.
	# Refer to https://git-scm.com/docs/git-config#FILES
	readonly HOME="${BATS_SUITE_TMPDIR?}"
	mkdir -p "${HOME}"

	# For `git` tests to run well, user name and email need to be set.
	# Refer to https://git-scm.com/docs/git-commit#_commit_information.
	# This goes to the test-specific config, due to the $HOME overridden above.
	git config --global user.name "gaudi-bash bats runner"
	git config --global user.email "bash@gaudi.bash"
	git config --global advice.detachedHead false
	git config --global init.defaultBranch "main"

	# Locate the temporary folder, avoid double-slash.
	GAUDI_BASH="${BATS_FILE_TMPDIR//\/\///}/.gaudi_bash"
	make_gaudi_test_install

	load "$GAUDI_BASH_ORIGIN/lib/composure.bash"
	cite about param example group priority

	# Run any local test setup
	local_setup_file

	set +a # not needed, but symmetric!
}

function teardown_file() {
	rm -rf "${GAUDI_BASH?}"
}

function local_setup() {
	true
}

function local_teardown() {
	true
}

function local_setup_file() {
	true
}

function teardown() {
	unset GIT_CONFIG_NOSYSTEM

	rm -rf "${GAUDI_BASH?}/components"
	rm -rf "${GAUDI_BASH?}/tmp"
	rm -rf "${GAUDI_BASH?}/profiles"

	local_teardown

}
