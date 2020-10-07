#!/usr/bin/env bash

if [[ -z "$BASH_IT" ]];
then
  BASH_IT="$HOME/.bash_it"
fi

__install () {
  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  env git clone --depth=1 --recurse-submodules https://github.com/ahmadassaf/bash-it.git "$BASH_IT" || {
      printf "Error: Cloning of gaudi into this machine failed :(\\n"
      exit 1
  }

  bash "$BASH_IT/setup.sh"
}

if [[ -d "$BASH_IT" ]]; then
    echo "You already have bash-it installed.."
    unset REPLY
    while ! [[ $REPLY =~ ^[yY]$ ]] && ! [[ $REPLY =~ ^[nN]$ ]]; do
        read -rp "Do you want to set up a fresh installation of bash-it? " -n 1 </dev/tty;
        [[ -n $REPLY ]] && echo ""
    done
    if [[ $REPLY =~ ^[yY]$ ]]; then
        rm -rf "$BASH_IT"
    else
        echo "Running a bash-it update to pull latest changes ..."
        git -C "$BASH_IT" pull
    fi
    __install
else
  __install
fi
