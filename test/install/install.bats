#!/usr/bin/env bats

load ../helper

load ../../lib/composure

cite about param example group priority

case $OSTYPE in
  darwin*)
    export GAUDI_BASH_CONFIG_FILE=".bash_profile"
    ;;
  *)
    export GAUDI_BASH_CONFIG_FILE=".bashrc"
    ;;
esac

local_setup () {
  prepare
}

@test "gaudi-bash install: verify that the install script exists" {

  assert_file_exist "$GAUDI_BASH/install.sh"
}

@test "gaudi-bash install: verify that the setup script exists" {

  assert_file_exist "$GAUDI_BASH/setup.sh"
}

@test "gaudi-bash install: run the install script silently by skipping prompts" {

  ./setup.sh --silent
  [[ -z $output ]]
}

@test "gaudi-bash install: run the install script silently and check that config file exists" {

  cd "$GAUDI_BASH"

  ./setup.sh --silent
  assert_file_exist "$HOME/$GAUDI_BASH_CONFIG_FILE"
}

@test "gaudi-bash install: run the install script silently and enable sane defaults" {

  cd "$GAUDI_BASH"

  ./setup.sh --silent

  assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/365___alias-completion.plugins.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
  assert_file_exist "$GAUDI_BASH/components/enabled/350___system.completions.bash"
}

@test "gaudi-bash install: run the install script silently and don't modify configs" {
  rm -rf "$HOME/$GAUDI_BASH_CONFIG_FILE"

  cd "$GAUDI_BASH"
  ./setup.sh --silent --no_modify_config

  assert_file_not_exist "$HOME/$GAUDI_BASH_CONFIG_FILE"
}

@test "gaudi-bash install: verify that a backup file is created" {

  cd "$GAUDI_BASH"

  touch "$HOME/$GAUDI_BASH_CONFIG_FILE"
  echo "test file content" > "$HOME/$GAUDI_BASH_CONFIG_FILE"
  local md5_orig=$(md5sum "$HOME/$GAUDI_BASH_CONFIG_FILE" | awk '{print $1}')

  ./setup.sh --silent

  assert_file_exist "$HOME/$GAUDI_BASH_CONFIG_FILE"
  assert_file_exist "$HOME/$GAUDI_BASH_CONFIG_FILE.bak"

  local md5_bak=$(md5sum "$HOME/$GAUDI_BASH_CONFIG_FILE.bak" | awk '{print $1}')

  assert_equal "$md5_orig" "$md5_bak"
}
