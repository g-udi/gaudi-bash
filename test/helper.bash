export GIT_CONFIG_NOSYSTEM


local_setup() {
  true
}

local_teardown() {
  true
}

case $OSTYPE in
  darwin*)
    CONFIG_FILE=.bash_profile
    ;;
  *)
    CONFIG_FILE=.bashrc
    ;;
esac

# This function sets up a local test fixture, i.e. a completely fresh and isolated bash-it directory.
# This is done to avoid messing with your own bash-it source directory.
# If you need this, call it in your .bats file's `local_setup` function.
prepare () {
  local lib_directory  src_topdir

  # Create the bash_it folder in the temp test directory
  mkdir -p "$BASH_IT"

  # Get the root folder of bash_it by traversing from the bats lib location
  lib_directory="$(cd "$(dirname "$0")" && pwd)"
  src_topdir="$lib_directory/../../../.."

  if command -v rsync &> /dev/null
  then
    # Use rsync to copy bash-it to the temp folder
    rsync -qavrKL -d --delete-excluded --exclude=.git "$src_topdir" "$BASH_IT"
  else
    rm -rf "$BASH_IT"
    mkdir -p "$BASH_IT"

    find "$src_topdir" \
      -mindepth 1 -maxdepth 1 \
      -not -name .git \
      -exec cp -r {} "$BASH_IT" \;
  fi

  rm -rf "$BASH_IT/components/enabled"
  mkdir -p "$BASH_IT/components/enabled"
}

setup () {

  # TEST_MAIN_DIR Points to the 'test' folder location e.g., $HOME/.bash_it/test/
  export TEST_MAIN_DIR="${BATS_TEST_DIRNAME}/.."
  # TEST_DEPS_DIR will point to the folder where the bats git submodules are
  export TEST_DEPS_DIR="${TEST_DEPS_DIR-${TEST_MAIN_DIR}/../bin}"

  load "${TEST_DEPS_DIR}/bats-support/load.bash"
  load "${TEST_DEPS_DIR}/bats-assert/load.bash"
  load "${TEST_DEPS_DIR}/bats-file/load.bash"

  # Create a temp directory with a 'bash-it-test-' prefix
  TEST_TEMP_DIR="$(temp_make --prefix 'bash-it-test-')"

  export BATSLIB_FILE_PATH_REM="#${TEST_TEMP_DIR}"
  export BATSLIB_FILE_PATH_ADD='<temp>'
  export BASH_IT="${TEST_TEMP_DIR}/.bash_it"
  export TEST_TEMP_DIR

  # Some tools, e.g. `git` use configuration files from the $HOME directory,
  # which interferes with our tests. The only way to keep `git` from doing this
  # seems to set HOME explicitly to a separate location [ref: https://git-scm.com/docs/git-config#FILES]
  unset XDG_CONFIG_HOME
  export HOME="${TEST_TEMP_DIR}"
  mkdir -p "${HOME}"

  # For `git` tests to run well, user name and email need to be set [ref: https://git-scm.com/docs/git-commit#_commit_information]
  # This goes to the test-specific config, due to the $HOME overridden above
  git config --global user.name "John Doe"
  git config --global user.email "johndoe@example.com"

  local_setup
}

teardown () {
  local_teardown

  rm -rf "${BASH_IT}"
  temp_del "${TEST_TEMP_DIR}"
}


