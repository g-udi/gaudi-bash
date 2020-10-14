#!/usr/bin/env bats

load ../helper

load ../../lib/composure

cite about param example group

load ../../lib/bash-it

local_setup () {
  prepare
}

@test "bash-it core: _bash-it-backup should successfully backup enabled components" {

  cd "$BASH_IT"
  ./setup.sh --silent

  assert_file_exist "$BASH_IT/components/enabled/150___general.aliases.bash"
  assert_file_exist "$BASH_IT/components/enabled/250___base.plugins.bash"
  assert_file_exist "$BASH_IT/components/enabled/350___git.completions.bash"
  assert_file_exist "$BASH_IT/components/enabled/365___alias-completion.plugins.bash"
  assert_file_exist "$BASH_IT/components/enabled/350___bash-it.completions.bash"
  assert_file_exist "$BASH_IT/components/enabled/350___system.completions.bash"

  assert_file_not_exist "$BASH_IT/tmp/enabled.bash-it.backup"

  run _bash-it-backup

  assert_file_exist "$BASH_IT/tmp/enabled.bash-it.backup"
  local backup_md5=$(md5sum "$BASH_IT/tmp/enabled.bash-it.backup" | awk '{print $1}')
  # This is compare against the md5 hash of the backup file created from a fresh set of enabled plugins after setup
  assert_equal "$backup_md5" "e0ee585f9e1ce1d7b409d5acd7d5fde8"
}

@test "bash-it core: _bash-it-backup should overwrite old backed up components" {

  local backup_md5

  cd "$BASH_IT"
  ./setup.sh --silent

  assert_file_exist "$BASH_IT/components/enabled/150___general.aliases.bash"
  assert_file_exist "$BASH_IT/components/enabled/250___base.plugins.bash"
  assert_file_exist "$BASH_IT/components/enabled/350___git.completions.bash"
  assert_file_exist "$BASH_IT/components/enabled/365___alias-completion.plugins.bash"
  assert_file_exist "$BASH_IT/components/enabled/350___bash-it.completions.bash"
  assert_file_exist "$BASH_IT/components/enabled/350___system.completions.bash"

  assert_file_not_exist "$BASH_IT/tmp/enabled.bash-it.backup"

  run _bash-it-backup

  assert_file_exist "$BASH_IT/tmp/enabled.bash-it.backup"
  backup_md5=$(md5sum "$BASH_IT/tmp/enabled.bash-it.backup" | awk '{print $1}')
  # This is compare against the md5 hash of the backup file created from a fresh set of enabled plugins after setup
  assert_equal "$backup_md5" "e0ee585f9e1ce1d7b409d5acd7d5fde8"

  run bash-it disable completion git
  run _bash-it-backup
  backup_md5=$(md5sum "$BASH_IT/tmp/enabled.bash-it.backup" | awk '{print $1}')
  # This is compare against the md5 hash of the backup file created from a fresh set of enabled plugins after setup
  assert_equal "$backup_md5" "662d4f27c32d1d408a0bccab8b1825ea"
}

@test "bash-it core: _bash-it-restore should successfully restore backed up components" {

  local backup_md5

  cd "$BASH_IT"
  ./setup.sh --silent

  assert_file_exist "$BASH_IT/components/enabled/150___general.aliases.bash"
  assert_file_exist "$BASH_IT/components/enabled/250___base.plugins.bash"
  assert_file_exist "$BASH_IT/components/enabled/350___git.completions.bash"
  assert_file_exist "$BASH_IT/components/enabled/365___alias-completion.plugins.bash"
  assert_file_exist "$BASH_IT/components/enabled/350___bash-it.completions.bash"
  assert_file_exist "$BASH_IT/components/enabled/350___system.completions.bash"

  assert_file_not_exist "$BASH_IT/tmp/enabled.bash-it.backup"

  run _bash-it-backup

  assert_line --index 0 "Backing up alias: general"
  assert_file_exist "$BASH_IT/tmp/enabled.bash-it.backup"
  backup_md5=$(md5sum "$BASH_IT/tmp/enabled.bash-it.backup" | awk '{print $1}')
  # This is compare against the md5 hash of the backup file created from a fresh set of enabled plugins after setup
  assert_equal "$backup_md5" "e0ee585f9e1ce1d7b409d5acd7d5fde8"

  run bash-it disable plugins all
  run bash-it disable completion all
  run bash-it disable aliases all

  assert_file_not_exist "$BASH_IT/components/enabled/150___general.aliases.bash"
  assert_file_not_exist "$BASH_IT/components/enabled/250___base.plugins.bash"
  assert_file_not_exist "$BASH_IT/components/enabled/350___git.completions.bash"
  assert_file_not_exist "$BASH_IT/components/enabled/365___alias-completion.plugins.bash"
  assert_file_not_exist "$BASH_IT/components/enabled/350___bash-it.completions.bash"
  assert_file_not_exist "$BASH_IT/components/enabled/350___system.completions.bash"

  run _bash-it-restore

  assert_file_exist "$BASH_IT/components/enabled/150___general.aliases.bash"
  assert_file_exist "$BASH_IT/components/enabled/250___base.plugins.bash"
  assert_file_exist "$BASH_IT/components/enabled/350___git.completions.bash"
  assert_file_exist "$BASH_IT/components/enabled/365___alias-completion.plugins.bash"
  assert_file_exist "$BASH_IT/components/enabled/350___bash-it.completions.bash"
  assert_file_exist "$BASH_IT/components/enabled/350___system.completions.bash"

}
