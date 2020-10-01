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
  echo "--interactive (-i): Interactively choose plugins"
  echo "--no-modify-config (-n): Do not modify existing config file"
  exit 0;
}

# enable one component (alias, plugin, completion)
load_one () {
  file_type=$1
  file_to_enable=$2
  mkdir -p "$BASH_IT/${file_type}/enabled"

  dest="${BASH_IT}/${file_type}/enabled/${file_to_enable}"
  if [[ ! -e "${dest}" ]]; then
    ln -sf "../available/${file_to_enable}" "${dest}"
  else
    echo "File ${dest} exists, skipping"
  fi
}

# Interactively enable several components
load_some () {
  file_type=$1
  single_type=$(echo "$file_type" | sed -e "s/aliases$/alias/g" | sed -e "s/plugins$/plugin/g")
  enable_func="_enable-$single_type"
  [[ -d "$BASH_IT/$file_type/enabled" ]] || mkdir "$BASH_IT/$file_type/enabled"
  for path in "$BASH_IT/${file_type}/available/"[^_]*
  do
    file_name=$(basename "$path")
    while true
    do
      just_the_name="${file_name%%.*}"
      read -e -n 1 -p "Would you like to enable the $just_the_name $file_type? [Y/N] " RESP
      case $RESP in
      [yY])
        $enable_func $just_the_name
        break
        ;;
      [nN]|"")
        break
        ;;
      *)
        echo -e "Please choose [Y/N]"
        ;;
      esac
    done
  done
}

for param in "$@"; do
  shift
  case "$param" in
    "--help")               set -- "$@" "-h" ;;
    "--silent")             set -- "$@" "-s" ;;
    "--interactive")        set -- "$@" "-i" ;;
    "--no-modify-config")   set -- "$@" "-n" ;;
    *)                      set -- "$@" "$param"
  esac
done

OPTIND=1
while getopts "hsin" opt
do
  case "$opt" in
  "h") show_usage; exit 0 ;;
  "s") silent=true ;;
  "i") interactive=true ;;
  "n") no_modify_config=true ;;
  "?") show_usage >&2; exit 1 ;;
  esac
done
shift "$(expr $OPTIND - 1)"

if [[ $silent ]] && [[ $interactive ]]; then
  echo -e "Options --silent and --interactive are mutually exclusive. Please choose one or the other"
  exit 1;
fi

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
cite about param example group _author _version
source "$BASH_IT/lib/helpers.bash"

if [[ $interactive ]] && ! [[ $silent ]] ;
then
  for type in "aliases" "plugins" "completion"
  do
    echo -e "${GREEN}Enabling $type${NC}"
    load_some $type
  done
else
  echo ""
  echo -e "${GREEN}Enabling reasonable defaults${NC}\n"
  _enable-completion bash-it
  _enable-completion system
  _enable-completion git
  _enable-plugin base
  _enable-plugin alias-completion
  _enable-alias general
  _enable-alias gls
fi

echo ""
echo -e "${GREEN}Installation finished successfully! Enjoy bash-it!${NC}"
echo -e "${MAGENTA}To start using it, open a new tab or 'source "$HOME/$CONFIG_FILE"'.${NC}"
echo ""
echo "To show the available aliases/completions/plugins, type one of the following:"
echo "  bash-it show"
echo "  bash-it show aliases"
echo "  bash-it show completions"
echo "  bash-it show plugins"
echo ""
echo "To avoid issues and to keep your shell lean, please enable only features you really want to use."
echo "Enabling everything can lead to issues"

source "$CONFIG_FILE"
