#!/usr/bin/env bats

load ../helper

load ../../lib/composure

cite about param example group

load ../../lib/gaudi-bash

local_setup () {
  prepare
}

@test "gaudi-bash core: _gaudi-bash-backup should successfully backup enabled components" {

  cd "$GAUDI_BASH"
  ./setup.sh --silent

  assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/350___git.completions.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/365___alias-completion.plugins.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/350___system.completions.bash"

  assert_file_not_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

  run _gaudi-bash-backup

  assert_file_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"
  local backup_md5=$(md5sum "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup" | awk '{print $1}')
  # This is compare against the md5 hash of the backup file created from a fresh set of enabled plugins after setup
  assert_equal "$backup_md5" "e0ee585f9e1ce1d7b409d5acd7d5fde8"
}

@test "gaudi-bash core: _gaudi-bash-backup should overwrite old backed up components" {

  local backup_md5

  cd "$GAUDI_BASH"
  ./setup.sh --silent

  assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/350___git.completions.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/365___alias-completion.plugins.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/350___system.completions.bash"

  assert_file_not_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

  run _gaudi-bash-backup

  assert_file_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"
  backup_md5=$(md5sum "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup" | awk '{print $1}')
  # This is compare against the md5 hash of the backup file created from a fresh set of enabled plugins after setup
  assert_equal "$backup_md5" "e0ee585f9e1ce1d7b409d5acd7d5fde8"

  run gaudi-bash disable completion git
  run _gaudi-bash-backup
  backup_md5=$(md5sum "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup" | awk '{print $1}')
  # This is compare against the md5 hash of the backup file created from a fresh set of enabled plugins after setup
  assert_equal "$backup_md5" "662d4f27c32d1d408a0bccab8b1825ea"
}

@test "gaudi-bash core: _gaudi-bash-restore should successfully restore backed up components" {

  local backup_md5

  cd "$GAUDI_BASH"
  ./setup.sh --silent

  assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/350___git.completions.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/365___alias-completion.plugins.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/350___system.completions.bash"

  assert_file_not_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"

  run _gaudi-bash-backup

  assert_line --index 0 "Backing up alias: general"
  assert_file_exist "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup"
  backup_md5=$(md5sum "$GAUDI_BASH/tmp/enabled.gaudi-bash.backup" | awk '{print $1}')
  # This is compare against the md5 hash of the backup file created from a fresh set of enabled plugins after setup
  assert_equal "$backup_md5" "e0ee585f9e1ce1d7b409d5acd7d5fde8"

  run gaudi-bash disable plugins all
  run gaudi-bash disable completion all
  run gaudi-bash disable aliases all

  assert_file_not_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
  assert_file_not_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
  assert_file_not_exist "$GAUDI_BASH/components/enabled/350___git.completions.bash"
  assert_file_not_exist "$GAUDI_BASH/components/enabled/365___alias-completion.plugins.bash"
  assert_file_not_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
  assert_file_not_exist "$GAUDI_BASH/components/enabled/350___system.completions.bash"

  run _gaudi-bash-restore

  assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/350___git.completions.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/365___alias-completion.plugins.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/350___system.completions.bash"

}
