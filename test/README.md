# Testing with Bats

## Overview

The gaudi-bash unit tests leverage the [Bats unit test framework for Bash](https://github.com/bats-core/bats-core).
There is no need to install Bats explicitly: Bats and its helper libraries are vendored as git submodules under `bin/`, and the test run script fetches them with `git submodule update --init --recursive`.

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

## Writing Tests

When adding or modifying tests, please stick to the format and conventions of the existing test cases.
The `helper.bash` script provides a couple of reusable helper functions that you should use when writing a test case,
for example for setting up an isolated test environment.
