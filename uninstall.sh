#!/usr/bin/env bash

source lib/colors.bash

if [ -z "$BASH_IT" ];
then
  BASH_IT="$HOME/.bash_it"
fi

case $OSTYPE in
  darwin*)
    CONFIG_FILE=.bash_profile
    ;;
  *)
    CONFIG_FILE=.bashrc
    ;;
esac

BACKUP_FILE=$CONFIG_FILE.bak

echo -e "${RED}Uninstalling bash-it${NC}"
if [ ! -e "$HOME/$BACKUP_FILE" ]; then
  echo -e "${YELLOW}Backup file $HOME/$BACKUP_FILE not found${NC}" >&2

  test -w "$HOME/$CONFIG_FILE" &&
    mv "$HOME/$CONFIG_FILE" "$HOME/$CONFIG_FILE.uninstall" &&
    echo -e "${WHITE}Moved your $HOME/$CONFIG_FILE to $HOME/$CONFIG_FILE.uninstall${NC}"
else
  test -w "$HOME/$BACKUP_FILE" &&
    cp -a "$HOME/$BACKUP_FILE" "$HOME/$CONFIG_FILE" &&
    rm "$HOME/$BACKUP_FILE" &&
    echo -e "${WHITE}mYour original $CONFIG_FILE has been restored${NC}"
fi

echo ""
echo -e "${CYAN}Uninstallation finished successfully! Sorry to see you go!${NC}"
echo ""
echo "Final steps to complete the uninstallation:"
echo "  -> Remove the $BASH_IT folder"
echo "  -> Open a new shell/tab/terminal"
