#!/usr/bin/env bats

load ../helper
load ../../lib/composure

case $OSTYPE in
  darwin*)
    export BASH_IT_CONFIG_FILE=".bash_profile"
    ;;
  *)
    export BASH_IT_CONFIG_FILE=".bashrc"
    ;;
esac

local_setup () {
  prepare
}

@test "bash-it install: verify that the install script exists" {

  assert_file_exist "$BASH_IT/install.sh"
}

@test "bash-it install: verify that the setup script exists" {

  assert_file_exist "$BASH_IT/setup.sh"
}

@test "bash-it install: run the install script silently by skipping prompts" {

  ./setup.sh --silent
  [[ -z $output ]]
}

@test "bash-it install: run the install script silently and check that config file exists" {

  cd "$BASH_IT"

  ./setup.sh --silent
  assert_file_exist "$HOME/$BASH_IT_CONFIG_FILE"
}

@test "bash-it install: run the install script silently and enable sane defaults" {

  cd "$BASH_IT"

  ./setup.sh --silent

  assert_file_exist "$BASH_IT/components/enabled/150___general.aliases.bash"
  assert_file_exist "$BASH_IT/components/enabled/250___base.plugins.bash"
  assert_file_exist "$BASH_IT/components/enabled/365___alias-completion.plugins.bash"
  assert_file_exist "$BASH_IT/components/enabled/350___bash-it.completions.bash"
  assert_file_exist "$BASH_IT/components/enabled/350___system.completions.bash"
}

@test "bash-it install: run the install script silently and don't modify configs" {
  rm -rf "$HOME/$BASH_IT_CONFIG_FILE"

  cd "$BASH_IT"
  ./setup.sh --silent --no_modify_config

  assert_file_not_exist "$HOME/$BASH_IT_CONFIG_FILE"
}

@test "bash-it install: verify that a backup file is created" {

  cd "$BASH_IT"

  touch "$HOME/$BASH_IT_CONFIG_FILE"
  echo "test file content" > "$HOME/$BASH_IT_CONFIG_FILE"
  local md5_orig=$(md5sum "$HOME/$BASH_IT_CONFIG_FILE" | awk '{print $1}')

  ./setup.sh --silent

  assert_file_exist "$HOME/$BASH_IT_CONFIG_FILE"
  assert_file_exist "$HOME/$BASH_IT_CONFIG_FILE.bak"

  local md5_bak=$(md5sum "$HOME/$BASH_IT_CONFIG_FILE.bak" | awk '{print $1}')

  assert_equal "$md5_orig" "$md5_bak"
}
