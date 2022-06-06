#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC1090,SC1091,SC2034,SC2003

_read_input() {
	unset REPLY
	while ! [[ $REPLY =~ ^[yY]$ ]] && ! [[ $REPLY =~ ^[nN]$ ]]; do
		read -rp "${1} " -n 1 < /dev/tty
		[[ -n $REPLY ]] && echo ""
	done
}

case $OSTYPE in
	darwin*)
		CONFIG_FILE=".bash_profile"
		;;
	*)
		CONFIG_FILE=".bashrc"
		;;
esac

# This is a special "print" function that prints the gaudi-bash ASCII art
__print-gaudi-bash() {

	echo -e "

 ██████╗  █████╗ ██╗   ██╗██████╗ ██╗      ██████╗  █████╗ ███████╗██╗  ██╗
██╔════╝ ██╔══██╗██║   ██║██╔══██╗██║      ██╔══██╗██╔══██╗██╔════╝██║  ██║
██║  ███╗███████║██║   ██║██║  ██║██║█████╗██████╔╝███████║███████╗███████║
██║   ██║██╔══██║██║   ██║██║  ██║██║╚════╝██╔══██╗██╔══██║╚════██║██╔══██║
╚██████╔╝██║  ██║╚██████╔╝██████╔╝██║      ██████╔╝██║  ██║███████║██║  ██║
 ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝      ╚═════╝ ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝


Installing gaudi-bash ..\n"
}

# Show how to use this installer
show_usage() {
	__print-gaudi-bash
	echo -e "
Usage:\n$0 [arguments] \n
Arguments:
  --help (-h): Display this help message
  --silent (-s): Install default settings without prompting for input
  --basic (-b): Do not enable default gaudi-bash components
  --no-modify-config (-n): Do not modify existing config file"
	exit 0
}

for param in "$@"; do
	shift
	case "$param" in
		"--help") set -- "$@" "-h" ;;
		"--silent") set -- "$@" "-s" ;;
		"--basic") set -- "$@" "-b" ;;
		"--no-modify-config") set -- "$@" "-n" ;;
		*) set -- "$@" "$param" ;;
	esac
done

OPTIND=1
while getopts "hsnb" opt; do
	case "$opt" in
		"h")
			show_usage
			exit 0
			;;
		"s") silent=true ;;
		"n") no_modify_config=true ;;
		"b") no_default_components=true ;;
		"?")
			show_usage >&2
			exit 1
			;;
	esac
done
shift "$(expr $OPTIND - 1)"

# Check if the silent flag is set and direct the output to /dev/null
if [[ -n $silent ]]; then
	exec > /dev/null 2>&1
fi

! [[ $silent ]] && __print-gaudi-bash && bash --version

if ! [[ $no_modify_config ]]; then
	echo ""
	echo -e "We need to make sure to backup your $CONFIG_FILE before running this installation"

	if [[ -e "$HOME/$CONFIG_FILE.bak" ]] && ! [[ $silent ]]; then

		echo -e "Backup file already exists!"
		_read_input "Would you like to overwrite the existing backup? This will delete your existing backup file ($HOME/$CONFIG_FILE.bak) [Yy/Nn]"
		[[ $REPLY =~ ^[yY]$ ]] && cp -aL "$HOME/$CONFIG_FILE" "$HOME/$CONFIG_FILE.bak"

	elif [[ -e "$HOME/$CONFIG_FILE" ]]; then

		cp -aL "$HOME/$CONFIG_FILE" "$HOME/$CONFIG_FILE.bak"
		echo -e"Your original $CONFIG_FILE has been backed up to $CONFIG_FILE.bak"

	fi

	! [[ $silent ]] && _read_input "Would you like to keep your $CONFIG_FILE and append gaudi-bash templates at the end? [Yy/Nn]"

	if [[ $REPLY =~ ^[yY]$ ]]; then
		(sed "s|{{GAUDI_BASH}}|$GAUDI_BASH|" "$GAUDI_BASH/template/bash_profile.template.bash" | tail -n +2) >> "$HOME/$CONFIG_FILE"
		echo -e "gaudi-bash template has been added to your $CONFIG_FILE"
	elif [[ $REPLY =~ ^[nN]$ ]] || [[ $silent ]]; then
		sed "s|{{GAUDI_BASH}}|$GAUDI_BASH|" "$GAUDI_BASH/template/bash_profile.template.bash" > "$HOME/$CONFIG_FILE"
		echo -e "Copied gaudi-bash template into ~/$CONFIG_FILE, edit this file to customize gaudi-bash"
	fi
fi

# Load dependencies for enabling components
source "$GAUDI_BASH/lib/composure.bash"
# Allow access for composure specific syntax to other functions
cite about param example group priority

source "$GAUDI_BASH/lib/gaudi-bash.bash"

# Check if the folder is a valid git and pull all submodules
[[ -d "$GAUDI_BASH/.git" &&  "$no_default_components" != "true" ]] && git submodule update --init --recursive

if [[ "$no_default_components" != "true" ]]; then

	echo -e "\nEnabling gaudi-bash default components"

	_gaudi-bash-enable completion gaudi-bash
	_gaudi-bash-enable completion system
	_gaudi-bash-enable plugin base
	_gaudi-bash-enable plugin alias-completion
	_gaudi-bash-enable alias general
	_gaudi-bash-enable alias gls
	_gaudi-bash-enable alias gaudi-bash
fi

echo -e "
Installation finished successfully! Enjoy gaudi-bash!
To start using it, open a new tab or 'source ${HOME}/$CONFIG_FILE'

To show the available aliases/completions/plugins, type one of the following:
  gaudi-bash show
  gaudi-bash show aliases
  gaudi-bash show completions
  gaudi-bash show plugins

To avoid issues and to keep your shell lean, please enable only features you really want to use.
Enabling everything can lead to issues
"
