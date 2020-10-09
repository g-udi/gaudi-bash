#!/usr/bin/env bash

# @function     _help-completions
# @description  summarize all completions available in bash-it
# @return       returns the table of available completions, their status(enabled/disabled) and description
# @example      ❯ _help-completions
_help-completions () {
  about 'summarize all completions available in bash-it'
  group 'bash-it:core:help'

  _bash-it-show completions
}

_help-aliases () {
    about 'shows help for all aliases, or a specific alias group'
    group 'bash-it:core:help'

    __help-list-aliases () {
      local file

      file=$(basename "$1" | sed -e 's/[0-9]*[-]*\(.*\)\.aliases\.bash/\1/g')
      printf '\n\n%s:\n' "${file}"
      "$1" | metafor about | sed "s/$/'/"
    }

      local __file

      for __file in $(sort <(compgen -G "${BASH_IT}/components/aliases/enabled/*") <(compgen -G "${BASH_IT}/components/enabled/*.aliases.bash"))
      do
          __help-list-aliases "$__file"
      done

      if [[ -e "${BASH_IT}/components/aliases/custom.aliases.bash" ]]; then
        __help-list-aliases "${BASH_IT}/components/aliases/custom.aliases.bash"
      fi

    # if [[ -n "$1" ]]; then
    #     case $1 in
    #         custom)
    #             alias_path='custom/custom.aliases.bash'
    #         ;;
    #         *)
    #             alias_path="aliases/$1.aliases.bash"
    #         ;;
    #     esac
    #     "${BASH_IT}/components/$alias_path" | metafor about | sed "s/$/'/"
    # else
    #     local __file

    #     for __file in $(sort <(compgen -G "${BASH_IT}/components/aliases/enabled/*") <(compgen -G "${BASH_IT}/components/enabled/*.aliases.bash"))

    #     do
    #     echo "file: $file"
    #         __help-list-aliases "$__file"
    #     done

    #     if [[ -e "${BASH_IT}/aliases/custom.aliases.bash" ]]; then
    #       __help-list-aliases "${BASH_IT}/aliases/custom.aliases.bash"
    #     fi
    # fi
}

# @function     _help-plugins
# @description  summarize all functions defined by enabled bash-it plugins
# @param $1     mode: help mode to decide what to show (default: show help for enabled plugins only)
#                 - all: show all help functions that has valid composure about and group (including bash-it core functions)
# @return       returns the list of function names and their descriptions
# @example      ❯ _help-plugins
#               ❯ _help-plugins all
_help-plugins () {
    about 'summarize all functions defined by enabled bash-it plugins'
    group 'bash-it:core:help'

    # Overrides the composure default letterpress function to allow for custom column width setting for plugins help
    __letterpress () {
      typeset rightcol="$1" leftcol="${2:- }" leftwidth="${10:-45}"

      if [ -z "$rightcol" ]; then
        return
      fi
      printf "%-*s%s\n" "$leftwidth" "$leftcol" "$rightcol"
    }

    printf "${GREEN}%s${NC}" "please wait, building help..."
    local grouplist func

    grouplist=$(mktemp -t grouplist.XXXXXX)
    for func in $(_typeset_functions)
    do
        local group
        group="$(local -f "$func" | metafor group)"
        # Make sure only to include items with a valid group
        if [[ -n "$group" ]]; then
          local about

          if [[ $1 != "all" ]] && [[ "$group" =~ "bash-it" ]]; then
            continue
          fi

          about="$(local -f "$func" | metafor about)"
          __letterpress "$about" "$func" >> "$grouplist".$group
          echo "$grouplist".$group >> "$grouplist"

        fi
    done

    local group gfile
    for gfile in $(cat "$grouplist" | sort | uniq)
    do
        printf '%s\n' "${gfile##*.}"
        printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
        cat "$gfile"
        printf '\n'
        rm "$gfile" 2> /dev/null
    done | less
    rm "$grouplist" 2> /dev/null
}
