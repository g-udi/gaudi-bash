#!/usr/bin/env bash

BASH_IT_LOAD_PRIORITY_DEFAULT_ALIASES=${BASH_IT_LOAD_PRIORITY_DEFAULT_ALIASES:-150}
BASH_IT_LOAD_PRIORITY_DEFAULT_PLUGINS=${BASH_IT_LOAD_PRIORITY_DEFAULT_PLUGINS:-250}
BASH_IT_LOAD_PRIORITY_DEFAULT_COMPLETIONS=${BASH_IT_LOAD_PRIORITY_DEFAULT_COMPLETIONS:-350}

# @function     _bash-it-enable
# @description  enables a component
# @param $1     component type: bash-it component of type aliases, plugins, completions
# @param $2     component name: bash-it component name .e.g., base, git
# @return       message to indicate the outcome
_bash-it-enable () {

    about "enable a bash-it component (plugin, component, alias)"
    group "bash-it:core"

    ! __check-function-parameters "$1" && printf "%s\n" "Please enter a valid component to enable" && return 1

    local type component load_priority

    # Make sure the component is pluralized in case this function is called directly e.g., for unit tests
    type=$(_bash-it-pluralize-component "$1")
    type_singular=$(_bash-it-singularize-component "$1")
    _load_priority="BASH_IT_LOAD_PRIORITY_DEFAULT_${type^^}"
    component="$2"
    load_priority="${!_load_priority}"

    # Capture if the user prompted for a disable all and iterate on all components
    if [[ "$type" = "alls" ]] && [[ -z "$component"  ]]; then
      _read_input "This will enable all bash-it components (aliases, plugins and completions). Are you sure you want to proceed? [yY/nN]"
      if [[ $REPLY =~ ^[yY]$ ]]; then
        for file_type in "aliases" "plugins" "completions"; do
          _bash-it-enable "$file_type" "all"
        done
      fi
      return
    fi

    [[ -z "$component" ]] && printf "${RED}%s${NC}\n" "Please enter a valid $type_singular(s) to enable" && return 1

    if [[ "$component" = "all" ]]; then
        local _component
        for _component in "${BASH_IT}/components/$type/"*.bash
        do
          _bash-it-enable "$type" "$(basename "$_component" ."$type".bash)"
        done
    else
        local _component

        _component=$(command ls "${BASH_IT}/components/$type/$component".*bash 2>/dev/null | head -1)

        [[ -z "$_component" ]] && printf "${CYAN}$component ${RED}%s ${GREEN}$type_singular${NC}\n" "does not appear to be an available" && return 1
        _component=$(basename "$_component")

        local enabled_component

        enabled_component=$(command compgen -G "${BASH_IT}/components/enabled/[0-9][0-9][0-9]$BASH_IT_LOAD_PRIORITY_SEPARATOR$_component" 2>/dev/null | head -1)
        if [[ -n "$enabled_component" ]] ; then
          printf "${GREEN}$type_singular ${CYAN}$component${NC} %s\n" "is already enabled"
          return
        fi

        mkdir -p "${BASH_IT}/components/enabled"

        # Load the priority from the file if it present there
        declare local_file_priority use_load_priority
        local_file_priority=$(grep -E "^# BASH_IT_LOAD_PRIORITY:" "${BASH_IT}/components/$type/$_component" | awk -F': ' '{ print $2 }')
        use_load_priority=${local_file_priority:-$load_priority}

        ln -s "${BASH_IT}"/components/"$type"/"$_component" "${BASH_IT}/components/enabled/${use_load_priority}${BASH_IT_LOAD_PRIORITY_SEPARATOR}${_component}"
    fi

    _bash-it-component-cache-clean "${type}"

    printf "${GREEN}%s $type_singular: ${CYAN}$component${NC} %s ${RED}$use_load_priority${NC}\n" "◉" "enabled with priority"

    if [[ -n "$BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE" ]]; then
      _bash-it-reload
    fi
}
