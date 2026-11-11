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

	local component component_type mode component_type_label name about_text

	# Make sure the component is pluralized in case this function is called directly e.g., for unit tests
	component=$(_gaudi-bash-pluralize-component "$1")
	component_type="$(_gaudi-bash-singularize-component "$component")"
	mode=${2:-"all"}

	component_type_label="$(printf "%s" "$component_type" | awk '{print toupper(substr($0, 1, 1)) substr($0, 2)}')"
	printf "\n%-20s%-10s%s\n" "$component_type_label" 'Enabled?' '  Description'
	printf "%*s\n" "${COLUMNS:-$(tput cols 2> /dev/null || echo 80)}" '' | tr ' ' -

	# Only the descriptions are cached: whether a component is enabled is looked up for every row
	while IFS=$'\t' read -r name about_text; do
		[[ -n "$name" ]] || continue
		if _gaudi-bash-component-enabled-file "$component" "$name" > /dev/null; then
			printf "%-20s${GREEN}%-10s${NC}%s\n" "$name" "  ◉" "    $about_text"
		elif [[ "$mode" = "all" ]]; then
			printf "%-20s${RED}%-10s${NC}%s\n" "$name" "  ◯" "    $about_text"
		fi
	done < <(_gaudi-bash-component-descriptions "$component")

	if [[ "$mode" = "all" ]]; then
		printf "\n%b\n" "gaudi-bash allows you easily enable/disable components:

to enable ${GREEN}$component_type${NC}, do:
gbash enable ${GREEN}$component_type${NC}  <${GREEN}$component_type${NC} name> [${GREEN}$component_type${NC} name]... -or- $ gbash enable ${GREEN}$component${NC} all

to disable ${GREEN}$component_type${NC}, do:
gbash disable ${GREEN}$component_type${NC} <${GREEN}$component_type${NC} name> [${GREEN}$component_type${NC} name]... -or- $ gbash disable ${GREEN}$component${NC} all
"
	fi
}
