#!/usr/bin/env bash

BASH_IT_LOAD_PRIORITY_DEFAULT_ALIASES=${BASH_IT_LOAD_PRIORITY_DEFAULT_ALIASES:-150}
BASH_IT_LOAD_PRIORITY_DEFAULT_PLUGINS=${BASH_IT_LOAD_PRIORITY_DEFAULT_PLUGINS:-250}
BASH_IT_LOAD_PRIORITY_DEFAULT_COMPLETIONS=${BASH_IT_LOAD_PRIORITY_DEFAULT_COMPLETIONS:-350}

# @function     _bash-it-enable
# @description  Enables a component
#
# @param $1     component type: bash-it component of type aliases, plugins, completions
# @param $2     component name: bash-it component name .e.g., base, git
# @return       A message to indicate the outcome
_bash-it-enable () {
    about "enable a bash-it component (plugin, component, alias)"
    group "bash-it:core"

    local type component load_priority

    # Make sure the component is pluarised in case this function is called directly e.g., for unit tests
    type=$(_bash-it-pluralize-component "$1")
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

    [[ -z "$component" ]] && echo "${RED}Please enter a valid $(_bash-it-singularize-component "$type")(s) to enable${NC}" && return

    if [[ "$component" = "all" ]]; then
        local _component
        for _component in "${BASH_IT}/$type/available/"*.bash
        do
          _bash-it-enable "$type" "$(basename "$_component" ."$type".bash)"
        done
    else
        local _component

        _component=$(command ls "${BASH_IT}/$type/available/$component".*bash 2>/dev/null | head -1)
        if [[ -z "$_component" ]]; then
            printf "${GREEN}%s ${NC}${RED}%s${NC}\n" "$component" "does not appear to be an available $(_bash-it-singularize-component "$type")"
            return
        fi
        _component=$(basename "$_component")
        local enabled_component
        enabled_component=$(command compgen -G "${BASH_IT}/enabled/[0-9][0-9][0-9]$BASH_IT_LOAD_PRIORITY_SEPARATOR$_component" 2>/dev/null | head -1)
        if [[ -n "$enabled_component" ]] ; then
          printf "${GREEN}%s${NC}\n" "$component is already enabled"
          return
        fi

        mkdir -p "${BASH_IT}/enabled"

        # Load the priority from the file if it present there
        declare local_file_priority use_load_priority
        local_file_priority=$(grep -E "^# BASH_IT_LOAD_PRIORITY:" "${BASH_IT}/$type/available/$_component" | awk -F': ' '{ print $2 }')
        use_load_priority=${local_file_priority:-$load_priority}

        ln -s ../"$type"/available/"$_component" "${BASH_IT}/enabled/${use_load_priority}${BASH_IT_LOAD_PRIORITY_SEPARATOR}${_component}"
    fi

    _bash-it-clean-component-cache "${type}"

    printf "${GREEN}%s${NC} %s %s${RED} (%s)${NC}\n" "[● ENABLED]" "$type: $component" "enabled with priority" "$use_load_priority"

    if [[ -n "$BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE" ]]; then
      _bash-it-reload
    fi
}
