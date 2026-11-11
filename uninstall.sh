#!/usr/bin/env bash
# shellcheck shell=bash

: "${GAUDI_BASH:=$HOME/.gaudi_bash}"

# Removes the gaudi-bash lines from a profile, keeping a copy of the profile as it was in <profile>.uninstall
# $1: path of the profile
_gaudi_bash_uninstall_clean_profile() {
	local profile="$1"
	local cleaned="$1.gaudi-bash-uninstall"
	local block_start="# >>> gaudi-bash >>>" block_end="# <<< gaudi-bash <<<"
	local load_line='^[[:space:]]*(source|\.)[[:space:]].*gaudi_bash\.sh'

	if grep -qFx "$block_start" "$profile" && grep -qFx "$block_end" "$profile"; then
		sed "/^${block_start}\$/,/^${block_end}\$/d" "$profile" > "$cleaned" || return 1
	elif grep -qE "$load_line" "$profile"; then
		# Profiles written by older versions have no markers: only drop the line that loads gaudi-bash
		grep -vE "$load_line" "$profile" > "$cleaned"
		echo -e "${YELLOW}Removed the line that loads gaudi-bash from $profile, the gaudi-bash settings (GAUDI_BASH*) around it can be deleted by hand.${NC}"
	else
		echo -e "${YELLOW}$profile does not load gaudi-bash, it was left as is.${NC}"
		return 0
	fi

	# Write through the profile (it might be a symlink) and keep its previous content aside
	cp -aL "$profile" "$profile.uninstall" && cat "$cleaned" > "$profile" && rm -f "$cleaned" || return 1
	echo -e "${GREEN}Removed gaudi-bash from $profile (the previous version was saved to $profile.uninstall).${NC}"
}

_gaudi_bash_uninstall() {
	local arg profile_name profile backup restore_backup=false REPLY=""

	for arg in "$@"; do
		case "$arg" in
			--restore-backup)
				restore_backup=true
				;;
			*)
				echo "Usage: uninstall.sh [--restore-backup]"
				echo "  --restore-backup: replace your Bash profile with the backup taken by setup.sh without asking"
				[[ "$arg" == "-h" || "$arg" == "--help" ]] && return 0
				return 1
				;;
		esac
	done

	# Find the profile the same way setup.sh does, GAUDI_BASH_PROFILE is only set inside a gaudi-bash shell
	profile_name="${GAUDI_BASH_PROFILE:-}"
	if [[ -z "$profile_name" ]]; then
		case $OSTYPE in
			darwin*)
				profile_name=".bash_profile"
				;;
			?*)
				profile_name=".bashrc"
				;;
		esac
	fi

	if [[ -z "${HOME:-}" || -z "$profile_name" ]]; then
		echo -e "${RED}Could not determine which Bash profile loads gaudi-bash, nothing was changed.${NC}" >&2
		echo "Set GAUDI_BASH_PROFILE to its name (e.g., GAUDI_BASH_PROFILE=.bash_profile) and run this script again." >&2
		return 1
	fi

	if [[ ! -f "$GAUDI_BASH/gaudi_bash.sh" ]]; then
		echo -e "${RED}$GAUDI_BASH does not look like a gaudi-bash installation, nothing was changed.${NC}" >&2
		return 1
	fi

	profile="$HOME/$profile_name"
	backup="$profile.bak"

	if [[ -e "$profile" && ! -w "$profile" ]]; then
		echo -e "${RED}$profile is not writable, nothing was changed.${NC}" >&2
		return 1
	fi

	# Restoring the backup discards everything added to the profile since the installation, so it needs a clear yes
	if [[ "$restore_backup" != true && -e "$backup" && -t 0 ]]; then
		printf "%s" "Replace $profile with the backup taken at installation ($backup)? [y/N] "
		read -r REPLY || true
		[[ $REPLY =~ ^[yY]$ ]] && restore_backup=true
	fi

	if [[ "$restore_backup" == true ]]; then
		if [[ ! -e "$backup" ]]; then
			echo -e "${RED}Backup file $backup not found, nothing was changed.${NC}" >&2
			return 1
		fi
		cp -a "$backup" "$profile" && rm "$backup" || return 1
		echo -e "${GREEN}Your original $profile_name has been restored.${NC}"
	elif [[ -e "$profile" ]]; then
		if ! _gaudi_bash_uninstall_clean_profile "$profile"; then
			echo -e "${RED}Could not update $profile, nothing was removed.${NC}" >&2
			return 1
		fi
		[[ -e "$backup" ]] && echo "The backup taken at installation was kept: $backup"
	else
		echo -e "${YELLOW}$profile not found, there is no profile to clean.${NC}"
	fi

	rm -rf "$GAUDI_BASH"

	echo ""
	echo -e "${GREEN}un-installation finished successfully! Sorry to see you go!${NC}"
	echo ""
	echo "Final steps to complete the un-installation:"
	echo "  -> Open a new shell/tab/terminal"
}

_gaudi_bash_uninstall "$@"
_gaudi_bash_uninstall_status=$?

unset -f _gaudi_bash_uninstall _gaudi_bash_uninstall_clean_profile

if [[ "${BASH_SOURCE[0]}" != "$0" ]]; then
	return "$_gaudi_bash_uninstall_status"
fi
exit "$_gaudi_bash_uninstall_status"
