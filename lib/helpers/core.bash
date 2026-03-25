#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2001,SC2002

# A collection of reusable gaudi-bash functions

# @function     _gaudi-bash-grep
# @description  outputs a full path of the grep found on the filesystem
# @return       Path to the egrep, grep bin e.g., /usr/bin/egrep
_gaudi-bash-grep() {
	about "outputs a full path of the grep found on the filesystem"
	group "gaudi-bash:core"

	if [[ -z "${GAUDI_BASH_GREP}" ]]; then
		GAUDI_BASH_GREP="$(type -P egrep || type -P grep || echo '/usr/bin/grep')"
		export GAUDI_BASH_GREP
	fi
	printf "%s" "${GAUDI_BASH_GREP}"
}

# Cache grep path immediately to avoid repeated subshells
: "${GAUDI_BASH_GREP:=$(type -P egrep 2> /dev/null || type -P grep 2> /dev/null || echo '/usr/bin/grep')}"
export GAUDI_BASH_GREP

# @function     _gaudi-bash-describe
# @description  describes gaudi-bash components by listing the component, description and its status (enabled vs. disabled)
#               the function can display all the items for a specific component (alias, plugin or completion) passed as a param
# @param $1     component: (of type aliases, plugins, completions)
# @param $2     mode <enabled, all>: either show all available components or filter only for enabled ones (default: all)
# @return       table showing each component name, status (enabled/disabled) and description
_gaudi-bash-describe() {
	about "describes gaudi-bash components by listing the component, description and its status (enabled vs. disabled)"
	group "gaudi-bash:core"

	declare -a GAUDI_BASH_DESCRIBE_MODES=(enabled all)

	__check-function-parameters "$1" || return 1
	[[ -n "$2" ]] && ! _array-contains "$2" "${GAUDI_BASH_DESCRIBE_MODES[@]}" && echo "unsupported describe mode" && return 1

	# Make sure the component is pluralized in case this function is called directly e.g., for unit tests
	component=$(_gaudi-bash-pluralize-component "$1")
	component_type="$(_gaudi-bash-singularize-component "$component")"
	mode=${2:-"all"}

	printf "\n%-20s%-10s%s\n" "${component_type^}" 'Enabled?' '  Description'
	printf "%*s\n" "${COLUMNS:-$(tput cols 2> /dev/null || echo 80)}" '' | tr ' ' -

	file=$(_gaudi-bash-component-cache-add "$component-enabled")

	[[ "$mode" = "all" ]] && file=${file/-enabled/}

	if [[ ! -s "${file}" ]]; then
		rm -f "${file}" 2> /dev/null
		local __file
		for __file in "${GAUDI_BASH}/components/$component/lib/"*.bash; do
			local enabled_file component_name about_text
			enabled_file="${__file##*/}"
			component_name="${enabled_file%%.*}"

			about_text="$(metafor about-"$component_type" < "$__file")"

			if compgen -G "${GAUDI_BASH}/components/enabled/*${GAUDI_BASH_LOAD_PRIORITY_SEPARATOR}${enabled_file}" > /dev/null 2>&1; then
				printf "%-20s${GREEN}%-10s${NC}%s\n" "$component_name" "  ◉" "    $about_text" | tee -a "${file}"
			elif [[ "$mode" = "all" ]]; then
				printf "%-20s${RED}%-10s${NC}%s\n" "$component_name" "  ◯" "    $about_text" | tee -a "${file}"
			fi
		done
	else
		cat "${file}"
	fi

	if [[ "$mode" = "all" ]]; then
		printf "\n%b\n" "gaudi-bash allows you easily enable/disable components:

to enable ${GREEN}$component_type${NC}, do:
gaudi-bash enable ${GREEN}$component_type${NC}  <${GREEN}$component_type${NC} name> [${GREEN}$component_type${NC} name]... -or- $ gaudi-bash enable ${GREEN}$component${NC} all

to disable ${GREEN}$component_type${NC}, do:
gaudi-bash disable ${GREEN}$component_type${NC} <${GREEN}$component_type${NC} name> [${GREEN}$component_type${NC} name]... -or- $ gaudi-bash disable ${GREEN}$component${NC} all
"
	fi
}
