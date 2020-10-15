#!/usr/bin/env bash
# shellcheck disable=SC1090,SC2034,SC2001

export BASH_IT_LOAD_PRIORITY_SEPARATOR="___"

# Load all the helper libraries
for helper in "${BASH_IT}"/lib/helpers/*.bash; do source "$helper"; done

# @function     _bash-it-update
# @description  updates the bash-it installation by fetching latest code from the remote git
#               will prompt the user to accept pulling the updates by showing the latest commit log
# @return       status message to indicate the outcome
#               remote update success: bash-it successfully updated!
#               remote update fail: bash-it is up to date, nothing to do!
#               remote update error: Error updating bash-it, please, check if your bash-it installation folder (${BASH_IT}) is clean
#               user skip: Skipping upgrade
_bash-it-update () {

  about "Updates the bash-it installation by fetching latest code from the remote git"
  group "bash-it:core"

  local old_pwd="${PWD}"

  cd "${BASH_IT}" || return

  if [[ -z $BASH_IT_REMOTE ]]; then
    BASH_IT_REMOTE="origin"
  fi

  git fetch &> /dev/null

  declare status
  status="$(git rev-list master..${BASH_IT_REMOTE}/master 2> /dev/null)"

  if [[ -n "${status}" ]]; then

    for i in $(git rev-list --merges --first-parent master..${BASH_IT_REMOTE}); do
      num_of_lines=$(git log -1 --format=%B "$i" | awk 'NF' | wc -l)
      if [[ $num_of_lines -eq 1 ]]; then
        description="%s"
      else
        description="%b"
      fi
      git log --format="%h: $description (%an)" -1 "$i"
    done

    _read_input "Would you like to update to $(git log -1 --format=%h origin/master) - $(git log -1 --format=%B origin/master)? [Y/n]"
    if [[ $REPLY =~ ^[yY]$ ]]; then
      git pull --rebase &> /dev/null
      if [[ $? -eq 0 ]]; then
        printf "${GREEN}%s${NC}\n" "bash-it successfully updated!"
        bash-it reload
      else
        printf "${RED}%s${NC}\n" "Error updating bash-it, please, check if your bash-it installation folder (${BASH_IT}) is clean"
      fi
    else
      printf "${YELLOW}%s${NC}\n" "Skipping upgrade :("
    fi
  else
    echo "bash-it is up to date, nothing to do!"
  fi

  if [[ "$*" = "all" ]]; then
    echo "checking bash-it dependencies"
    cd "${BASH_IT}/components" && git submodule update --recursive --remote
  fi

  cd "${old_pwd}" &> /dev/null || return
}

# @function     _bash-it-version
# @description  prints the bash-it version
#               shows current git SHA, commit hash and the remote that was compared against
# @return       current git SHA e.g., Current git SHA: 47d1e26 on 2020-10-01T17:50:08-07:00
#               last git commit link e.g., git@github.com:ahmadassaf/bash-it/commit/47d1e26
#               latest remote e.g., Compare to latest: git@github.com:ahmadassaf/bash-it/compare/47d1e26...master
_bash-it-version () {
  about "Shows current bash-it version with the Current git SHA and commit hash"
  group "bash-it:core"

  cd "${BASH_IT}" || return

  if [[ -z $BASH_IT_REMOTE ]]; then
    BASH_IT_REMOTE="origin"
  fi

  BASH_IT_GIT_REMOTE=$(git remote get-url $BASH_IT_REMOTE)
  BASH_IT_GIT_URL=${BASH_IT_GIT_REMOTE%.git}

  BASH_IT_GIT_VERSION_INFO="$(git log --pretty=format:'%h on %aI' -n 1)"
  BASH_IT_GIT_SHA=${BASH_IT_GIT_VERSION_INFO%% *}

  echo -e "Current git SHA: ${GREEN}$BASH_IT_GIT_VERSION_INFO${NC}"
  echo -e "${MAGENTA}$BASH_IT_GIT_URL/commit/$BASH_IT_GIT_SHA${NC}"
  echo -e "Compare to latest: ${YELLOW}$BASH_IT_GIT_URL/compare/$BASH_IT_GIT_SHA...master${NC}"

  cd - &> /dev/null || return
}

# @function     _bash-it-reload
# @description  reloads the bash profile
#               reloads the profile that corresponds to the correct OS type (.bashrc, .bash_profile)
_bash-it-reload () {
  about "Reloads the bash profile that corresponds to the correct OS type (.bashrc, .bash_profile)"
  group "bash-it:core"

  pushd "${BASH_IT}" &> /dev/null || return

  case $OSTYPE in
    darwin*)
      source "$HOME/.bash_profile"
      ;;
    *)
      source "$HOME/.bashrc"
      ;;
  esac

  popd &> /dev/null || return
}

# @function     _bash-it-help
# @description  shows help command of a component (alias, plugin, completion)
# @param $1     type: component type of: aliases, plugins, completions
# @param $2     component: component name to show help for
# @return       help list for each component
#               completions: show list of completion components in the bash-it show table
#               aliases: show list of aliases in either 1) all enabled aliases if no alias was passed or 2) a specific alias
#               plugins: show function descriptions of either 1) all enabled plugins if no plugin was passed or 2) a specific plugin
_bash-it-help () {
  ! __check-function-parameters "$1" && reference bash-it && return 0

  local type component

  type="$(_bash-it-pluralize-component "$1")"
  _command_exists _help-"${type}" && _help-"${type}" "$2"
}

# @function     _bash-it-show
# @description  shows a list of all items of a component (alias, plugin, completion)
#               if no param was passed, shows all enabled components across.
#               components descriptions are retrieved via the composure metadata 'about'
# @param $1     type: component type of: aliases, plugins, completions
# @param $2     mode <enabled, all>: either show all available components or filter only for enabled ones
# @return       table showing each component name, status (enabled/disabled) and description
_bash-it-show () {
  about "List available bash_it components or allow filtering for a specific type e.g., plugins, aliases, completions"
  group "bash-it:core"

  if [[ -n "$1" ]]; then
    _bash-it-describe "$1" "$2"
  else
    for file_type in "aliases" "plugins" "completions"; do
      _bash-it-describe "$file_type" "enabled"
    done
  fi
}

# @function     _bash-it-backup
# @description  backs up enabled components (plugins, aliases, completions)
#               the function writes "enable" commands into a file in $BASH_IT/tmp/enabled.bash-it.backup
# @return       $BASH_IT/tmp/enabled.bash-it.backup file with 'bash-it enable' commands
_bash-it-backup () {
  about "backs up enabled components (plugins, aliases, completions)"
  group "bash-it:core"

  # Clear out the existing backup file
  echo -n "" > "${BASH_IT}/tmp/enabled.bash-it.backup"

  for _file in "${BASH_IT}"/components/enabled/*.bash; do
    local _component _type

    _component="$(echo "$_file" | sed -e "s/.*$BASH_IT_LOAD_PRIORITY_SEPARATOR\(.*\).bash.*/\1/")"
    _type=$(_bash-it-singularize-component "${_component##*.}")
    _component=${_component%%.*}

    echo "Backing up $_type: ${_component}"
    printf "%s\n" "bash-it enable ${_type} ${_component}" >> "${BASH_IT}/tmp/enabled.bash-it.backup"

  done
}

# @function     _bash-it-restore
# @description  restores enabled bash-it components
#               the function gets the list of enabled commands from the backup file in $BASH_IT/tmp/enabled.bash-it.backup
# @return       status message to indicate the outcome
_bash-it-restore () {
  about "restores enabled components (plugins, aliases, completions)"
  group "bash-it:core"

  ! [[ -f "${BASH_IT}/tmp/enabled.bash-it.backup" ]] && echo -e "${RED}No valid backup file found :(${NC}" && return

  while IFS= read -r line; do
    $line
  done < "${BASH_IT}/tmp/enabled.bash-it.backup"
}


bash-it () {
    about 'provides a solid framework for using, developing and maintaining shell scripts and custom commands for your daily work'
    param '1: verb [one of: help | backup | show | enable | disable | update | restore | search | version | reload | doctor ]] '
    param '2: component type [one of: alias(es) | completion(s) | plugin(s) ]] or search term(s)'
    param '3: specific component [optional]'

    example '$ bash-it show plugins'
    example '$ bash-it help aliases'
    example '$ bash-it enable plugin git [tmux]...'
    example '$ bash-it disable alias hg [tmux]...'
    example '$ bash-it update'
    example '$ bash-it backup'
    example '$ bash-it help plugins'
    example '$ bash-it search [-|@]term1 [-|@]term2 ... [[ -e/--enable ]] [[ -d/--disable ]] [[ -r/--refresh ]] [[ -c/--no-color ]]'
    example '$ bash-it version'
    example '$ bash-it reload'
    example '$ bash-it doctor errors|warnings|all'

    local verb=${1:-}; shift
    local component=${1:-}; shift
    local func

    case $verb in
      show)
        func=_bash-it-show;;
      enable)
        func=_bash-it-enable;;
      disable)
        func=_bash-it-disable;;
      help)
        _bash-it-help "$component" "$@"
        return;;
      doctor)
        func=_bash-it-doctor;;
      update)
        _bash-it-update "$component" "$@"
        return;;
      version)
        func=_bash-it-version;;
      backup)
        func=_bash-it-backup;;
      restore)
        func=_bash-it-restore;;
      reload)
        func=_bash-it-reload;;
      search)
        _bash-it-search "$component" "$@"
        return;;
      *)
        reference bash-it
        return;;
    esac

    if [[ x"$verb" == x"enable" || x"$verb" == x"disable" ]] && [[ ${#@} != 0 ]]; then
      for arg in "$@"
      do
        $func "$(_bash-it-pluralize-component "$component")" "$arg"
      done
    else
      $func "$(_bash-it-pluralize-component "$component")" "$@"
    fi


}
