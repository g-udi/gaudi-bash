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

	local __file

	if [[ -n "${1:-}" ]]; then
		# A specific alias group: prefer the enabled copy, fall back to the available one
		__file="$(compgen -G "${GAUDI_BASH}/components/enabled/*${GAUDI_BASH_LOAD_PRIORITY_SEPARATOR:-___}${1}.aliases.bash" | head -n 1)"
		[[ -n "$__file" ]] || __file="${GAUDI_BASH}/components/aliases/lib/${1}.aliases.bash"
		if [[ ! -e "$__file" ]]; then
			printf '%b
' "${RED:-}No aliases named '${1}' were found${NC:-}" >&2
			return 1
		fi
		__help-list-aliases "$__file"
		return 0
	fi

	for __file in $(sort <(compgen -G "${GAUDI_BASH}/components/enabled/*.aliases.bash")); do
		__help-list-aliases "$__file"
	done
	return 0
}

# @function     _help-plugins
# @description  summarize all functions defined by enabled gaudi-bash plugins
# @param $1     mode: help mode to decide what to show (default: show help for enabled plugins only)
#                 - all: show all help functions that has valid composure about and group (including gaudi-bash core functions)
#                 - <plugin>: show only the functions defined by that plugin
# @return       returns the list of function names and their descriptions
# @example      ❯ _help-plugins
#               ❯ _help-plugins all
#               ❯ _help-plugins git
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

	if [[ -n "${1:-}" && "$1" != "all" ]]; then
		__help-plugin "$1"
		return
	fi

	printf "${GREEN}%s${NC}" "please wait, building help..."
	local grouplist func

	grouplist=$(mktemp -t grouplist.XXXXXX)
	for func in $(_typeset_functions); do
		local group
		group="$(local -f "$func" | metafor group)"
		# Make sure only to include items with a valid group
		if [[ -n "$group" ]]; then
			local about

			[[ "$group" =~ "composure" ]] && continue
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
		printf '%*s\n' "${COLUMNS:-$(tput cols 2> /dev/null || echo 80)}" '' | tr ' ' -
		cat "$gfile"
		printf '\n'
		rm "$gfile" 2> /dev/null
	done | less
	rm "$grouplist" 2> /dev/null
}

# Helper function to list the aliases in a given *.aliases.bash file using the composure meta
__help-list-aliases() {

	[[ -n $1 ]] || return 1
	local file

	file=$(basename "$1" | sed -e 's/[0-9]*[___]*\(.*\)\.aliases\.bash/\1/g')
	printf '\n\n%b\n' "${GREEN}${file}${NC}"
	printf '%*s\n' "${COLUMNS:-$(tput cols 2> /dev/null || echo 80)}" '' | tr ' ' -
	cat "$1" | metafor alias | sed "s/$/'/"
}

# Helper function to list the functions a single plugin defines, with their composure about text
__help-plugin() {

	[[ -n $1 ]] || return 1
	local file func about found

	file="${GAUDI_BASH}/components/plugins/lib/${1}.plugins.bash"
	if [[ ! -e "$file" ]]; then
		printf '%b\n' "${RED:-}No plugin named '${1}' was found${NC:-}" >&2
		return 1
	fi

	printf '\n%b\n' "${GREEN:-}${1}${NC:-}"
	printf '%*s\n' "${COLUMNS:-$(tput cols 2> /dev/null || echo 80)}" '' | tr ' ' -

	# Function names are read from the plugin file; only the ones loaded in this shell can be described
	for func in $(sed -nE -e 's/^[[:space:]]*function[[:space:]]+([^[:space:](){]+).*/\1/p' -e 's/^[[:space:]]*([^[:space:](){#=]+)[[:space:]]*\(\).*/\1/p' "$file" | sort -u); do
		declare -F "$func" > /dev/null 2>&1 || continue
		about="$(declare -f "$func" | metafor about)"
		printf '%-45s%s\n' "$func" "$about"
		found=true
	done

	if [[ -z "${found:-}" ]]; then
		printf '%s\n' "No functions from this plugin are loaded. Enable it with: gbash enable plugin ${1}"
	fi
	return 0
}
