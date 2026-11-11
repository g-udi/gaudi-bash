# Testing with Bats

## Overview

The gaudi-bash unit tests leverage the [Bats unit test framework for Bash](https://github.com/bats-core/bats-core).
There is no need to install Bats explicitly: Bats and its helper libraries are vendored as git submodules under `bin/`. An installation made with `install.sh` or `setup.sh` does not fetch them, so fetch them once before running the tests:

```bash
git submodule update --init --recursive
```

The test run script only checks that the submodules it needs are there and tells you which ones are missing. It never fetches or moves them itself, so a submodule you are working on is left as it is and a test run needs no network.

When making changes to gaudi-bash, the tests are automatically executed by the [GitHub Actions](https://docs.github.com/en/actions) workflow in `.github/workflows/ci.yml` on `ubuntu-24.04`, `ubuntu-22.04`, `macos-15` and `macos-26`.

## Test Execution

To execute the unit tests, please run the `run` script:

```bash
# If you are in the `test` directory:
./run

# If you are in the root `.gaudi_bash` directory:
test/run
```

The `run` script will then run all tests found under the `test` directory, including subdirectories: first every `.bats` file except the search tests, then the search tests on their own.

To run a subset, pass one or more `.bats` files or directories (relative to the current directory, or absolute). Only those are run:

```bash
test/run test/helpers/help.bats
test/run test/lib/search.bats test/scripts
```

## Writing Tests

When adding or modifying tests, please stick to the format and conventions of the existing test cases.
The `helper.bash` script provides a couple of reusable helper functions that you should use when writing a test case,
for example for setting up an isolated test environment.

Tests must not depend on the machine they run on: every test starts from the profile in `test/fixtures/home/`, a temporary `HOME` and a cache directory of its own.
