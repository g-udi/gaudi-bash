#!/usr/bin/env bash

BASH_IT_LOAD_PRIORITY_DEFAULT_ALIAS=${BASH_IT_LOAD_PRIORITY_DEFAULT_ALIAS:-150}
BASH_IT_LOAD_PRIORITY_DEFAULT_PLUGIN=${BASH_IT_LOAD_PRIORITY_DEFAULT_PLUGIN:-250}
BASH_IT_LOAD_PRIORITY_DEFAULT_COMPLETION=${BASH_IT_LOAD_PRIORITY_DEFAULT_COMPLETION:-350}

_enable-plugin () {
    about 'enables bash_it plugin'
    param '1: plugin name'
    example '$ enable-plugin rvm'
    group 'lib'

    _enable-thing "plugins" "plugin" $1 $BASH_IT_LOAD_PRIORITY_DEFAULT_PLUGIN
}

_enable-alias () {
    about 'enables bash_it alias'
    param '1: alias name'
    example '$ enable-alias git'
    group 'lib'

    _enable-thing "aliases" "alias" $1 $BASH_IT_LOAD_PRIORITY_DEFAULT_ALIAS
}

_enable-completion () {
    about 'enables bash_it completion'
    param '1: completion name'
    example '$ enable-completion git'
    group 'lib'

    _enable-thing "completions" "completion" $1 $BASH_IT_LOAD_PRIORITY_DEFAULT_COMPLETION
}

_enable-thing () {
    cite about param example
    about 'enables a bash_it component'
    param '1: subdirectory'
    param '2: file_type'
    param '3: file_entity'
    param '4: load priority'
    example '$ _enable-thing "plugins" "plugin" "ssh" "150"'

    subdirectory="$1"
    file_type="$2"
    file_entity="$3"
    load_priority="$4"

    if [[ -z "$file_entity" ]]; then
        reference "enable-$file_type"
        return
    fi

    if [[ "$file_entity" = "all" ]]; then
        local f $file_type
        for f in "${BASH_IT}/$subdirectory/available/"*.bash
        do
            to_enable=$(basename $f .$file_type.bash)
            if [[ "$file_type" = "alias" ]]; then
              to_enable=$(basename $f ".aliases.bash")
            fi
            _enable-thing $subdirectory $file_type $to_enable $load_priority
        done
    else
        local to_enable
        to_enable=$(command ls "${BASH_IT}/$subdirectory/available/"$file_entity.*bash 2>/dev/null | head -1)
        if [[ -z "$to_enable" ]]; then
            printf '%s\n' "sorry, $file_entity does not appear to be an available $file_type."
            return
        fi

        to_enable=$(basename $to_enable)
        # Check for existence of the file using a wildcard, since we don't know which priority might have been used when enabling it.
        local enabled_plugin
        enabled_plugin=$(command ls "${BASH_IT}/$subdirectory/enabled/"{[0-9][0-9][0-9]$BASH_IT_LOAD_PRIORITY_SEPARATOR$to_enable,$to_enable} 2>/dev/null | head -1)
        if [[ ! -z "$enabled_plugin" ]] ; then
          printf '%s\n' "$file_entity is already enabled."
          return
        fi

        local enabled_plugin_global
        enabled_plugin_global=$(command compgen -G "${BASH_IT}/enabled/[0-9][0-9][0-9]$BASH_IT_LOAD_PRIORITY_SEPARATOR$to_enable" 2>/dev/null | head -1)
        if [[ ! -z "$enabled_plugin_global" ]] ; then
          printf '%s\n' "$file_entity is already enabled."
          return
        fi

        mkdir -p "${BASH_IT}/enabled"

        # Load the priority from the file if it present there
        declare local_file_priority use_load_priority
        local_file_priority=$(grep -E "^# BASH_IT_LOAD_PRIORITY:" "${BASH_IT}/$subdirectory/available/$to_enable" | awk -F': ' '{ print $2 }')
        use_load_priority=${local_file_priority:-$load_priority}

        ln -s ../$subdirectory/available/$to_enable "${BASH_IT}/enabled/${use_load_priority}${BASH_IT_LOAD_PRIORITY_SEPARATOR}${to_enable}"
    fi

    _bash-it-clean-component-cache "${file_type}"

    if [[ -n "$BASH_IT_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE" ]]; then
      _bash-it-reload
    fi

    printf "${GREEN}%s${NC} %s %s${RED} (%s)${NC}\n" "[● ENABLED]" "$subdirectory: $file_entity" "enabled with priority" "$use_load_priority"
}
