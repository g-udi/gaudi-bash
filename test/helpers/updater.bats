#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

run_updater_script() {
	local script="$BATS_TEST_TMPDIR/run-updater.sh"

	UPDATE_GIT_CALLS="$BATS_TEST_TMPDIR/git.calls"
	: > "$UPDATE_GIT_CALLS"

	cat > "$script" << 'SCRIPT'
#!/bin/bash

GIT_CALLS="$1"
shift

source "$GAUDI_BASH/lib/composure.bash"
cite about param example group priority
source "$GAUDI_BASH/lib/gaudi-bash.bash"

git() {
	printf "%s\n" "$*" >> "$GIT_CALLS"
	case "$1" in
		diff)
			return 0
			;;
		fetch)
			return 0
			;;
		describe)
			printf "%s\n" "v1.2.3"
			return 0
			;;
		rev-list)
			case "$2" in
				--tags)
					printf "%s\n" "tagsha"
					;;
				HEAD..v1.2.3 | HEAD..origin/master)
					printf "%s\n" "commitsha"
					;;
				v1.2.3..HEAD)
					return 0
					;;
				*)
					return 0
					;;
			esac
			return 0
			;;
		log)
			if [[ "$2" == "-1" ]]; then
				printf "%s\n" "abc123"
			else
				printf "%s\n" "abc123: test change (gaudi-bash bats runner)"
			fi
			return 0
			;;
		checkout | submodule)
			return 0
			;;
	esac

	return 0
}

_gaudi-bash-restart() {
	printf "%s\n" "restart" >> "$GIT_CALLS"
}

_gaudi-bash-update "$@"
SCRIPT

	chmod +x "$script"

	run env GAUDI_BASH="$GAUDI_BASH" /bin/bash "$script" "$UPDATE_GIT_CALLS" "$@"
}

@test "gaudi-bash helpers: updater: should reject unsupported update modes" {

	run_updater_script unsupported
	assert_failure
	assert_output "Usage: gaudi-bash update [stable|dev|all] [--silent|-s]"
}

@test "gaudi-bash helpers: updater: should reject mixed positional update modes" {

	run_updater_script dev all
	assert_failure
	assert_output "Usage: gaudi-bash update [stable|dev|all] [--silent|-s]"
}

@test "gaudi-bash helpers: updater: update all should sync submodules after updating stable core" {

	run_updater_script all --silent
	assert_success

	run cat "$UPDATE_GIT_CALLS"
	assert_output --partial "fetch origin --tags"
	assert_output --partial "checkout v1.2.3"
	assert_output --partial "submodule sync --recursive"
	assert_output --partial "submodule update --init --recursive"
}

@test "gaudi-bash helpers: updater: update dev should not sync submodules" {

	run_updater_script dev --silent
	assert_success

	run grep -F "submodule" "$UPDATE_GIT_CALLS"
	assert_failure
}
