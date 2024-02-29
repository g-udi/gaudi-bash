#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2002,SC2013

# @function     _help-completions
# @description  summarize all completions available in gaudi-bash
# @return       returns the table of available completions, their status(enabled/disabled) and description
# @example      ❯ _help-completions
_help-completions() {
	about 'summarize all completions available in gaudi-bash'
	group 'gaudi-bash:core:help'

	_gaudi-bash-show completions
}

# @function     _help-aliases
# @description  summarize aliases available in gaudi-bash (default: all enabled aliases)
# @param $1     (optional) component name: display only aliases for the passed component if available
# @return       returns the list of alias definitions
# @example      ❯ _help-aliases
#               ❯ _help-aliases git
_help-aliases() {
	about "shows help for all aliases, or a specific alias group"
	group "gaudi-bash:core:help"


	# Helper function to list the aliases in a given *.aliases.bash file using the composure meta
	__help-list-aliases() {
		local file

		file=$(basename "$1" | sed -e 's/[0-9]*[___]*\(.*\)\.aliases\.bash/\1/g')
		printf '\n\n%b\n' "${GREEN}${file}${NC}"
		printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
		cat "$1" | metafor alias | sed "s/$/'/"
	}

	if [[ -n "$1" ]]; then
		local alias_path="aliases/lib/$1.aliases.bash"
		
		# If the alias doesn't exist .. return an error code
		if [[ ! -e "${GAUDI_BASH}/components/$alias_path" ]]; then
			printf "${RED}The provided alias: ${GREEN}%s${NC} ${RED}doesn't exist${NC}" "$1"
			return 1
		fi

		cat "${GAUDI_BASH}/components/$alias_path" | metafor alias | sed "s/$/'/"
	else
		local __file
		for __file in $(sort <(compgen -G "${GAUDI_BASH}/components/aliases/lib/*.aliases.bash")); do
			__help-list-aliases "$__file"
		done
	fi
}

# @function     _help-plugins
# @description  summarize all functions defined by enabled gaudi-bash plugins
# @param $1     mode: help mode to decide what to show (default: show help for enabled plugins only)
#                 - all: show all help functions that has valid composure about and group (including gaudi-bash core functions)
# @return       returns the list of function names and their descriptions
# @example      ❯ _help-plugins
#               ❯ _help-plugins all
_help-plugins() {
	about 'summarize all functions defined by enabled gaudi-bash plugins'
	group 'gaudi-bash:core:help'

	# Overrides the composure default letterpress function to allow for custom column width setting for plugins help
	__letterpress() {
		typeset rightcol="$1" leftcol="${2:- }" leftwidth="${10:-45}"

		if [ -z "$rightcol" ]; then
			return
		fi
		printf "%-*s%s\n" "$leftwidth" "$leftcol" "$rightcol"
	}

	printf "${GREEN}%s${NC}" "please wait, building help..."
	local grouplist func

	grouplist=$(mktemp -t grouplist.XXXXXX)
	for func in $(_typeset_functions); do
		local group
		group="$(local -f "$func" | metafor group)"
		# Make sure only to include items with a valid group
		if [[ -n "$group" ]]; then
			local about

			[[ "$group" =~ "composure" ]] && continue;
			if [[ $1 != "all" ]] && [[ "$group" =~ "gaudi-bash" ]]; then
				continue
			fi

			about="$(local -f "$func" | metafor about)"
			__letterpress "$about" "$func" >> "$grouplist"."$group"
			echo "$grouplist"."$group" >> "$grouplist"

		fi
	done

	local group gfile
	for gfile in $(cat "$grouplist" | sort | uniq); do
		printf '%s\n' "${gfile##*.}"
		printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
		cat "$gfile"
		printf '\n'
		rm "$gfile" 2> /dev/null
	done | less
	rm "$grouplist" 2> /dev/null
}
