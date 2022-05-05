#!/usr/bin/env bash
# shellcheck shell=bash

: "${GAUDI_BASH:=$HOME/.gaudi_bash}"

case $OSTYPE in
	darwin*)
		CONFIG_FILE=".bash_profile"
		;;
	*)
		CONFIG_FILE=".bashrc"
		;;
esac

BACKUP_FILE=$CONFIG_FILE.bak

if [[ ! -e "$HOME/$BACKUP_FILE" ]]; then
	echo -e "${YELLOW}Backup file $HOME/$BACKUP_FILE not found.${NC}" >&2

	test -w "$HOME/$CONFIG_FILE" \
		&& mv "$HOME/$CONFIG_FILE" "$HOME/$CONFIG_FILE.uninstall" \
		&& echo -e "${GREEN}Moved your $HOME/$CONFIG_FILE to $HOME/$CONFIG_FILE.uninstall.${NC}"
else
	test -w "$HOME/$BACKUP_FILE" \
		&& cp -a "$HOME/$BACKUP_FILE" "$HOME/$CONFIG_FILE" \
		&& rm "$HOME/$BACKUP_FILE" \
		&& echo -e "${GREEN}Your original $CONFIG_FILE has been restored.${NC}"
fi

rm -rf "$GAUDI_BASH"

echo ""
echo -e "${GREEN}un-installation finished successfully! Sorry to see you go!${NC}"
echo ""
echo "Final steps to complete the un-installation:"
echo "  -> Open a new shell/tab/terminal"
