#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2034

source "./lib/colors.bash"
source "./lib/composure.bash"; cite about group
source "./lib/helpers/utils.bash"

case $OSTYPE in
  darwin*)
    CONFIG_FILE=.bash_profile
    ;;
  *)
    CONFIG_FILE=.bashrc
    ;;
esac

# This is a special "print" function that prints the bash-it ASCII art
__print-bash-it () {

echo -e "
██████╗  █████╗ ███████╗██╗  ██╗      ██╗████████╗
██╔══██╗██╔══██╗██╔════╝██║  ██║      ██║╚══██╔══╝
██████╔╝███████║███████╗███████║█████╗██║   ██║
██╔══██╗██╔══██║╚════██║██╔══██║╚════╝██║   ██║
██████╔╝██║  ██║███████║██║  ██║      ██║   ██║
╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝      ╚═╝   ╚═╝

${CYAN}Installing bash-it ..${NC}"
}

# Show how to use this installer
show_usage () {
  __print-bash-it
  echo -e "
Usage:\n${GREEN}$0 [arguments] \n${NC}
Arguments:
  ${YELLOW}--help (-h)${NC}: Display this help message
  ${YELLOW}--silent (-s)${NC}: Install default settings without prompting for input
  ${YELLOW}--no-modify-config (-n)${NC}: Do not modify existing config file"
  exit 0;
}

for param in "$@"; do
  shift
  case "$param" in
    "--help") set -- "$@" "-h" ;;
    "--silent") set -- "$@" "-s" ;;
    "--no-modify-config") set -- "$@" "-n" ;;
    *) set -- "$@" "$param"
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

# Check if the silent flag is set and direct the output to /dev/null
if [[ -n $silent ]] ; then
    exec >/dev/null 2>&1
fi

BASH_IT="$(cd "$(dirname "$0")" && pwd)"

! [[ $silent ]] && __print-bash-it && bash --version

if ! [[ $no_modify_config ]]; then

  echo -e "${RED}We need to make sure to backup your $CONFIG_FILE before running this installation${NC}"

  if [[ -e "$HOME/$CONFIG_FILE.bak" ]] && ! [[ $silent ]]; then

    echo -e "${GREEN}Backup file already exists!${NC}"
    _read_input "Would you like to overwrite the existing backup? This will delete your existing backup file ($HOME/$CONFIG_FILE.bak) [Yy/Nn]"
    [[ $REPLY =~ ^[yY]$ ]] && cp -aL "$HOME/$CONFIG_FILE" "$HOME/$CONFIG_FILE.bak"

  elif [[ -e "$HOME/$CONFIG_FILE" ]]; then

    cp -aL "$HOME/$CONFIG_FILE" "$HOME/$CONFIG_FILE.bak"
    echo -e"${GREEN}Your original $CONFIG_FILE has been backed up to $CONFIG_FILE.bak${NC}"

  fi

  ! [[ $silent ]] && _read_input "Would you like to keep your $CONFIG_FILE and append bash-it templates at the end? [Yy/Nn]"

  if [[ $REPLY =~ ^[yY]$ ]]; then
    (sed "s|{{BASH_IT}}|$BASH_IT|" "$BASH_IT/template/bash_profile.template.bash" | tail -n +2) >> "$HOME/$CONFIG_FILE"
    echo -e "${GREEN}bash-it template has been added to your $CONFIG_FILE${NC}"
  elif [[ $REPLY =~ ^[nN]$ ]] || [[ $silent ]]; then
    sed "s|{{BASH_IT}}|$BASH_IT|" "$BASH_IT/template/bash_profile.template.bash" > "$HOME/$CONFIG_FILE"
    echo -e "${YELLOW}Copied bash-it template into ~/$CONFIG_FILE, edit this file to customize bash-it${NC}"
  fi
fi

# Load dependencies for enabling components
source "$BASH_IT/lib/composure.bash"
# Allow access for composure specific syntax to other functions
cite about param example group

source "$BASH_IT/lib/helpers.bash"

# Check if the folder is a valid git and pull all submodules
[[ -d "$BASH_IT/.git" ]] && git submodule update --init --recursive

echo -e  "\n${MAGENTA}Enabling reasonable defaults${NC}"

_bash-it-enable completion bash-it
_bash-it-enable completion system
_bash-it-enable completion git
_bash-it-enable plugin base
_bash-it-enable plugin alias-completion
_bash-it-enable alias general
_bash-it-enable alias gls


echo -e "
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
