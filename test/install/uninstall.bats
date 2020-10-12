#!/usr/bin/env bats

load ../helper

local_setup () {
  prepare
}

@test "bash-it uninstall: verify that the uninstall script exists" {

  assert_file_exist "$BASH_IT/uninstall.sh"
}

@test "bash-it uninstall: run the uninstall script with an existing backup file" {

  cd "$BASH_IT"

  echo "test file content for backup" > "$HOME/$CONFIG_FILE.bak"
  echo "test file content for original file" > "$HOME/$CONFIG_FILE"
  local md5_bak=$(md5sum "$HOME/$CONFIG_FILE.bak" | awk '{print $1}')

  ./uninstall.sh

  assert_file_not_exist "$HOME/$CONFIG_FILE.uninstall"
  assert_file_not_exist "$HOME/$CONFIG_FILE.bak"
  assert_file_exist "$HOME/$CONFIG_FILE"

  local md5_conf=$(md5sum "$HOME/$CONFIG_FILE" | awk '{print $1}')

  assert_equal "$md5_bak" "$md5_conf"
}

@test "bash-it uninstall: run the uninstall script without an existing backup file" {

  cd "$BASH_IT"

  echo "test file content for original file" > "$HOME/$CONFIG_FILE"
  local md5_orig=$(md5sum "$HOME/$CONFIG_FILE" | awk '{print $1}')

  ./uninstall.sh

  assert_file_exist "$HOME/$CONFIG_FILE.uninstall"
  assert_file_not_exist "$HOME/$CONFIG_FILE.bak"
  assert_file_not_exist "$HOME/$CONFIG_FILE"

  local md5_uninstall=$(md5sum "$HOME/$CONFIG_FILE.uninstall" | awk '{print $1}')

  assert_equal "$md5_orig" "$md5_uninstall"
}
