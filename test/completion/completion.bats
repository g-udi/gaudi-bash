# !/usr/bin/env bats
# shellcheck shell=bats

load ../helper
load ../../lib/composure
load ../../components/completions/lib/gaudi-bash.completions

local_setup () {
  prepare
}

@test "gaudi-bash completion: ensure that the _gaudi-bash-comp function is available" {
  run type -a _gaudi-bash-comp &> /dev/null
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

  # Run the gaudi-bash completion function
  _gaudi-bash-comp

  # Return the completion output
  echo "${COMPREPLY[@]}"
}

@test "gaudi-bash completion: doctor - show options" {

  run __check_completion 'gaudi-bash doctor '
  assert_line --index 0 "errors warnings all"
}

@test "gaudi-bash completion: help - show options" {

  run __check_completion 'gaudi-bash help '
  assert_line --index 0 "aliases completions migrate plugins update"
}

@test "gaudi-bash completion: update - show no options" {

  run __check_completion 'gaudi-bash update '
  refute_output
}

@test "gaudi-bash completion: show options" {

  run __check_completion 'gaudi-bash '
  assert_line --index 0 "version help doctor reload restart search update backup restore disable enable show"
}

@test "gaudi-bash completion: gudi-bash - show options" {

  run __check_completion 'gudi-bash '
  assert_line --index 0 "version help doctor reload restart search update backup restore disable enable show"
}

@test "gaudi-bash completion: g-udi-bash - show options" {

  run __check_completion 'g-udi-bash '
  assert_line --index 0 "version help doctor reload restart search update backup restore disable enable show"
}

@test "gaudi-bash completion: gadi-bash - show options" {

  run __check_completion 'gadi-bash '
  assert_line --index 0 "version help doctor reload restart search update backup restore disable enable show"
}

@test "gaudi-bash completion: guadi-bash - show options" {
  run __check_completion 'guadi-bash '
  assert_line --index 0 "version help doctor reload restart search update backup restore disable enable show"
}

@test "gaudi-bash completion: show - show options" {

  run __check_completion 'gaudi-bash show '
  assert_line --index 0 "aliases completions plugins"
}

@test "gaudi-bash completion: disable - show options" {

  run __check_completion 'gaudi-bash disable '
  assert_line --index 0 "alias completion plugin"
}

@test "gaudi-bash completion: disable - show options a" {

  run __check_completion 'gaudi-bash disable a'
  assert_line --index 0 "alias"
}

@test "gaudi-bash completion: disable - provide nothing when atom is not enabled" {

  run __check_completion 'gaudi-bash disable alias ato'
  refute_output
}

@test "gaudi-bash completion: disable - provide all when atom is not enabled" {
  run __check_completion 'gaudi-bash disable alias a'
  assert_line --index 0 "all"
}

# @test "gaudi-bash completion: disable - provide the a* aliases when atom is enabled with the old location and name" {

#   run gaudi-bash enable alias atom
#   assert_link_exist $GAUDI_BASH/components/enabled/150___atom.aliases.bash

#   run __check_completion 'gaudi-bash disable alias a'
#   assert_line --index 0 "all atom"
# }

# @test "gaudi-bash completion: disable - provide the a* aliases when atom is enabled with the old location and priority-based name" {
#   ln -s $GAUDI_BASH/aliases/available/atom.aliases.bash $GAUDI_BASH/aliases/enabled/150---atom.aliases.bash
#   assert_link_exist "$GAUDI_BASH/aliases/enabled/150---atom.aliases.bash"

#   ln -s $GAUDI_BASH/completion/available/apm.completion.bash $GAUDI_BASH/completion/enabled/350---apm.completion.bash
#   assert_link_exist "$GAUDI_BASH/completion/enabled/350---apm.completion.bash"

#   run __check_completion 'gaudi-bash disable alias a'
#   assert_line --index 0 "all atom"
# }

# @test "gaudi-bash completion: disable - provide the a* aliases when atom is enabled with the new location and priority-based name" {
#   ln -s $GAUDI_BASH/aliases/available/atom.aliases.bash $GAUDI_BASH/enabled/150---atom.aliases.bash
#   assert_link_exist "$GAUDI_BASH/enabled/150---atom.aliases.bash"

#   ln -s $GAUDI_BASH/completion/available/apm.completion.bash $GAUDI_BASH/enabled/350---apm.completion.bash
#   assert_link_exist "$GAUDI_BASH/enabled/350---apm.completion.bash"

#   run __check_completion 'gaudi-bash disable alias a'
#   assert_line --index 0 "all atom"
# }

# @test "gaudi-bash completion: disable - provide the docker-machine plugin when docker-machine is enabled with the old location and name" {
#   ln -s $GAUDI_BASH/aliases/available/docker-compose.aliases.bash $GAUDI_BASH/aliases/enabled/docker-compose.aliases.bash
#   assert_link_exist "$GAUDI_BASH/aliases/enabled/docker-compose.aliases.bash"

#   ln -s $GAUDI_BASH/plugins/available/docker-machine.plugin.bash $GAUDI_BASH/plugins/enabled/docker-machine.plugin.bash
#   assert_link_exist "$GAUDI_BASH/plugins/enabled/docker-machine.plugin.bash"

#   run __check_completion 'gaudi-bash disable plugin docker'
#   assert_line --index 0 "docker-machine"
# }

# @test "gaudi-bash completion: disable - provide the docker-machine plugin when docker-machine is enabled with the old location and priority-based name" {
#   ln -s $GAUDI_BASH/aliases/available/docker-compose.aliases.bash $GAUDI_BASH/aliases/enabled/150---docker-compose.aliases.bash
#   assert_link_exist "$GAUDI_BASH/aliases/enabled/150---docker-compose.aliases.bash"

#   ln -s $GAUDI_BASH/plugins/available/docker-machine.plugin.bash $GAUDI_BASH/plugins/enabled/350---docker-machine.plugin.bash
#   assert_link_exist "$GAUDI_BASH/plugins/enabled/350---docker-machine.plugin.bash"

#   run __check_completion 'gaudi-bash disable plugin docker'
#   assert_line --index 0 "docker-machine"
# }

# @test "gaudi-bash completion: disable - provide the docker-machine plugin when docker-machine is enabled with the new location and priority-based name" {
#   ln -s $GAUDI_BASH/aliases/available/docker-compose.aliases.bash $GAUDI_BASH/enabled/150---docker-compose.aliases.bash
#   assert_link_exist "$GAUDI_BASH/enabled/150---docker-compose.aliases.bash"

#   ln -s $GAUDI_BASH/plugins/available/docker-machine.plugin.bash $GAUDI_BASH/enabled/350---docker-machine.plugin.bash
#   assert_link_exist "$GAUDI_BASH/enabled/350---docker-machine.plugin.bash"

#   run __check_completion 'gaudi-bash disable plugin docker'
#   assert_line --index 0 "docker-machine"
# }

# @test "gaudi-bash completion: disable - provide the todo.txt-cli aliases when todo plugin is enabled with the old location and name" {
#   ln -s $GAUDI_BASH/aliases/available/todo.txt-cli.aliases.bash $GAUDI_BASH/aliases/enabled/todo.txt-cli.aliases.bash
#   assert_link_exist "$GAUDI_BASH/aliases/enabled/todo.txt-cli.aliases.bash"

#   ln -s $GAUDI_BASH/plugins/available/todo.plugin.bash $GAUDI_BASH/plugins/enabled/todo.plugin.bash
#   assert_link_exist "$GAUDI_BASH/plugins/enabled/todo.plugin.bash"

#   run __check_completion 'gaudi-bash disable alias to'
#   assert_line --index 0 "todo.txt-cli"
# }

# @test "gaudi-bash completion: disable - provide the todo.txt-cli aliases when todo plugin is enabled with the old location and priority-based name" {
#   ln -s $GAUDI_BASH/aliases/available/todo.txt-cli.aliases.bash $GAUDI_BASH/aliases/enabled/150---todo.txt-cli.aliases.bash
#   assert_link_exist "$GAUDI_BASH/aliases/enabled/150---todo.txt-cli.aliases.bash"

#   ln -s $GAUDI_BASH/plugins/available/todo.plugin.bash $GAUDI_BASH/plugins/enabled/350---todo.plugin.bash
#   assert_link_exist "$GAUDI_BASH/plugins/enabled/350---todo.plugin.bash"

#   run __check_completion 'gaudi-bash disable alias to'
#   assert_line --index 0 "todo.txt-cli"
# }

# @test "gaudi-bash completion: disable - provide the todo.txt-cli aliases when todo plugin is enabled with the new location and priority-based name" {
#   ln -s $GAUDI_BASH/aliases/available/todo.txt-cli.aliases.bash $GAUDI_BASH/enabled/150---todo.txt-cli.aliases.bash
#   assert_link_exist "$GAUDI_BASH/enabled/150---todo.txt-cli.aliases.bash"

#   ln -s $GAUDI_BASH/plugins/available/todo.plugin.bash $GAUDI_BASH/enabled/350---todo.plugin.bash
#   assert_link_exist "$GAUDI_BASH/enabled/350---todo.plugin.bash"

#   run __check_completion 'gaudi-bash disable alias to'
#   assert_line --index 0 "todo.txt-cli"
# }

# @test "gaudi-bash completion: enable - show options" {
#   run __check_completion 'gaudi-bash enable '
#   assert_line --index 0 "alias completion plugin"
# }

# @test "gaudi-bash completion: enable - show options a" {
#   run __check_completion 'gaudi-bash enable a'
#   assert_line --index 0 "alias"
# }

# @test "gaudi-bash completion: enable - provide the atom aliases when not enabled" {
#   run __check_completion 'gaudi-bash enable alias ato'
#   assert_line --index 0 "atom"
# }

# @test "gaudi-bash completion: enable - provide the a* aliases when not enabled" {
#   run __check_completion 'gaudi-bash enable alias a'
#   assert_line --index 0 "all ag ansible applications apt atom"
# }

# @test "gaudi-bash completion: enable - provide the a* aliases when atom is enabled with the old location and name" {
#   ln -s $GAUDI_BASH/aliases/available/atom.aliases.bash $GAUDI_BASH/aliases/enabled/atom.aliases.bash
#   assert_link_exist "$GAUDI_BASH/aliases/enabled/atom.aliases.bash"

#   run __check_completion 'gaudi-bash enable alias a'
#   assert_line --index 0 "all ag ansible applications apt"
# }

# @test "gaudi-bash completion: enable - provide the a* aliases when atom is enabled with the old location and priority-based name" {
#   ln -s $GAUDI_BASH/aliases/available/atom.aliases.bash $GAUDI_BASH/aliases/enabled/150---atom.aliases.bash
#   assert_link_exist "$GAUDI_BASH/aliases/enabled/150---atom.aliases.bash"

#   run __check_completion 'gaudi-bash enable alias a'
#   assert_line --index 0 "all ag ansible applications apt"
# }

# @test "gaudi-bash completion: enable - provide the a* aliases when atom is enabled with the new location and priority-based name" {
#   ln -s $GAUDI_BASH/aliases/available/atom.aliases.bash $GAUDI_BASH/enabled/150---atom.aliases.bash
#   assert_link_exist "$GAUDI_BASH/enabled/150---atom.aliases.bash"

#   run __check_completion 'gaudi-bash enable alias a'
#   assert_line --index 0 "all ag ansible applications apt"
# }

# @test "gaudi-bash completion: enable - provide the docker-* plugins when nothing is enabled with the old location and name" {
#   ln -s $GAUDI_BASH/aliases/available/docker-compose.aliases.bash $GAUDI_BASH/aliases/enabled/docker-compose.aliases.bash
#   assert_link_exist "$GAUDI_BASH/aliases/enabled/docker-compose.aliases.bash"

#   run __check_completion 'gaudi-bash enable plugin docker'
#   assert_line --index 0 "docker-compose docker-machine docker"
# }

# @test "gaudi-bash completion: enable - provide the docker-* plugins when nothing is enabled with the old location and priority-based name" {
#   ln -s $GAUDI_BASH/aliases/available/docker-compose.aliases.bash $GAUDI_BASH/aliases/enabled/150---docker-compose.aliases.bash
#   assert_link_exist "$GAUDI_BASH/aliases/enabled/150---docker-compose.aliases.bash"

#   run __check_completion 'gaudi-bash enable plugin docker'
#   assert_line --index 0 "docker-compose docker-machine docker"
# }

# @test "gaudi-bash completion: enable - provide the docker-* plugins when nothing is enabled with the new location and priority-based name" {
#   ln -s $GAUDI_BASH/aliases/available/docker-compose.aliases.bash $GAUDI_BASH/enabled/150---docker-compose.aliases.bash
#   assert_link_exist "$GAUDI_BASH/enabled/150---docker-compose.aliases.bash"

#   run __check_completion 'gaudi-bash enable plugin docker'
#   assert_line --index 0 "docker-compose docker-machine docker"
# }

# @test "gaudi-bash completion: enable - provide the docker-* completions when nothing is enabled with the old location and name" {
#   ln -s $GAUDI_BASH/aliases/available/docker-compose.aliases.bash $GAUDI_BASH/aliases/enabled/docker-compose.aliases.bash
#   assert_link_exist "$GAUDI_BASH/aliases/enabled/docker-compose.aliases.bash"

#   run __check_completion 'gaudi-bash enable completion docker'
#   assert_line --index 0 "docker docker-compose docker-machine"
# }

# @test "gaudi-bash completion: enable - provide the docker-* completions when nothing is enabled with the old location and priority-based name" {
#   ln -s $GAUDI_BASH/aliases/available/docker-compose.aliases.bash $GAUDI_BASH/aliases/enabled/150---docker-compose.aliases.bash
#   assert_link_exist "$GAUDI_BASH/aliases/enabled/150---docker-compose.aliases.bash"

#   run __check_completion 'gaudi-bash enable completion docker'
#   assert_line --index 0 "docker docker-compose docker-machine"
# }

# @test "gaudi-bash completion: enable - provide the docker-* completions when nothing is enabled with the new location and priority-based name" {
#   ln -s $GAUDI_BASH/aliases/available/docker-compose.aliases.bash $GAUDI_BASH/enabled/150---docker-compose.aliases.bash
#   assert_link_exist "$GAUDI_BASH/enabled/150---docker-compose.aliases.bash"

#   run __check_completion 'gaudi-bash enable completion docker'
#   assert_line --index 0 "docker docker-compose docker-machine"
# }

# @test "gaudi-bash completion: enable - provide the todo.txt-cli aliases when todo plugin is enabled with the old location and name" {
#   ln -s $GAUDI_BASH/plugins/available/todo.plugin.bash $GAUDI_BASH/plugins/enabled/todo.plugin.bash
#   assert_link_exist "$GAUDI_BASH/plugins/enabled/todo.plugin.bash"

#   run __check_completion 'gaudi-bash enable alias to'
#   assert_line --index 0 "todo.txt-cli"
# }

# @test "gaudi-bash completion: enable - provide the todo.txt-cli aliases when todo plugin is enabled with the old location and priority-based name" {
#   ln -s $GAUDI_BASH/plugins/available/todo.plugin.bash $GAUDI_BASH/plugins/enabled/350---todo.plugin.bash
#   assert_link_exist "$GAUDI_BASH/plugins/enabled/350---todo.plugin.bash"

#   run __check_completion 'gaudi-bash enable alias to'
#   assert_line --index 0 "todo.txt-cli"
# }

# @test "gaudi-bash completion: enable - provide the todo.txt-cli aliases when todo plugin is enabled with the new location and priority-based name" {
#   ln -s $GAUDI_BASH/plugins/available/todo.plugin.bash $GAUDI_BASH/enabled/350---todo.plugin.bash
#   assert_link_exist "$GAUDI_BASH/enabled/350---todo.plugin.bash"

#   run __check_completion 'gaudi-bash enable alias to'
#   assert_line --index 0 "todo.txt-cli"
# }
