#!/usr/bin/env bash

_help-completions () {
  _about 'summarize all completions available in bash-it'
  _group 'lib'

  _bash-it-completions
}

_help-aliases () {
    _about 'shows help for all aliases, or a specific alias group'
    _param '1: optional alias group'
    _example '$ alias-help'
    _example '$ alias-help git'

    if [[ -n "$1" ]]; then
        case $1 in
            custom)
                alias_path='custom.aliases.bash'
            ;;
            *)
                alias_path="available/$1.aliases.bash"
            ;;
        esac
        cat "${BASH_IT}/aliases/$alias_path" | metafor alias | sed "s/$/'/"
    else
        local f

        for f in `sort <(compgen -G "${BASH_IT}/aliases/enabled/*") <(compgen -G "${BASH_IT}/enabled/*.aliases.bash")`
        do
            _help-list-aliases $f
        done

        if [[ -e "${BASH_IT}/aliases/custom.aliases.bash" ]]; then
          _help-list-aliases "${BASH_IT}/aliases/custom.aliases.bash"
        fi
    fi
}

_help-list-aliases () {
    local file

    file=$(basename $1 | sed -e 's/[0-9]*[-]*\(.*\)\.aliases\.bash/\1/g')
    printf '\n\n%s:\n' "${file}"
    cat $1 | metafor alias | sed "s/$/'/"
}

_help-plugins () {
    _about 'summarize all functions defined by enabled bash-it plugins'
    _group 'lib'

    printf '%s' 'please wait, building help...'
    local grouplist func

    grouplist=$(mktemp -t grouplist.XXXXXX)
    for func in $(_local_functions)
    do
        local group
        group="$(local -f $func | metafor group)"
        if [[ -z "$group" ]]; then
            group='misc'
        fi
        local about
        about="$(local -f $func | metafor about)"
        _letterpress "$about" $func >> $grouplist.$group
        echo $grouplist.$group >> $grouplist
    done

    printf '\r%s\n' '                              '
    local group gfile
    for gfile in $(cat $grouplist | sort | uniq)
    do
        printf '%s\n' "${gfile##*.}:"
        cat $gfile
        printf '\n'
        rm $gfile 2> /dev/null
    done | less
    rm $grouplist 2> /dev/null
}

_help-update () {
  _about 'help message for update command'
  _group 'lib'

  echo "Check for a new version of bash-it and update it."
}

_help-migrate () {
  _about 'help message for migrate command'
  _group 'lib'

  printf "${MAGENTA}%s${NC}\n" "Migrates internal bash-it structure to the latest version in case of changes"
  printf "${GREEN}%s${NC} %s ${GREEN}%s${NC}, ${GREEN}%s${NC} or ${GREEN}%s${NC}" "'migrate'" "command is run automatically when calling" "'update'" "'enable'" "'disable'"
}
