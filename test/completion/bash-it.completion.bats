#!/usr/bin/env bats

load ../helper
load ../../lib/composure
load ../../completion/available/bash-it.completion

local_setup () {
  setup_test_fixture
}

@test "completion" {}

@test "completion: ensure that the _bash-it-comp function is available" {
  run type -a _bash-it-comp &> /dev/null
  assert_success
}

__check_completion () {
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
  if [[  ${COMP_LINE:$COMP_LAST} = ' ' ]]; then
    # ...then add an empty array item
    COMP_WORDS+=('')
  fi

  # Word index of the last word
  COMP_CWORD=$(( ${#COMP_WORDS[@]} - 1 ))

  # Run the bash-it completion function
  _bash-it-comp

  # Return the completion output
  echo "${COMPREPLY[@]}"
}

@test "completion: doctor - show options" {
  run __check_completion 'bash-it doctor '
  assert_line -n 0 "errors warnings all"
}

@test "completion: help - show options" {
  run __check_completion 'bash-it help '
  assert_line -n 0 "aliases completions migrate plugins update"
}

@test "completion: help - aliases v" {
  run __check_completion 'bash-it help aliases v'
  assert_line -n 0 "vagrant vault vim"
}

@test "completion: update - show no options" {
  run __check_completion 'bash-it update '
  assert_line -n 0 ""
}

@test "completion: search - show no options" {
  run __check_completion 'bash-it search '
  assert_line -n 0 ""
}

@test "completion: migrate - show no options" {
  run __check_completion 'bash-it migrate '
  assert_line -n 0 ""
}

@test "completion: show options" {
  run __check_completion 'bash-it '
  assert_line -n 0 "disable enable help migrate reload doctor search show update version"
}

@test "completion: bash-ti - show options" {
  run __check_completion 'bash-ti '
  assert_line -n 0 "disable enable help migrate reload doctor search show update version"
}

@test "completion: shit - show options" {
  run __check_completion 'shit '
  assert_line -n 0 "disable enable help migrate reload doctor search show update version"
}

@test "completion: bashit - show options" {
  run __check_completion 'bashit '
  assert_line -n 0 "disable enable help migrate reload doctor search show update version"
}

@test "completion: batshit - show options" {
  run __check_completion 'batshit '
  assert_line -n 0 "disable enable help migrate reload doctor search show update version"
}

@test "completion: bash_it - show options" {
  run __check_completion 'bash_it '
  assert_line -n 0 "disable enable help migrate reload doctor search show update version"
}

@test "completion: show - show options" {
  run __check_completion 'bash-it show '
  assert_line -n 0 "aliases completions plugins"
}

@test "completion: completion: disable" {}

@test "completion: disable - show options" {
  run __check_completion 'bash-it disable '
  assert_line -n 0 "alias completion plugin"
}

@test "completion: disable - show options a" {
  run __check_completion 'bash-it disable a'
  assert_line -n 0 "alias"
}

@test "completion: disable - provide nothing when atom is not enabled" {
  run __check_completion 'bash-it disable alias ato'
  assert_line -n 0 ""
}

@test "completion: disable - provide all when atom is not enabled" {
  run __check_completion 'bash-it disable alias a'
  assert_line -n 0 "all"
}

@test "completion: disable - provide the a* aliases when atom is enabled with the old location and name" {
  ln -s $BASH_IT/aliases/available/atom.aliases.bash $BASH_IT/aliases/enabled/atom.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/atom.aliases.bash"

  ln -s $BASH_IT/completion/available/apm.completion.bash $BASH_IT/completion/enabled/apm.completion.bash
  assert_link_exist "$BASH_IT/completion/enabled/apm.completion.bash"

  run __check_completion 'bash-it disable alias a'
  assert_line -n 0 "all atom"
}

@test "completion: disable - provide the a* aliases when atom is enabled with the old location and priority-based name" {
  ln -s $BASH_IT/aliases/available/atom.aliases.bash $BASH_IT/aliases/enabled/150---atom.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/150---atom.aliases.bash"

  ln -s $BASH_IT/completion/available/apm.completion.bash $BASH_IT/completion/enabled/350---apm.completion.bash
  assert_link_exist "$BASH_IT/completion/enabled/350---apm.completion.bash"

  run __check_completion 'bash-it disable alias a'
  assert_line -n 0 "all atom"
}

@test "completion: disable - provide the a* aliases when atom is enabled with the new location and priority-based name" {
  ln -s $BASH_IT/aliases/available/atom.aliases.bash $BASH_IT/enabled/150---atom.aliases.bash
  assert_link_exist "$BASH_IT/enabled/150---atom.aliases.bash"

  ln -s $BASH_IT/completion/available/apm.completion.bash $BASH_IT/enabled/350---apm.completion.bash
  assert_link_exist "$BASH_IT/enabled/350---apm.completion.bash"

  run __check_completion 'bash-it disable alias a'
  assert_line -n 0 "all atom"
}

@test "completion: disable - provide the docker-machine plugin when docker-machine is enabled with the old location and name" {
  ln -s $BASH_IT/aliases/available/docker-compose.aliases.bash $BASH_IT/aliases/enabled/docker-compose.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/docker-compose.aliases.bash"

  ln -s $BASH_IT/plugins/available/docker-machine.plugin.bash $BASH_IT/plugins/enabled/docker-machine.plugin.bash
  assert_link_exist "$BASH_IT/plugins/enabled/docker-machine.plugin.bash"

  run __check_completion 'bash-it disable plugin docker'
  assert_line -n 0 "docker-machine"
}

@test "completion: disable - provide the docker-machine plugin when docker-machine is enabled with the old location and priority-based name" {
  ln -s $BASH_IT/aliases/available/docker-compose.aliases.bash $BASH_IT/aliases/enabled/150---docker-compose.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/150---docker-compose.aliases.bash"

  ln -s $BASH_IT/plugins/available/docker-machine.plugin.bash $BASH_IT/plugins/enabled/350---docker-machine.plugin.bash
  assert_link_exist "$BASH_IT/plugins/enabled/350---docker-machine.plugin.bash"

  run __check_completion 'bash-it disable plugin docker'
  assert_line -n 0 "docker-machine"
}

@test "completion: disable - provide the docker-machine plugin when docker-machine is enabled with the new location and priority-based name" {
  ln -s $BASH_IT/aliases/available/docker-compose.aliases.bash $BASH_IT/enabled/150---docker-compose.aliases.bash
  assert_link_exist "$BASH_IT/enabled/150---docker-compose.aliases.bash"

  ln -s $BASH_IT/plugins/available/docker-machine.plugin.bash $BASH_IT/enabled/350---docker-machine.plugin.bash
  assert_link_exist "$BASH_IT/enabled/350---docker-machine.plugin.bash"

  run __check_completion 'bash-it disable plugin docker'
  assert_line -n 0 "docker-machine"
}

@test "completion: completion: enable" {}

@test "completion: enable - show options" {
  run __check_completion 'bash-it enable '
  assert_line -n 0 "alias completion plugin"
}

@test "completion: enable - show options a" {
  run __check_completion 'bash-it enable a'
  assert_line -n 0 "alias"
}

@test "completion: enable - provide the atom aliases when not enabled" {
  run __check_completion 'bash-it enable alias ato'
  assert_line -n 0 "atom"
}

@test "completion: enable - provide the a* aliases when not enabled" {
  run __check_completion 'bash-it enable alias a'
  assert_line -n 0 "all ag ansible applications apt atom"
}

@test "completion: enable - provide the a* aliases when atom is enabled with the old location and name" {
  ln -s $BASH_IT/aliases/available/atom.aliases.bash $BASH_IT/aliases/enabled/atom.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/atom.aliases.bash"

  run __check_completion 'bash-it enable alias a'
  assert_line -n 0 "all ag ansible applications apt"
}

@test "completion: enable - provide the a* aliases when atom is enabled with the old location and priority-based name" {
  ln -s $BASH_IT/aliases/available/atom.aliases.bash $BASH_IT/aliases/enabled/150---atom.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/150---atom.aliases.bash"

  run __check_completion 'bash-it enable alias a'
  assert_line -n 0 "all ag ansible applications apt"
}

@test "completion: enable - provide the a* aliases when atom is enabled with the new location and priority-based name" {
  ln -s $BASH_IT/aliases/available/atom.aliases.bash $BASH_IT/enabled/150---atom.aliases.bash
  assert_link_exist "$BASH_IT/enabled/150---atom.aliases.bash"

  run __check_completion 'bash-it enable alias a'
  assert_line -n 0 "all ag ansible applications apt"
}

@test "completion: enable - provide the docker-* plugins when nothing is enabled with the old location and name" {
  ln -s $BASH_IT/aliases/available/docker-compose.aliases.bash $BASH_IT/aliases/enabled/docker-compose.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/docker-compose.aliases.bash"

  run __check_completion 'bash-it enable plugin docker'
  assert_line -n 0 "docker-compose docker-machine docker"
}

@test "completion: enable - provide the docker-* plugins when nothing is enabled with the old location and priority-based name" {
  ln -s $BASH_IT/aliases/available/docker-compose.aliases.bash $BASH_IT/aliases/enabled/150---docker-compose.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/150---docker-compose.aliases.bash"

  run __check_completion 'bash-it enable plugin docker'
  assert_line -n 0 "docker-compose docker-machine docker"
}

@test "completion: enable - provide the docker-* plugins when nothing is enabled with the new location and priority-based name" {
  ln -s $BASH_IT/aliases/available/docker-compose.aliases.bash $BASH_IT/enabled/150---docker-compose.aliases.bash
  assert_link_exist "$BASH_IT/enabled/150---docker-compose.aliases.bash"

  run __check_completion 'bash-it enable plugin docker'
  assert_line -n 0 "docker-compose docker-machine docker"
}

@test "completion: enable - provide the docker-* completions when nothing is enabled with the old location and name" {
  ln -s $BASH_IT/aliases/available/docker-compose.aliases.bash $BASH_IT/aliases/enabled/docker-compose.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/docker-compose.aliases.bash"

  run __check_completion 'bash-it enable completion docker'
  assert_line -n 0 "docker docker-compose docker-machine"
}

@test "completion: enable - provide the docker-* completions when nothing is enabled with the old location and priority-based name" {
  ln -s $BASH_IT/aliases/available/docker-compose.aliases.bash $BASH_IT/aliases/enabled/150---docker-compose.aliases.bash
  assert_link_exist "$BASH_IT/aliases/enabled/150---docker-compose.aliases.bash"

  run __check_completion 'bash-it enable completion docker'
  assert_line -n 0 "docker docker-compose docker-machine"
}

@test "completion: enable - provide the docker-* completions when nothing is enabled with the new location and priority-based name" {
  ln -s $BASH_IT/aliases/available/docker-compose.aliases.bash $BASH_IT/enabled/150---docker-compose.aliases.bash
  assert_link_exist "$BASH_IT/enabled/150---docker-compose.aliases.bash"

  run __check_completion 'bash-it enable completion docker'
  assert_line -n 0 "docker docker-compose docker-machine"
}
