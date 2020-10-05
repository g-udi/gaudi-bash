#!/usr/bin/env bash

# @function     _on-disable-callback
# @description  calls the disabled plugin destructor, if present
# @param $1     component name: bash-it component name .e.g., base, git
_on-disable-callback () {
    callback=$1_on_disable
    _command_exists "$callback" && $callback
}

# @function     _bash-it-disable
# @description  disables a component
# @param $1     component type: bash-it component of type aliases, plugins, completions
# @param $2     component name: bash-it component name .e.g., base, git
# @return       message to indicate the outcome
_bash-it-disable () {
    about "disable a bash-it component (plugin, component, alias)"
    group "bash-it:core"

    local type component

    # Make sure the component is pluarised in case this function is called directly e.g., for unit tests
    type=$(_bash-it-pluralize-component "$1")
    component="$2"

    # Capture if the user prompted for a disable all and iterate on all components
    if [[ "$type" = "alls" ]] && [[ -z "$component"  ]]; then
      _read_input "This will disable all bash-it components (aliases, plugins and completions). Are you sure you want to proceed? [yY/nN]"
      if [[ $REPLY =~ ^[yY]$ ]]; then
        for file_type in "aliases" "plugins" "completions"; do
          _bash-it-disable "$file_type" "all"
        done
      fi
      return
    fi

    [[ -z "$component" ]] && echo "${RED}Please enter a valid $(_bash-it-singularize-component "$1")(s) to disable${NC}" && return

    if [[ "$component" = "all" ]]; then
      find "${BASH_IT}/enabled" -name "*.${type}.bash" -exec rm {} \;
    else
        local _component

        _component=$(command ls $ "${BASH_IT}/enabled/"[0-9]*"$BASH_IT_LOAD_PRIORITY_SEPARATOR$component.$type.bash" 2>/dev/null | head -1)
        if [[ -z "$_component" ]]; then
          printf '%s\n' "sorry, $_component does not appear to be an enabled $type"
          rm "${BASH_IT}/$type/enabled/$(basename "$_component")"
        else
          rm "${BASH_IT}/enabled/$(basename "$_component")"
        fi
    fi

    _bash-it-clean-component-cache "${type}"

    printf "${RED}%s${NC} %s\n" "[◯ DISABLED]" "$type: $component"

    [[ $type == "plugins" ]] && _on-disable-callback "$component"

    if [[ -n "$BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE" ]]; then
      _bash-it-reload
    fi
}
