#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034

source "./lib/colors.bash"
source "./lib/helpers/generic.bash"

echo -e "\n[INFO] ${YELLOW}Getting bash version .... ${NC}\n"
bash --version

echo -e "
██████╗  █████╗ ███████╗██╗  ██╗      ██╗████████╗
██╔══██╗██╔══██╗██╔════╝██║  ██║      ██║╚══██╔══╝
██████╔╝███████║███████╗███████║█████╗██║   ██║
██╔══██╗██╔══██║╚════██║██╔══██║╚════╝██║   ██║
██████╔╝██║  ██║███████║██║  ██║      ██║   ██║
╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝      ╚═╝   ╚═╝

${CYAN}Installing bash-it ..${NC}"

# Show how to use this installer
show_usage () {
  echo -e "\n$0 : Install bash-it"
  echo -e "Usage:\n$0 [arguments] \n"
  echo "Arguments:"
  echo "--help (-h): Display this help message"
  echo "--silent (-s): Install default settings without prompting for input";
  echo "--no-modify-config (-n): Do not modify existing config file"
  exit 0;
}

for param in "$@"; do
  shift
  case "$param" in
    "--help")               set -- "$@" "-h" ;;
    "--silent")             set -- "$@" "-s" ;;
    "--no-modify-config")   set -- "$@" "-n" ;;
    *)                      set -- "$@" "$param"
  esac
done

OPTIND=1
while getopts "hsn" opt
do
  case "$opt" in
  "h") show_usage; exit 0 ;;
  "s") silent=true ;;
  "n") no_modify_config=true ;;
  "?") show_usage >&2; exit 1 ;;
  esac
done
shift "$(expr $OPTIND - 1)"


BASH_IT="$(cd "$(dirname "$0")" && pwd)"

case $OSTYPE in
  darwin*)
    CONFIG_FILE=.bash_profile
    ;;
  *)
    CONFIG_FILE=.bashrc
    ;;
esac

if ! [[ $no_modify_config ]]; then

  printf "${RED}%s${NC}\n" "We need to make sure to backup your $CONFIG_FILE before running this installation"

  if [[ -e "$HOME/$CONFIG_FILE.bak" ]] && ! [[ $silent ]]; then
    printf "${GREEN}%s${NC}\n" "Backup file already exists!"
    _read_input "Would you like to overwrite the existing backup? This will delete your existing backup file ($HOME/$CONFIG_FILE.bak) [Yy/Nn]"
    [[ $REPLY =~ ^[yY]$ ]] && cp -aL "$HOME/$CONFIG_FILE" "$HOME/$CONFIG_FILE.bak"
  else
    cp -aL "$HOME/$CONFIG_FILE" "$HOME/$CONFIG_FILE.bak"
    printf "${GREEN}%s${NC}\n" "Your original $CONFIG_FILE has been backed up to $CONFIG_FILE.bak"
  fi

  ! [[ $silent ]] && _read_input "Would you like to keep your $CONFIG_FILE and append bash-it templates at the end? [Yy/Nn]"

  if [[ $REPLY =~ ^[yY]$ ]]; then
    (sed "s|{{BASH_IT}}|$BASH_IT|" "$BASH_IT/template/bash_profile.template.bash" | tail -n +2) >> "$HOME/$CONFIG_FILE"
    printf "${GREEN}%s${NC}\n" "bash-it template has been added to your $CONFIG_FILE"
  elif [[ $REPLY =~ ^[nN]$ ]] || [[ $silent ]]; then
    sed "s|{{BASH_IT}}|$BASH_IT|" "$BASH_IT/template/bash_profile.template.bash" > "$HOME/$CONFIG_FILE"
    printf "${YELLOW}%s${NC}\n" "Copied the template $CONFIG_FILE into ~/$CONFIG_FILE, edit this file to customize bash-it"
  fi
fi

# Load dependencies for enabling components
source "$BASH_IT/lib/composure.bash"
# Allow access for composure specifc syntax to other functions
cite about param example group _author _version

source "$BASH_IT/lib/helpers.bash"

if ! [[ $silent ]]; then
  printf "\n${GREEN}%s${NC}\n" "Enabling reasonable defaults"

  _bash-it-enable completion bash-it
  _bash-it-enable completion system
  _bash-it-enable completion git
  _bash-it-enable plugin base
  _bash-it-enable plugin alias-completion
  _bash-it-enable alias general
  _bash-it-enable alias gls
fi

! [[ $silent ]] && echo -e  "
${GREEN}Installation finished successfully! Enjoy bash-it!${NC}
${MAGENTA}To start using it, open a new tab or 'source ${HOME}/$CONFIG_FILE'${NC}

To show the available aliases/completions/plugins, type one of the following:
  bash-it show
  bash-it show aliases
  bash-it show completions
  bash-it show plugins

To avoid issues and to keep your shell lean, please enable only features you really want to use.
Enabling everything can lead to issues
"

source "$HOME/$CONFIG_FILE"
