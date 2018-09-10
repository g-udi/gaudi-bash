main() {

  if [ ! -n "$BASH_IT" ]; then
    BASH_IT=~/.BASH_IT
  fi

  if [ -d "$BASH_IT" ]; then
    printf "You already have Oh My Zsh installed\n"
    printf "You'll need to remove $BASH_IT if you want to re-install.\n"
    exit
  fi

  # Prevent the cloned repository from having insecure permissions. Failing to do
  # so causes compinit() calls to fail with "command not found: compdef" errors
  # for users with insecure umasks (e.g., "002", allowing group writability). Note
  # that this will be ignored under Cygwin by default, as Windows ACLs take
  # precedence over umasks except for filesystems mounted with option "noacl".
  umask g-w,o-w

  printf "Cloning Bash-it...\n"
  command -v git >/dev/null 2>&1 || {
    echo "Error: git is not installed"
    exit 1
  }
  # The Windows (MSYS) Git is not compatible with normal use on cygwin
  if [ "$OSTYPE" = cygwin ]; then
    if git --version | grep msysgit > /dev/null; then
      echo "Error: Windows/MSYS Git is not supported on Cygwin"
      echo "Error: Make sure the Cygwin git package is installed and is first on the path"
      exit 1
    fi
  fi
  env git clone --depth=1 https://github.com/ahmadassaf/bash-it.git "$BASH_IT" || {
    printf "Error: git clone of bash-it repo failed\n"
    exit 1
  }

  . "$BASH_IT/install.sh"
}

main
