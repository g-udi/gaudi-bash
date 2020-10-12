#!/usr/bin/env bash
# shellcheck disable=SC2001

# A collection of reusable bash-it functions

# @function     _bash-it-grep
# @description  outputs a full path of the grep found on the filesystem
# @return       Path to the egrep, grep bin e.g., /usr/bin/egrep
_bash-it-grep () {
  about "outputs a full path of the grep found on the filesystem"
  group "bash-it:core"

  if [[ -z "${BASH_IT_GREP}" ]] ; then
    BASH_IT_GREP="$(which egrep || which grep || '/usr/bin/grep')"
    export BASH_IT_GREP
  fi
  printf "%s " "${BASH_IT_GREP}"
}

# @function     _bash-it-describe
# @description  describes bash-it components by listing the component, description and its status (enabled vs. disabled)
#               the function can display all the items for a specific component (alias, plugin or completion) passed as a param
# @param $1     component: (of type aliases, plugins, completions)
# @param $2     mode <enabled, all>: either show all available components or filter only for enabled ones (default: all)
# @return       table showing each component name, status (enabled/disabled) and description
_bash-it-describe () {
    about "describes bash-it components by listing the component, description and its status (enabled vs. disabled)"
    group "bash-it:core"

    declare -a BASH_IT_DESCRIBE_MODES=(enabled all)

    __check-function-parameters "$1" || return 1
    [[ -n "$2" ]] && ! _array-contains "$2" "${BASH_IT_DESCRIBE_MODES[@]}" && echo "unsupported describe mode" && return 1

    # Make sure the component is pluralized in case this function is called directly e.g., for unit tests
    component=$(_bash-it-pluralize-component "$1")
    component_type="$(_bash-it-singularize-component "$component")"
    mode=${2:-"all"}

    printf "\n%-20s%-10s%s\n" "${component_type^}" "Enabled?" "  Description"
    printf "%*s\n" "${COLUMNS:-$(tput cols)}" '' | tr ' ' -

    file=$(_bash-it-component-cache-add "${component}-enabled")
    [[ "$mode" = "all" ]] && file=${file/-enabled/}

    if [[ ! -s "${file}" || -z $(find "${file}" -mmin -300) ]] ; then
      rm -f "${file}" 2>/dev/null
        local __file
        for __file in "${BASH_IT}/components/$component/"*.bash
        do
            # Check for both the old format without the load priority, and the extended format with the priority
            declare enabled_files enabled_file
            enabled_file=$(basename "$__file")
            enabled_files=$(sort <(compgen -G "${BASH_IT}/components/enabled/*$BASH_IT_LOAD_PRIORITY_SEPARATOR${enabled_file}") | wc -l)

            if [[ "$enabled_files" -gt 0 ]]; then
                printf "%-20s${GREEN}%-10s${NC}%s\n" "$(basename "$__file" | sed -e 's/\(.*\)\..*\.bash/\1/g')" "  ◉" "    $(cat $__file | metafor about-"$component_type")" 2>&1 | tee -a "${file}"
            elif [[ "$mode" = "all" ]]; then
                printf "%-20s${RED}%-10s${NC}%s\n" "$(basename "$__file" | sed -e 's/\(.*\)\..*\.bash/\1/g')" "  ◯" "    $(cat $__file | metafor about-"$component_type")" 2>&1 | tee -a "${file}"
            fi
        done
    else
      cat "${file}"
    fi

    if [[ "$mode" = "all" ]]; then
      printf "\n%b" "bash-it allows you easily enable/disable components:

to enable ${GREEN}$component_type${NC}, do:
bash-it enable ${GREEN}$component_type${NC}  <${GREEN}$component_type${NC} name> [${GREEN}$component_type${NC} name]... -or- $ bash-it enable ${GREEN}$component${NC} all

to disable ${GREEN}$component_type${NC}, do:
bash-it disable ${GREEN}$component_type${NC} <${GREEN}$component_type${NC} name> [${GREEN}$component_type${NC} name]... -or- $ bash-it disable ${GREEN}$component${NC} all
"
    fi
}
