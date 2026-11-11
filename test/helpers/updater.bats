#!/usr/bin/env bats
# shellcheck shell=bats
# shellcheck disable=SC2030,SC2031,SC2329

load "$GAUDI_TEST_DIRECTORY"/helper.bash

# These tests update a throwaway gaudi-bash "installation" made from temporary local repositories:
#   origin              stands for the gaudi-bash core repository, released as v1.0.0
#   origin/components   stands for the components repository (a git submodule of the core)
#   install             the installation that `gbash update` works on
# Nothing is fetched from the network.

local_setup() {
	load_gaudi_libs gaudi-bash

	# A real update ends by replacing the shell (exec), which must not happen to the test process
	_gaudi-bash-restart() {
		echo "RESTARTED"
		exit 0
	}

	UPDATER_ROOT="$BATS_TEST_TMPDIR/updater"
	UPDATER_INSTALL="$UPDATER_ROOT/install"
	UPDATER_CLOCK=0

	mkdir -p "$UPDATER_ROOT"

	git init -q -b main "$UPDATER_ROOT/origin"
	git init -q -b main "$UPDATER_ROOT/origin/components"
	_commit origin/components "components 1"

	git -C "$UPDATER_ROOT/origin" submodule --quiet add "$UPDATER_ROOT/origin/components" components 2> /dev/null
	_commit origin "core 1"
	git -C "$UPDATER_ROOT/origin" tag v1.0.0

	# The installation is a copy with the fixture repositories as its remotes
	cp -R "$UPDATER_ROOT/origin" "$UPDATER_INSTALL"
	git -C "$UPDATER_INSTALL" remote add origin "$UPDATER_ROOT/origin"
	git -C "$UPDATER_INSTALL/components" remote add origin "$UPDATER_ROOT/origin/components"
	git -C "$UPDATER_INSTALL" fetch -q origin --tags
}

# Commits a change to one of the fixture repositories, each commit is a minute younger than the previous one
_commit() {
	local repo="$UPDATER_ROOT/$1" date

	UPDATER_CLOCK=$((UPDATER_CLOCK + 1))
	printf -v date "2026-01-01T00:%02d:00" "$UPDATER_CLOCK"

	echo "$2" >> "$repo/changes.txt"
	git -C "$repo" add -A
	GIT_AUTHOR_DATE="$date" GIT_COMMITTER_DATE="$date" git -C "$repo" commit -q -m "$2"
}

# Releases a new core version, optionally (bump) pinning a newer commit of the components
_release() {
	local tag="$1" bump="${2:-}"

	if [[ "$bump" == "bump" ]]; then
		_commit origin/components "components for $tag"
		# git refuses to fetch a submodule from a local path by itself (protocol.file.allow), so the new commit is
		# fetched here; with a real remote `git submodule update` gets it on its own
		git -C "$UPDATER_INSTALL/components" fetch -q origin
	fi
	_commit origin "core $tag"
	git -C "$UPDATER_ROOT/origin" tag "$tag"
}

_install_head() {
	git -C "$UPDATER_INSTALL" rev-parse HEAD
}

@test "gaudi-bash helpers: updater: should update to the latest stable version" {

	_release v2.0.0

	GAUDI_BASH="$UPDATER_INSTALL" run _gaudi-bash-update --silent
	assert_success
	assert_output --partial "Updating to v2.0.0"
	assert_output --partial "gaudi-bash successfully updated."
	assert_output --partial "RESTARTED"
	assert_equal "$(_install_head)" "$(git -C "$UPDATER_ROOT/origin" rev-parse "v2.0.0^{commit}")"
}

@test "gaudi-bash helpers: updater: should bring the submodules to the commits pinned by the new version" {

	_release v2.0.0 bump

	GAUDI_BASH="$UPDATER_INSTALL" run _gaudi-bash-update stable --silent
	assert_success
	assert_output --partial "RESTARTED"

	assert_equal "$(git -C "$UPDATER_INSTALL/components" rev-parse HEAD)" "$(git -C "$UPDATER_ROOT/origin/components" rev-parse HEAD)"
	run git -C "$UPDATER_INSTALL" status --porcelain
	assert_output ""
}

@test "gaudi-bash helpers: updater: should keep updating after a release moved a submodule" {

	_release v2.0.0 bump

	# The state an update without a submodule update leaves behind: the core moved on, the components did not
	git -C "$UPDATER_INSTALL" fetch -q origin --tags
	git -C "$UPDATER_INSTALL" checkout -q v2.0.0
	run git -C "$UPDATER_INSTALL" diff --name-status
	assert_output --partial "components"

	_release v3.0.0

	GAUDI_BASH="$UPDATER_INSTALL" run _gaudi-bash-update --silent
	assert_success
	refute_output --partial "Local changes detected"
	assert_output --partial "RESTARTED"
	assert_equal "$(_install_head)" "$(git -C "$UPDATER_ROOT/origin" rev-parse "v3.0.0^{commit}")"

	run git -C "$UPDATER_INSTALL" status --porcelain
	assert_output ""
}

@test "gaudi-bash helpers: updater: should refuse to update over local changes to tracked files" {

	local head

	_release v2.0.0
	head="$(_install_head)"
	echo "local edit" >> "$UPDATER_INSTALL/changes.txt"

	GAUDI_BASH="$UPDATER_INSTALL" run _gaudi-bash-update --silent
	assert_failure
	assert_output --partial "Local changes detected"
	assert_output --partial "changes.txt"
	assert_equal "$(_install_head)" "$head"
}

@test "gaudi-bash helpers: updater: should update to the development branch" {

	_release v2.0.0
	_commit origin "core unreleased"

	GAUDI_BASH="$UPDATER_INSTALL" run _gaudi-bash-update dev --silent
	assert_success
	assert_output --partial "Updating to origin/main"
	assert_output --partial "RESTARTED"
	assert_equal "$(_install_head)" "$(git -C "$UPDATER_ROOT/origin" rev-parse main)"
}

@test "gaudi-bash helpers: updater: should report when there is nothing to update" {

	GAUDI_BASH="$UPDATER_INSTALL" run _gaudi-bash-update --silent
	assert_success
	assert_output --partial "You're on the latest stable version"
	refute_output --partial "RESTARTED"

	GAUDI_BASH="$UPDATER_INSTALL" run _gaudi-bash-update dev --silent
	assert_success
	assert_output --partial "gaudi-bash is up to date"
}

@test "gaudi-bash helpers: updater: should only accept stable or dev as the update mode" {

	local head mode

	_release v2.0.0
	head="$(_install_head)"

	for mode in --help latest stabel; do
		GAUDI_BASH="$UPDATER_INSTALL" run _gaudi-bash-update "$mode" --silent
		assert_failure
		assert_output --partial "Unknown update mode: $mode"
		assert_output --partial "Usage: gbash update [stable|dev]"
	done

	assert_equal "$(_install_head)" "$head"
}

@test "gaudi-bash helpers: updater: should fail when the remote can not be fetched" {

	git -C "$UPDATER_INSTALL" remote set-url origin "$UPDATER_ROOT/gone"

	GAUDI_BASH="$UPDATER_INSTALL" run _gaudi-bash-update --silent
	assert_failure
	assert_output --partial "Unable to fetch from 'origin'"
	refute_output --partial "latest stable version"

	GAUDI_BASH="$UPDATER_INSTALL" run _gaudi-bash-update dev --silent
	assert_failure
	refute_output --partial "up to date"
}

@test "gaudi-bash helpers: updater: should leave the working directory where it was" {

	local current="$PWD"

	GAUDI_BASH="$UPDATER_INSTALL" _gaudi-bash-update --silent
	assert_equal "$PWD" "$current"
}

@test "gaudi-bash helpers: updater: _gaudi-bash-submodules-update should fetch what gaudi-bash runs on and leave out what only the tests need" {

	# The core gets a second submodule, standing for bats
	git init -q -b main "$UPDATER_ROOT/origin/bin/bats-core"
	_commit origin/bin/bats-core "bats 1"
	git -C "$UPDATER_ROOT/origin" submodule --quiet add "$UPDATER_ROOT/origin/bin/bats-core" bin/bats-core 2> /dev/null
	_commit origin "core with bats"

	# A clone without submodules, as the installer makes it
	git clone -q "$UPDATER_ROOT/origin" "$UPDATER_ROOT/fresh"
	assert_file_not_exist "$UPDATER_ROOT/fresh/components/changes.txt"

	# git only fetches a submodule from a local path when it is told that this is fine
	GIT_CONFIG_COUNT=1 GIT_CONFIG_KEY_0=protocol.file.allow GIT_CONFIG_VALUE_0=always run _gaudi-bash-submodules-update "$UPDATER_ROOT/fresh"
	assert_success

	assert_file_exist "$UPDATER_ROOT/fresh/components/changes.txt"
	assert_file_not_exist "$UPDATER_ROOT/fresh/bin/bats-core/changes.txt"
}
