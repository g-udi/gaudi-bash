function setup_file() {
	# export *everything* to subshells, needed to support tests
	set -a

	# Load the BATS modules we use:
	load "${GAUDI_TEST_DEPS_DIR}/bats-support/load.bash"
	load "${GAUDI_TEST_DEPS_DIR}/bats-assert/load.bash"
	load "${GAUDI_TEST_DEPS_DIR}/bats-file/load.bash"

	# shellcheck disable=SC2034 # Clear any inherited environment:
	XDG_DUMMY="" BASH_IT_DUMMY=""    # avoid possible invalid reference:
	unset "${!XDG_@}" "${!BASH_IT@}" # unset all BASH_IT* and XDG_* variables
	unset GIT_HOSTING NGINX_PATH IRC_CLIENT TODO SCM_CHECK

	# Some tools, e.g. `git` use configuration files from the $HOME directory,
	# which interferes with our tests. The only way to keep `git` from doing
	# this seems to set HOME explicitly to a separate location.
	# Refer to https://git-scm.com/docs/git-config#FILES.
	cp -r "$HOME/$GAUDI_BASH_BASHRC_PROFILE" "$BATS_SUITE_TMPDIR"
	readonly HOME="${BATS_SUITE_TMPDIR?}"
	mkdir -p "${HOME}"

	# For `git` tests to run well, user name and email need to be set.
	# Refer to https://git-scm.com/docs/git-commit#_commit_information.
	# This goes to the test-specific config, due to the $HOME overridden above.
	git config --global user.name "gaudi-bash bats runner"
	git config --global user.email "bash@gaudi.bash"
	git config --global advice.detachedHead false
	git config --global init.defaultBranch "master"

	# Locate the temporary folder, avoid double-slash.
	GAUDI_BASH="${BATS_FILE_TMPDIR//\/\///}/.gaudi_bash"
	# This sets up a local test fixture, i.e. a completely fresh and isolated gaudi-bash directory. This is done to avoid messing with your own gaudi-bash source directory.
	git --git-dir="${GAUDI_BASH_GIT_DIR?}" worktree add -d "${GAUDI_BASH}"

	cp -r "$GAUDI_BASH_ORIGIN/components/aliases" "$GAUDI_BASH/components/aliases"
	cp -r "$GAUDI_BASH_ORIGIN/components/plugins" "$GAUDI_BASH/components/plugins"
	cp -r "$GAUDI_BASH_ORIGIN/components/completions" "$GAUDI_BASH/components/completions"

	load "$GAUDI_BASH_ORIGIN/lib/composure.bash"
	cite about param example group priority

	# Run any local test setup
	local_setup_file
	set +a # not needed, but symetiric!
}

function load_gaudi_libs() {
	for lib in "$@"; do
		component=$(find "${GAUDI_BASH}/lib" -type f -iname "${lib}.bash")
		load "$component"
	done
	return 0
}

function local_setup_file() {
	true
}

function local_setup() {
	true
}

function local_teardown() {
	true
}

function setup_test_fixture() {
	mkdir -p "${GAUDI_BASH?}/enabled"
}

function setup() {
	# be independent of git's system configuration
	export GIT_CONFIG_NOSYSTEM
	export XDG_CACHE_HOME="${GAUDI_TEST_DIRECTORY?}"

	setup_test_fixture
	local_setup
}

function teardown() {
	unset GIT_CONFIG_NOSYSTEM
	local_teardown
	
	rm -rf "${GAUDI_BASH?}/enabled"
	rm -rf "${GAUDI_BASH?}/tmp/cache"
	rm -rf "${GAUDI_BASH?}/profiles"/test*.bash_it
}

function teardown_file() {
	# This only serves to clean metadata from the real git repo.
	git --git-dir="${GAUDI_BASH_GIT_DIR?}" worktree remove -f "${GAUDI_BASH?}"
}