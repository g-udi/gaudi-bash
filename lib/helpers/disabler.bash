#!/usr/bin/env bash

_on-disable-callback () {
    about 'Calls the disabled plugin destructor, if present'
    param '1: plugin name'
    example '$ _on-disable-callback gitstatus'
    group 'lib'

    callback=$1_on_disable
    _command_exists $callback && $callback
}

_disable-plugin () {
    about 'disables bash_it plugin'
    param '1: plugin name'
    example '$ disable-plugin rvm'
    group 'lib'

    _disable-thing "plugins" "plugin" $1
    _on-disable-callback $1
}

_disable-alias () {
    about 'disables bash_it alias'
    param '1: alias name'
    example '$ disable-alias git'
    group 'lib'

    _disable-thing "aliases" "alias" $1
}

_disable-completion () {
    about 'disables bash_it completion'
    param '1: completion name'
    example '$ disable-completion git'
    group 'lib'

    _disable-thing "completions" "completion" $1
}

_disable-thing () {
    about 'disables a bash_it component'
    param '1: subdirectory'
    param '2: file_type'
    param '3: file_entity'
    example '$ _disable-thing "plugins" "plugin" "ssh"'

    subdirectory="$1"
    file_type="$2"
    file_entity="$3"

    if [[ -z "$file_entity" ]]; then
        reference "disable-$file_type"
        return
    fi

    local f suffix
    suffix=$(echo "$subdirectory" | sed -e 's/plugins/plugin/g')

    if [[ "$file_entity" = "all" ]]; then
        # Disable everything that's using the old structure
        for f in `compgen -G "${BASH_IT}/$subdirectory/enabled/*.${suffix}.bash"`
        do
          rm "$f"
        done

        # Disable everything in the global "enabled" directory
        for f in `compgen -G "${BASH_IT}/enabled/*.${suffix}.bash"`
        do
          rm "$f"
        done
    else
        local plugin_global
        plugin_global=$(command ls $ "${BASH_IT}/enabled/"[0-9]*$BASH_IT_LOAD_PRIORITY_SEPARATOR$file_entity.$suffix.bash 2>/dev/null | head -1)
        if [[ -z "$plugin_global" ]]; then
          # Use a glob to search for both possible patterns
          local plugin
          plugin=$(command ls $ "${BASH_IT}/$subdirectory/enabled/"{[0-9]*$BASH_IT_LOAD_PRIORITY_SEPARATOR$file_entity.$suffix.bash,$file_entity.$suffix.bash} 2>/dev/null | head -1)
          if [[ -z "$plugin" ]]; then
              printf '%s\n' "sorry, $file_entity does not appear to be an enabled $file_type."
              return
          fi
          rm "${BASH_IT}/$subdirectory/enabled/$(basename $plugin)"
        else
          rm "${BASH_IT}/enabled/$(basename $plugin_global)"
        fi
    fi

    _bash-it-clean-component-cache "${file_type}"

    if [[ -n "$BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE" ]]; then
      _bash-it-reload
    fi

    printf "${RED}%s${NC} %s\n" "[◯ DISABLED]" "$subdirectory: $file_entity"
}
