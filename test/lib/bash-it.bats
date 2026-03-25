#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	load_gaudi_libs gaudi-bash
}

assert_sane_defaults() {
	assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/150___gaudi-bash.aliases.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/325___system.completions.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"

	assert_file_not_exist "$GAUDI_BASH/components/enabled/150___gls.aliases.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/350___git.completions.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/365___alias-completion.plugins.bash"
}

assert_default_backup_file() {
	assert_file_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run cat "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"
	assert_success
	assert_equal "${#lines[@]}" "5"
	assert_line --index 0 "gaudi-bash enable alias gaudi-bash"
	assert_line --index 1 "gaudi-bash enable alias general"
	assert_line --index 2 "gaudi-bash enable plugin base"
	assert_line --index 3 "gaudi-bash enable completion system"
	assert_line --index 4 "gaudi-bash enable completion gaudi-bash"
}

@test "gaudi-bash startup: optional command guards should be silent when tools are missing" {
	local bash_path

	bash_path="$(command -v bash)"

	ln -s "$GAUDI_BASH/components/aliases/lib/git.aliases.bash" "$GAUDI_BASH/components/enabled/150___git.aliases.bash"
	ln -s "$GAUDI_BASH/components/aliases/lib/fuck.aliases.bash" "$GAUDI_BASH/components/enabled/150___fuck.aliases.bash"
	ln -s "$GAUDI_BASH/components/plugins/lib/fzf.plugins.bash" "$GAUDI_BASH/components/enabled/250___fzf.plugins.bash"
	ln -s "$GAUDI_BASH/components/plugins/lib/thefuck.plugins.bash" "$GAUDI_BASH/components/enabled/250___thefuck.plugins.bash"
	ln -s "$GAUDI_BASH/components/completions/lib/github-cli.completions.bash" "$GAUDI_BASH/components/enabled/350___github-cli.completions.bash"

	run env \
		HOME="$HOME" \
		PATH="/usr/bin:/bin" \
		GAUDI_BASH="$GAUDI_BASH" \
		GAUDI_BASH_LOG_LEVEL=0 \
		"$bash_path" -c "source \"$GAUDI_BASH/gaudi_bash.sh\""

	assert_success
	refute_output --partial "command gh does not exist!"
	refute_output --partial "command fd does not exist!"
	refute_output --partial "command fuck does not exist!"
	refute_output --partial "command thefuck does not exist!"
}

@test "gaudi-bash core: _gaudi-bash-backup should successfully backup enabled components" {

	cd "$GAUDI_BASH"
	./setup.sh --silent

	assert_sane_defaults

	assert_file_not_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run _gaudi-bash-backup

	assert_default_backup_file
}

@test "gaudi-bash core: _gaudi-bash-backup should overwrite old backed up components" {

	cd "$GAUDI_BASH"
	./setup.sh --silent

	assert_sane_defaults

	assert_file_not_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run _gaudi-bash-backup

	assert_default_backup_file

	run gaudi-bash disable completion git
	run _gaudi-bash-backup
	assert_default_backup_file
}

@test "gaudi-bash core: _gaudi-bash-restore should successfully restore backed up components" {

	cd "$GAUDI_BASH"
	./setup.sh --silent

	assert_sane_defaults

	assert_file_not_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

	run _gaudi-bash-backup

	assert_line --index 0 "Backing up alias: gaudi-bash"
	assert_default_backup_file

	run gaudi-bash disable plugins all
	run gaudi-bash disable completion all
	run gaudi-bash disable aliases all

	assert_file_not_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/150___gaudi-bash.aliases.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/365___alias-completion.plugins.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
	assert_file_not_exist "$GAUDI_BASH/components/enabled/325___system.completions.bash"

	run _gaudi-bash-restore

	assert_sane_defaults

}
