#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC1090,SC1091,SC2034,SC2003,SC2317

GAUDI_SETUP_SOURCE="${BASH_SOURCE[0]:-$0}"
GAUDI_SETUP_DIRECTORY="$(cd "$(dirname "$GAUDI_SETUP_SOURCE")" && pwd)"
: "${GAUDI_BASH:=$GAUDI_SETUP_DIRECTORY}"
export GAUDI_BASH

source "$GAUDI_SETUP_DIRECTORY/lib/colors.bash"

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

# First line of the gaudi-bash block in the profile template (see template/bash_profile.template.bash)
GAUDI_PROFILE_MARKER="# >>> gaudi-bash >>>"

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
}

_die() {
	printf "%s\n" "Error: $*" >&2
	return 1
}

_parse_args() {
	silent=false
	no_modify_config=false
	no_default_components=false

	while [[ $# -gt 0 ]]; do
		case "$1" in
			-h | --help)
				show_usage
				return 2
				;;
			-s | --silent)
				silent=true
				;;
			-b | --basic)
				no_default_components=true
				;;
			-n | --no-modify-config | --no_modify_config)
				no_modify_config=true
				;;
			*)
				printf "%s\n" "Unknown argument: $1" >&2
				show_usage >&2
				return 1
				;;
		esac
		shift
	done
}

_submodules_needed() {
	local dependency_root="${GAUDI_BASH_ORIGIN:-$GAUDI_BASH}"

	[[ ! -s "$dependency_root/bin/composure/composure.sh" ]] && return 0
	[[ ! -s "$dependency_root/bin/preexec/bash-preexec.sh" ]] && return 0

	if [[ "$no_default_components" != "true" ]]; then
		[[ ! -d "$GAUDI_BASH/components/aliases/lib" ]] && return 0
		[[ ! -d "$GAUDI_BASH/components/completions/lib" ]] && return 0
		[[ ! -d "$GAUDI_BASH/components/plugins/lib" ]] && return 0
		[[ ! -d "$GAUDI_BASH/components/themes/gaudi" ]] && return 0
	fi

	return 1
}

# Fetches the git submodules gaudi-bash runs on (composure, preexec and the components), not the ones only the tests need
_init_submodules() {
	if _submodules_needed && git -C "$GAUDI_BASH" rev-parse --is-inside-work-tree > /dev/null 2>&1; then
		source "$GAUDI_BASH/lib/helpers/updater.bash" || return 1
		_gaudi-bash-submodules-update "$GAUDI_BASH" || return 1
	fi
}

_validate_install_paths() {
	local dependency_root="${GAUDI_BASH_ORIGIN:-$GAUDI_BASH}"

	[[ -s "$GAUDI_BASH/template/bash_profile.template.bash" ]] || _die "Missing profile template: $GAUDI_BASH/template/bash_profile.template.bash" || return 1
	[[ -s "$dependency_root/bin/composure/composure.sh" ]] || _die "Missing composure dependency. Run: git submodule update --init --recursive" || return 1
	[[ -s "$dependency_root/bin/preexec/bash-preexec.sh" ]] || _die "Missing bash-preexec dependency. Run: git submodule update --init --recursive" || return 1
	[[ -s "$GAUDI_BASH/lib/gaudi-bash.bash" ]] || _die "Missing gaudi-bash core library: $GAUDI_BASH/lib/gaudi-bash.bash" || return 1
}

_render_profile_template() {
	local skip_shebang="$1"
	local line first_line=true

	while IFS= read -r line || [[ -n "$line" ]]; do
		if [[ "$skip_shebang" == "true" && "$first_line" == "true" ]]; then
			first_line=false
			continue
		fi
		first_line=false
		printf "%s\n" "${line//\{\{GAUDI_BASH\}\}/$GAUDI_BASH}"
	done < "$GAUDI_BASH/template/bash_profile.template.bash"
}

# Checks if the profile already loads gaudi-bash: either the marked template block or the load line of an older install
_profile_has_gaudi_bash() {
	[[ -f "$1" ]] || return 1
	grep -qF "$GAUDI_PROFILE_MARKER" "$1" || grep -qE '^[[:space:]]*(source|\.)[[:space:]].*gaudi_bash\.sh' "$1"
}

# Backs up the profile without ever overwriting an existing backup unattended
_backup_profile() {
	local profile="$HOME/$CONFIG_FILE"
	local backup="$profile.bak"

	[[ -e "$profile" ]] || return 0

	if [[ -e "$backup" ]]; then
		# Nothing to keep when the profile is the backup itself or the unmodified gaudi-bash template
		cmp -s "$profile" "$backup" && return 0
		cmp -s "$profile" <(_render_profile_template false) && return 0

		if ! [[ $silent == true ]]; then
			echo -e "${GREEN}Backup file already exists!${NC}"
			_read_input "Would you like to overwrite the existing backup? This will delete your existing backup file ($backup) [Yy/Nn]"
		fi

		if ! [[ $silent == true ]] && [[ $REPLY =~ ^[yY]$ ]]; then
			cp -aL "$profile" "$backup" || return 1
		else
			backup="$backup.$(date +%Y%m%d%H%M%S)"
			cp -aL "$profile" "$backup" || return 1
			echo -e "${GREEN}Your existing backup was kept, your current $CONFIG_FILE has been backed up to ${backup##*/}${NC}"
		fi
	else
		cp -aL "$profile" "$backup" || return 1
		echo -e "${GREEN}Your original $CONFIG_FILE has been backed up to $CONFIG_FILE.bak${NC}"
	fi
}

_write_profile_template() {
	local destination="$HOME/$CONFIG_FILE"
	local mode="$1"

	if [[ "$mode" == "append" ]]; then
		# Appending is idempotent: running setup again must not add a second copy of the template
		if _profile_has_gaudi_bash "$destination"; then
			echo -e "${GREEN}gaudi-bash is already loaded from your $CONFIG_FILE, leaving it as is${NC}"
			return 0
		fi
		_render_profile_template true >> "$destination"
		echo -e "${GREEN}gaudi-bash template has been added to your $CONFIG_FILE${NC}"
	else
		_render_profile_template false > "$destination"
	fi
}

_setup_gaudi_bash() {
	_init_submodules || return 1
	_validate_install_paths || return 1

	! [[ $silent == true ]] && __print-gaudi-bash && bash --version

	if ! [[ $no_modify_config == true ]]; then
		echo ""
		echo -e "${RED}We need to make sure to backup your $CONFIG_FILE before running this installation${NC}"

		_backup_profile || _die "Could not back up $HOME/$CONFIG_FILE, leaving it untouched" || return 1

		! [[ $silent == true ]] && _read_input "Would you like to keep your $CONFIG_FILE and append gaudi-bash templates at the end? [Yy/Nn]"

		if ! [[ $silent == true ]] && [[ $REPLY =~ ^[yY]$ ]]; then
			_write_profile_template append
		elif [[ $REPLY =~ ^[nN]$ ]] || [[ $silent == true ]]; then
			_write_profile_template replace
			echo -e "${YELLOW}Copied gaudi-bash template into ~/$CONFIG_FILE, edit this file to customize gaudi-bash${NC}"
		fi
	fi

	# Load dependencies for enabling components
	source "$GAUDI_BASH/lib/composure.bash"
	# Allow access for composure specific syntax to other functions
	cite about param example group priority

	source "$GAUDI_BASH/lib/gaudi-bash.bash"

	if [[ "$no_default_components" != "true" ]]; then
		local enable_failed=false

		echo -e "\n${MAGENTA}Enabling gaudi-bash default components${NC}"

		_gaudi-bash-enable completion gaudi-bash || enable_failed=true
		_gaudi-bash-enable completion system || enable_failed=true
		_gaudi-bash-enable plugin base || enable_failed=true
		_gaudi-bash-enable alias general || enable_failed=true
		_gaudi-bash-enable alias gaudi-bash || enable_failed=true

		[[ "$enable_failed" == "true" ]] && return 1
	fi

	echo -e "
${GREEN}Installation finished successfully! Enjoy gaudi-bash!${NC}
${MAGENTA}To start using it, open a new tab or 'source ${HOME}/$CONFIG_FILE'${NC}

To show the available aliases/completions/plugins, type one of the following:
  gbash show
  gbash show aliases
  gbash show completions
  gbash show plugins

To avoid issues and to keep your shell lean, please enable only features you really want to use.
Enabling everything can lead to issues
"
}

_main() {
	local parse_status=0
	_parse_args "$@" || parse_status=$?
	[[ "$parse_status" -eq 2 ]] && return 0
	[[ "$parse_status" -ne 0 ]] && return "$parse_status"

	if [[ $silent == true ]]; then
		# Errors are kept on stderr so that a failed silent install says why it failed
		_setup_gaudi_bash > /dev/null
	else
		_setup_gaudi_bash
	fi
}

setup_status=0
_main "$@" || setup_status=$?

if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
	return "$setup_status"
fi
exit "$setup_status"
