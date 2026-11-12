#!/usr/bin/env bats
# shellcheck shell=bats
# shellcheck disable=SC2294,SC2004,SC2034

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	load_gaudi_libs gaudi-bash

	# The components are copied into the test directory for every test, so the completion is loaded here
	load "$GAUDI_BASH/components/completions/lib/gaudi-bash.completions.bash"

	# Components that only exist for these tests, so the expectations do not depend on the real component lists
	touch "$GAUDI_BASH/components/aliases/lib/zzgaudi-one.aliases.bash"
	touch "$GAUDI_BASH/components/aliases/lib/zzgaudi-two.aliases.bash"
	touch "$GAUDI_BASH/components/plugins/lib/zzgaudi-one.plugins.bash"
	touch "$GAUDI_BASH/components/completions/lib/zzgaudi-one.completions.bash"
}

__enable_fixture() {
	ln -s "$GAUDI_BASH/components/$1/lib/$2.$1.bash" "$GAUDI_BASH/components/enabled/$3___$2.$1.bash"
	assert_link_exist "$GAUDI_BASH/components/enabled/$3___$2.$1.bash"
}

__check_completion() {
	# Get the parameters as a single value
	COMP_LINE=$*

	# Get the parameters as an array
	eval set -- "$@"
	COMP_WORDS=("$@")

	# Index of the cursor in the line
	COMP_POINT=${#COMP_LINE}

	# Get the last character of the line that was entered
	COMP_LAST=$((${COMP_POINT} - 1))

	# If the last character was a space...
	if [[ ${COMP_LINE:$COMP_LAST} = ' ' ]]; then
		# ...then add an empty array item
		COMP_WORDS+=('')
	fi

	# Word index of the last word
	COMP_CWORD=$((${#COMP_WORDS[@]} - 1))

	# Run the gaudi-bash completion function
	_gaudi-bash-comp

	# Return the completion output
	echo "${COMPREPLY[@]}"
}

@test "gaudi-bash completion: ensure that the _gaudi-bash-comp function is available" {
	run type -a _gaudi-bash-comp &> /dev/null
	assert_success
}

@test "gaudi-bash completion: the completion is registered for the gbash command" {
	run complete -p gbash
	assert_success
	assert_output --partial "_gaudi-bash-comp"
}

@test "gaudi-bash completion: show options" {

	run __check_completion 'gbash '
	assert_line --index 0 "show enable disable reload restart search update migrate backup restore profile doctor help version"
}

@test "gaudi-bash completion: show options matching the typed verb" {

	run __check_completion 'gbash re'
	assert_line --index 0 "reload restart restore"
}

@test "gaudi-bash completion: doctor - show options" {

	run __check_completion 'gbash doctor '
	assert_line --index 0 "errors warnings all"
}

@test "gaudi-bash completion: help - show options" {

	run __check_completion 'gbash help '
	assert_line --index 0 "aliases completions plugins"
}

@test "gaudi-bash completion: help - provide the available aliases" {

	run __check_completion 'gbash help aliases zzgaudi'
	assert_line --index 0 "zzgaudi-one zzgaudi-two"
}

@test "gaudi-bash completion: help - provide the available plugins" {

	run __check_completion 'gbash help plugins zzgaudi'
	assert_line --index 0 "zzgaudi-one"
}

@test "gaudi-bash completion: update - show no options" {

	run __check_completion 'gbash update '
	refute_output
}

@test "gaudi-bash completion: show - show options" {

	run __check_completion 'gbash show '
	assert_line --index 0 "aliases completions plugins"
}

@test "gaudi-bash completion: disable - show options" {

	run __check_completion 'gbash disable '
	assert_line --index 0 "alias completion plugin"
}

@test "gaudi-bash completion: disable - show options a" {

	run __check_completion 'gbash disable a'
	assert_line --index 0 "alias"
}

@test "gaudi-bash completion: disable - provide nothing when the alias is not enabled" {

	run __check_completion 'gbash disable alias zzgaudi'
	refute_output
}

@test "gaudi-bash completion: disable - provide all when no alias is enabled" {

	run __check_completion 'gbash disable alias a'
	assert_line --index 0 "all"
}

@test "gaudi-bash completion: disable - provide the enabled aliases only" {

	__enable_fixture aliases zzgaudi-one 150
	__enable_fixture plugins zzgaudi-one 250

	run __check_completion 'gbash disable alias zzgaudi'
	assert_output --partial "zzgaudi-one"
	refute_output --partial "zzgaudi-two"
}

@test "gaudi-bash completion: disable - provide the enabled plugins only" {

	__enable_fixture aliases zzgaudi-two 150
	__enable_fixture plugins zzgaudi-one 250

	run __check_completion 'gbash disable plugin zzgaudi'
	assert_output --partial "zzgaudi-one"
	refute_output --partial "zzgaudi-two"
}

@test "gaudi-bash completion: disable - provide the enabled completions only" {

	__enable_fixture completions zzgaudi-one 350

	run __check_completion 'gbash disable completion zzgaudi'
	assert_output --partial "zzgaudi-one"
}

@test "gaudi-bash completion: enable - show options" {

	run __check_completion 'gbash enable '
	assert_line --index 0 "alias completion plugin"
}

@test "gaudi-bash completion: enable - show options a" {

	run __check_completion 'gbash enable a'
	assert_line --index 0 "alias"
}

@test "gaudi-bash completion: enable - provide all and the aliases when none is enabled" {

	run __check_completion 'gbash enable alias '
	assert_output --regexp "^all .*zzgaudi-one zzgaudi-two"
}

@test "gaudi-bash completion: enable - provide the aliases that are not enabled" {

	run __check_completion 'gbash enable alias zzgaudi'
	assert_line --index 0 "zzgaudi-one zzgaudi-two"
}

@test "gaudi-bash completion: enable - leave out the aliases that are already enabled" {

	__enable_fixture aliases zzgaudi-one 150

	run __check_completion 'gbash enable alias zzgaudi'
	assert_line --index 0 "zzgaudi-two"
}

@test "gaudi-bash completion: enable - an enabled plugin does not hide the alias with the same name" {

	__enable_fixture plugins zzgaudi-one 250

	run __check_completion 'gbash enable alias zzgaudi'
	assert_line --index 0 "zzgaudi-one zzgaudi-two"
}

@test "gaudi-bash completion: enable - provide the plugins that are not enabled" {

	run __check_completion 'gbash enable plugin zzgaudi'
	assert_line --index 0 "zzgaudi-one"
}

@test "gaudi-bash completion: enable - provide the completions that are not enabled" {

	run __check_completion 'gbash enable completion zzgaudi'
	assert_line --index 0 "zzgaudi-one"
}
