#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	load_gaudi_libs gaudi-bash
}

# --- Plugin enable/disable smoke tests ---

@test "gaudi-bash components: should enable and disable the sudo plugin" {
	cd "$GAUDI_BASH"
	run _gaudi-bash-enable plugins sudo
	assert_success
	assert_file_exist "$GAUDI_BASH/components/enabled/250___sudo.plugins.bash"

	run _gaudi-bash-disable plugins sudo
	assert_success
	assert_file_not_exist "$GAUDI_BASH/components/enabled/250___sudo.plugins.bash"
}

@test "gaudi-bash components: should enable and disable the url plugin" {
	cd "$GAUDI_BASH"
	run _gaudi-bash-enable plugins url
	assert_success
	assert_file_exist "$GAUDI_BASH/components/enabled/250___url.plugins.bash"

	run _gaudi-bash-disable plugins url
	assert_success
}

@test "gaudi-bash components: should enable and disable the fasd plugin" {
	cd "$GAUDI_BASH"
	run _gaudi-bash-enable plugins fasd
	assert_success
	assert_file_exist "$GAUDI_BASH/components/enabled/250___fasd.plugins.bash"

	run _gaudi-bash-disable plugins fasd
	assert_success
}

@test "gaudi-bash components: should enable and disable the python plugin" {
	cd "$GAUDI_BASH"
	run _gaudi-bash-enable plugins python
	assert_success
	assert_file_exist "$GAUDI_BASH/components/enabled/250___python.plugins.bash"

	run _gaudi-bash-disable plugins python
	assert_success
}

@test "gaudi-bash components: should enable and disable the history-eternal plugin" {
	cd "$GAUDI_BASH"
	run _gaudi-bash-enable plugins history-eternal
	assert_success
	assert_file_exist "$GAUDI_BASH/components/enabled/250___history-eternal.plugins.bash"

	run _gaudi-bash-disable plugins history-eternal
	assert_success
}

@test "gaudi-bash components: should enable and disable the history-substring-search plugin" {
	cd "$GAUDI_BASH"
	run _gaudi-bash-enable plugins history-substring-search
	assert_success
	assert_file_exist "$GAUDI_BASH/components/enabled/250___history-substring-search.plugins.bash"

	run _gaudi-bash-disable plugins history-substring-search
	assert_success
}

@test "gaudi-bash components: should enable and disable the cmd-returned-notify plugin" {
	cd "$GAUDI_BASH"
	run _gaudi-bash-enable plugins cmd-returned-notify
	assert_success
	assert_file_exist "$GAUDI_BASH/components/enabled/250___cmd-returned-notify.plugins.bash"

	run _gaudi-bash-disable plugins cmd-returned-notify
	assert_success
}

# --- Completion enable/disable smoke tests ---

@test "gaudi-bash components: should enable and disable the cargo completion" {
	cd "$GAUDI_BASH"
	run _gaudi-bash-enable completions cargo
	assert_success
	assert_file_exist "$GAUDI_BASH/components/enabled/350___cargo.completions.bash"

	run _gaudi-bash-disable completions cargo
	assert_success
}

@test "gaudi-bash components: should enable and disable the rustup completion" {
	cd "$GAUDI_BASH"
	run _gaudi-bash-enable completions rustup
	assert_success

	run _gaudi-bash-disable completions rustup
	assert_success
}

@test "gaudi-bash components: should enable and disable the github-cli completion" {
	cd "$GAUDI_BASH"
	run _gaudi-bash-enable completions github-cli
	assert_success

	run _gaudi-bash-disable completions github-cli
	assert_success
}

@test "gaudi-bash components: should enable and disable the dotnet completion" {
	cd "$GAUDI_BASH"
	run _gaudi-bash-enable completions dotnet
	assert_success

	run _gaudi-bash-disable completions dotnet
	assert_success
}

@test "gaudi-bash components: should enable and disable the yarn completion" {
	cd "$GAUDI_BASH"
	run _gaudi-bash-enable completions yarn
	assert_success

	run _gaudi-bash-disable completions yarn
	assert_success
}

@test "gaudi-bash components: should enable and disable the kind completion" {
	cd "$GAUDI_BASH"
	run _gaudi-bash-enable completions kind
	assert_success

	run _gaudi-bash-disable completions kind
	assert_success
}

# --- Alias enable/disable smoke tests ---

@test "gaudi-bash components: should enable and disable the terraform aliases" {
	cd "$GAUDI_BASH"
	run _gaudi-bash-enable aliases terraform
	assert_success
	assert_file_exist "$GAUDI_BASH/components/enabled/150___terraform.aliases.bash"

	run _gaudi-bash-disable aliases terraform
	assert_success
}

@test "gaudi-bash components: should enable and disable the composer aliases" {
	cd "$GAUDI_BASH"
	run _gaudi-bash-enable aliases composer
	assert_success
	assert_file_exist "$GAUDI_BASH/components/enabled/150___composer.aliases.bash"

	run _gaudi-bash-disable aliases composer
	assert_success
}

@test "gaudi-bash components: should enable and disable the directory aliases" {
	cd "$GAUDI_BASH"
	run _gaudi-bash-enable aliases directory
	assert_success
	assert_file_exist "$GAUDI_BASH/components/enabled/150___directory.aliases.bash"

	run _gaudi-bash-disable aliases directory
	assert_success
}
