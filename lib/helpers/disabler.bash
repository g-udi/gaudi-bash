#!/usr/bin/env bash

_on-disable-callback() {
    _about 'Calls the disabled plugin destructor, if present'
    _param '1: plugin name'
    _example '$ _on-disable-callback gitstatus'
    _group 'lib'

    callback=$1_on_disable
    _command_exists $callback && $callback
}

_disable-plugin () {
    _about 'disables bash_it plugin'
    _param '1: plugin name'
    _example '$ disable-plugin rvm'
    _group 'lib'

    _disable-thing "plugins" "plugin" $1
    _on-disable-callback $1
}

_disable-alias () {
    _about 'disables bash_it alias'
    _param '1: alias name'
    _example '$ disable-alias git'
    _group 'lib'

    _disable-thing "aliases" "alias" $1
}

_disable-completion () {
    _about 'disables bash_it completion'
    _param '1: completion name'
    _example '$ disable-completion git'
    _group 'lib'

    _disable-thing "completion" "completion" $1
}

_disable-thing () {
    _about 'disables a bash_it component'
    _param '1: subdirectory'
    _param '2: file_type'
    _param '3: file_entity'
    _example '$ _disable-thing "plugins" "plugin" "ssh"'

    subdirectory="$1"
    file_type="$2"
    file_entity="$3"

    if [ -z "$file_entity" ]; then
        reference "disable-$file_type"
        return
    fi

    typeset f suffix
    suffix=$(echo "$subdirectory" | sed -e 's/plugins/plugin/g')

    if [ "$file_entity" = "all" ]; then
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
        typeset plugin_global=$(command ls $ "${BASH_IT}/enabled/"[0-9]*$BASH_IT_LOAD_PRIORITY_SEPARATOR$file_entity.$suffix.bash 2>/dev/null | head -1)
        if [ -z "$plugin_global" ]; then
          # Use a glob to search for both possible patterns
          typeset plugin=$(command ls $ "${BASH_IT}/$subdirectory/enabled/"{[0-9]*$BASH_IT_LOAD_PRIORITY_SEPARATOR$file_entity.$suffix.bash,$file_entity.$suffix.bash} 2>/dev/null | head -1)
          if [ -z "$plugin" ]; then
              printf '%s\n' "sorry, $file_entity does not appear to be an enabled $file_type."
              return
          fi
          rm "${BASH_IT}/$subdirectory/enabled/$(basename $plugin)"
        else
          rm "${BASH_IT}/enabled/$(basename $plugin_global)"
        fi
    fi

    _bash-it-clean-component-cache "${file_type}"

    if [ -n "$BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE" ]; then
      _bash-it-reload
    fi

    printf '%s\n' "$file_entity disabled."
}
