#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC1090,SC1091,SC2034,SC2003,SC2317

GAUDI_SETUP_DIRECTORY="$(cd "$(dirname "$0")" && pwd)"
: "${GAUDI_BASH:=${GAUDI_SETUP_DIRECTORY}}"

if ! GAUDI_BASH="$(cd "${GAUDI_BASH}" 2> /dev/null && pwd)"; then
	printf "%s\n" "Error: unable to resolve gaudi-bash directory" >&2
	exit 1
fi
export GAUDI_BASH

source "$GAUDI_SETUP_DIRECTORY/lib/colors.bash"

__require_file() {
	local file="$1"

	if [[ ! -f "$file" ]]; then
		printf "%s\n" "Error: required gaudi-bash file not found: $file" >&2
		return 1
	fi
}

__sync_submodules() {
	[[ -e "$GAUDI_BASH/.git" ]] || return 0

	local submodule_path submodule_root

	git -C "$GAUDI_BASH" submodule sync --recursive || return 1

	while IFS=' ' read -r _ submodule_path; do
		submodule_root="${GAUDI_BASH}/${submodule_path}"

		if [[ -d "$submodule_root" ]] && [[ -z "$(find "$submodule_root" -mindepth 1 -maxdepth 1 -print -quit 2> /dev/null)" ]]; then
			rmdir "$submodule_root" 2> /dev/null || true
		fi

		if [[ -d "$submodule_root" ]] && [[ -n "$(find "$submodule_root" -mindepth 1 -maxdepth 1 -print -quit 2> /dev/null)" ]] && [[ ! -e "$submodule_root/.git" ]]; then
			continue
		fi

		git -C "$GAUDI_BASH" submodule update --init --recursive -- "$submodule_path" || return 1
	done < <(git -C "$GAUDI_BASH" config --file .gitmodules --get-regexp '^submodule\..*\.path$')
}

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


${CYAN}Installing gaudi-bash ..${NC}\n"
}

# Show how to use this installer
show_usage() {
	__print-gaudi-bash
	echo -e "
Usage:\n${GREEN}$0 [arguments] \n${NC}
Arguments:
  ${YELLOW}--help (-h)${NC}: Display this help message
  ${YELLOW}--silent (-s)${NC}: Install default settings without prompting for input
  ${YELLOW}--basic (-b)${NC}: Do not enable default gaudi-bash components
  ${YELLOW}--no-modify-config (-n)${NC}: Do not modify existing config file"
	exit 0
}

for param in "$@"; do
	shift
	case "$param" in
		"--help") set -- "$@" "-h" ;;
		"--silent") set -- "$@" "-s" ;;
		"--basic") set -- "$@" "-b" ;;
		"--no-modify-config") set -- "$@" "-n" ;;
		"--no_modify_config") set -- "$@" "-n" ;;
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
shift $((OPTIND - 1))

# Check if the silent flag is set and direct the output to /dev/null
if [[ -n $silent ]]; then
	exec > /dev/null 2>&1
fi

! [[ $silent ]] && __print-gaudi-bash && bash --version

if ! [[ $no_modify_config ]]; then
	echo ""
	echo -e "${RED}We need to make sure to backup your $CONFIG_FILE before running this installation${NC}"

	if [[ -e "$HOME/$CONFIG_FILE.bak" ]] && ! [[ $silent ]]; then

		echo -e "${GREEN}Backup file already exists!${NC}"
		_read_input "Would you like to overwrite the existing backup? This will delete your existing backup file ($HOME/$CONFIG_FILE.bak) [Yy/Nn]"
		[[ $REPLY =~ ^[yY]$ ]] && cp -aL "$HOME/$CONFIG_FILE" "$HOME/$CONFIG_FILE.bak"

	elif [[ -e "$HOME/$CONFIG_FILE" ]]; then

		cp -aL "$HOME/$CONFIG_FILE" "$HOME/$CONFIG_FILE.bak"
		echo -e "${GREEN}Your original $CONFIG_FILE has been backed up to $CONFIG_FILE.bak${NC}"

	fi

	! [[ $silent ]] && _read_input "Would you like to keep your $CONFIG_FILE and append gaudi-bash templates at the end? [Yy/Nn]"

	if [[ $REPLY =~ ^[yY]$ ]]; then
		(sed "s|{{GAUDI_BASH}}|$GAUDI_BASH|" "$GAUDI_BASH/template/bash_profile.template.bash" | tail -n +2) >> "$HOME/$CONFIG_FILE"
		echo -e "${GREEN}gaudi-bash template has been added to your $CONFIG_FILE${NC}"
	elif [[ $REPLY =~ ^[nN]$ ]] || [[ $silent ]]; then
		sed "s|{{GAUDI_BASH}}|$GAUDI_BASH|" "$GAUDI_BASH/template/bash_profile.template.bash" > "$HOME/$CONFIG_FILE"
		echo -e "${YELLOW}Copied gaudi-bash template into ~/$CONFIG_FILE, edit this file to customize gaudi-bash${NC}"
	fi
fi

# Ensure required submodules are present before sourcing libraries that depend on them.
if ! __sync_submodules; then
	printf "%s\n" "Error: failed to sync gaudi-bash submodules" >&2
	exit 1
fi

# Load dependencies for enabling components
if ! __require_file "$GAUDI_BASH/lib/composure.bash"; then
	exit 1
fi
# shellcheck disable=SC1090
if ! source "$GAUDI_BASH/lib/composure.bash"; then
	printf "%s\n" "Error: failed to load gaudi-bash file: $GAUDI_BASH/lib/composure.bash" >&2
	exit 1
fi
# Allow access for composure specific syntax to other functions
if ! command -v cite > /dev/null 2>&1; then
	printf "%s\n" "Error: failed to initialize gaudi-bash metadata helpers" >&2
	exit 1
fi
cite about param example group priority

if ! __require_file "$GAUDI_BASH/lib/gaudi-bash.bash"; then
	exit 1
fi
# shellcheck disable=SC1090
if ! source "$GAUDI_BASH/lib/gaudi-bash.bash"; then
	printf "%s\n" "Error: failed to load gaudi-bash file: $GAUDI_BASH/lib/gaudi-bash.bash" >&2
	exit 1
fi

if [[ "$no_default_components" != "true" ]]; then

	echo -e "\n${MAGENTA}Enabling gaudi-bash default components${NC}"
	unset GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE

	_gaudi-bash-enable completion gaudi-bash || exit 1
	_gaudi-bash-enable completion system || exit 1
	_gaudi-bash-enable plugin base || exit 1
	_gaudi-bash-enable alias general || exit 1
	_gaudi-bash-enable alias gaudi-bash || exit 1
fi

echo -e "
${GREEN}Installation finished successfully! Enjoy gaudi-bash!${NC}
${MAGENTA}To start using it, open a new tab or 'source ${HOME}/$CONFIG_FILE'${NC}

To show the available aliases/completions/plugins, type one of the following:
  gaudi-bash show
  gaudi-bash show aliases
  gaudi-bash show completions
  gaudi-bash show plugins

To avoid issues and to keep your shell lean, please enable only features you really want to use.
Enabling everything can lead to issues
"
