#!/usr/bin/env bash
# shellcheck disable=SC1090

BASH_IT_LOAD_PRIORITY_SEPARATOR="-"

# support 'plumbing' metadata
cite _about _param _example _group _author _version

# Load all the helper libraries
for helper in ${BASH_IT}/lib/helpers/*.bash; do source $helper; done

_bash-it-aliases () {
    _about 'summarizes available bash_it aliases'
    _group 'lib'

    _bash-it-describe "aliases" "an" "alias" "Alias"
}

_bash-it-completions () {
    _about 'summarizes available bash_it completions'
    _group 'lib'

    _bash-it-describe "completion" "a" "completion" "Completion"
}

_bash-it-plugins () {
    _about 'summarizes available bash_it plugins'
    _group 'lib'

    _bash-it-describe "plugins" "a" "plugin" "Plugin"
}

_bash-it_update() {
  _about 'updates bash-it'
  _group 'lib'

  local old_pwd="${PWD}"

  cd "${BASH_IT}" || return

  if [ -z $BASH_IT_REMOTE ]; then
    BASH_IT_REMOTE="origin"
  fi

  git fetch &> /dev/null

  declare status
  status="$(git rev-list master..${BASH_IT_REMOTE}/master 2> /dev/null)"

  if [[ -n "${status}" ]]; then

    for i in $(git rev-list --merges --first-parent master..${BASH_IT_REMOTE}); do
      num_of_lines=$(git log -1 --format=%B $i | awk 'NF' | wc -l)
      if [ $num_of_lines -eq 1 ]; then
        description="%s"
      else
        description="%b"
      fi
      git log --format="%h: $description (%an)" -1 $i
    done
    echo ""
    read -e -n 1 -p "Would you like to update to $(git log -1 --format=%h origin/master)? [Y/n] " RESP
    case $RESP in
      [yY]|"")
        git pull --rebase &> /dev/null
        if [[ $? -eq 0 ]]; then
          echo "bash-it successfully updated."
          echo ""
          echo "Migrating your installation to the latest version now..."
          _bash-it-migrate
          echo ""
          echo "All done, enjoy!"
          bash-it reload
        else
          echo "Error updating bash-it, please, check if your bash-it installation folder (${BASH_IT}) is clean."
        fi
        ;;
      [nN])
        echo "Not upgrading…"
        ;;
      *)
        echo -e "\033[91mPlease choose y or n.\033[m"
        ;;
      esac
  else
    echo "bash-it is up to date, nothing to do!"
  fi
  cd "${old_pwd}" &> /dev/null || return
}

_bash-it-migrate() {
  _about 'migrates bash-it configuration from a previous format to the current one'
  _group 'lib'

  declare migrated_something
  migrated_something=false

  for file_type in "aliases" "plugins" "completion"
  do
    for f in `sort <(compgen -G "${BASH_IT}/$file_type/enabled/*.bash")`
    do
      typeset ff=$(basename $f)

      # Get the type of component from the extension
      typeset single_type=$(echo $ff | sed -e 's/.*\.\(.*\)\.bash/\1/g' | sed 's/aliases/alias/g')
      # Cut off the optional "250---" prefix and the suffix
      typeset component_name=$(echo $ff | sed -e 's/[0-9]*[-]*\(.*\)\..*\.bash/\1/g')

      migrated_something=true

      echo "Migrating $single_type $component_name."

      disable_func="_disable-$single_type"
      enable_func="_enable-$single_type"

      $disable_func $component_name
      $enable_func $component_name
    done
  done

  if [ "$migrated_something" = "true" ]; then
    echo ""
    echo "If any migration errors were reported, please try the following: reload && bash-it migrate"
  fi
}

_bash-it-version() {
  _about 'shows current bash-it version'
  _group 'lib'

  cd "${BASH_IT}" || return

  if [ -z $BASH_IT_REMOTE ]; then
    BASH_IT_REMOTE="origin"
  fi

  BASH_IT_GIT_REMOTE=$(git remote get-url $BASH_IT_REMOTE)
  BASH_IT_GIT_URL=${BASH_IT_GIT_REMOTE%.git}

  BASH_IT_GIT_VERSION_INFO="$(git log --pretty=format:'%h on %aI' -n 1)"
  BASH_IT_GIT_SHA=${BASH_IT_GIT_VERSION_INFO%% *}

  echo "Current git SHA: ${GREEN}$BASH_IT_GIT_VERSION_INFO${NC}"
  echo "${MAGENTA}$BASH_IT_GIT_URL/commit/$BASH_IT_GIT_SHA${NC}"
  echo "Compare to latest: ${YELLOW}$BASH_IT_GIT_URL/compare/$BASH_IT_GIT_SHA...master${NC}"

  cd - &> /dev/null || return
}

_bash-it-reload() {
  _about 'reloads a profile file'
  _group 'lib'

  pushd "${BASH_IT}" &> /dev/null || return

  case $OSTYPE in
    darwin*)
      source ~/.bash_profile
      ;;
    *)
      source ~/.bashrc
      ;;
  esac

  popd &> /dev/null || return
}

_bash-it-describe () {
    _about 'summarizes available bash_it components'
    _param '1: subdirectory'
    _param '2: preposition'
    _param '3: file_type'
    _param '4: column_header'
    _example '$ _bash-it-describe "plugins" "a" "plugin" "Plugin"'

    subdirectory="$1"
    preposition="$2"
    file_type="$3"
    column_header="$4"

    typeset f
    typeset enabled
    printf "%-20s%-10s%s\n" "$column_header" 'Enabled?' 'Description'
    for f in "${BASH_IT}/$subdirectory/available/"*.bash
    do
        # Check for both the old format without the load priority, and the extended format with the priority
        declare enabled_files enabled_file
        enabled_file=$(basename $f)
        enabled_files=$(sort <(compgen -G "${BASH_IT}/enabled/*$BASH_IT_LOAD_PRIORITY_SEPARATOR${enabled_file}") <(compgen -G "${BASH_IT}/$subdirectory/enabled/${enabled_file}") <(compgen -G "${BASH_IT}/$subdirectory/enabled/*$BASH_IT_LOAD_PRIORITY_SEPARATOR${enabled_file}") | wc -l)

        if [ $enabled_files -gt 0 ]; then
            enabled='x'
        else
            enabled=' '
        fi
        printf "%-20s%-10s%s\n" "$(basename $f | sed -e 's/\(.*\)\..*\.bash/\1/g')" "  [$enabled]" "$(cat $f | metafor about-$file_type)"
    done
    printf '\n%s\n' "to enable $preposition $file_type, do:"
    printf '%s\n' "$ bash-it enable $file_type  <$file_type name> [$file_type name]... -or- $ bash-it enable $file_type all"
    printf '\n%s\n' "to disable $preposition $file_type, do:"
    printf '%s\n' "$ bash-it disable $file_type <$file_type name> [$file_type name]... -or- $ bash-it disable $file_type all"
}

all_groups () {
    about 'displays all unique metadata groups'
    group 'lib'

    typeset func
    typeset file=$(mktemp -t composure.XXXX)
    for func in $(_typeset_functions)
    do
        typeset -f $func | metafor group >> $file
    done
    cat $file | sort | uniq
    rm $file
}

if ! type pathmunge > /dev/null 2>&1
then
  function pathmunge () {
    about 'prevent duplicate directories in you PATH variable'
    group 'helpers'
    example 'pathmunge /path/to/dir is equivalent to PATH=/path/to/dir:$PATH'
    example 'pathmunge /path/to/dir after is equivalent to PATH=$PATH:/path/to/dir'

    if ! [[ $PATH =~ (^|:)$1($|:) ]] ; then
      if [ "$2" = "after" ] ; then
        export PATH=$PATH:$1
      else
        export PATH=$1:$PATH
      fi
    fi
  }
fi

bash-it () {
    about 'bash-it help and maintenance'
    param '1: verb [one of: help | show | enable | disable | migrate | update | search | version | reload | doctor ] '
    param '2: component type [one of: alias(es) | completion(s) | plugin(s) ] or search term(s)'
    param '3: specific component [optional]'
    example '$ bash-it show plugins'
    example '$ bash-it help aliases'
    example '$ bash-it enable plugin git [tmux]...'
    example '$ bash-it disable alias hg [tmux]...'
    example '$ bash-it migrate'
    example '$ bash-it update'
    example '$ bash-it search [-|@]term1 [-|@]term2 ... [ -e/--enable ] [ -d/--disable ] [ -r/--refresh ] [ -c/--no-color ]'
    example '$ bash-it version'
    example '$ bash-it reload'
    example '$ bash-it doctor errors|warnings|all'
    typeset verb=${1:-}
    shift
    typeset component=${1:-}
    shift
    typeset func

    case $verb in
      show)
        func=_bash-it-$component;;
      enable)
        func=_enable-$component;;
      disable)
        func=_disable-$component;;
      help)
        func=_help-$component;;
      doctor)
        func=_bash-it-doctor-$component;;
      search)
        _bash-it-search $component "$@"
        return;;
      update)
        func=_bash-it_update;;
      migrate)
        func=_bash-it-migrate;;
      version)
        func=_bash-it-version;;
      reload)
        func=_bash-it-reload;;
      *)
        reference bash-it
        return;;
    esac

    # pluralize component if necessary
    if ! _is_function $func; then
        if _is_function ${func}s; then
            func=${func}s
        else
            if _is_function ${func}es; then
                func=${func}es
            else
                echo "oops! $component is not a valid option!"
                reference bash-it
                return
            fi
        fi
    fi

    if [ x"$verb" == x"enable" ] || [ x"$verb" == x"disable" ]; then
        # Automatically run a migration if required
        _bash-it-migrate

        for arg in "$@"
        do
            $func $arg
        done
    else
        $func "$@"
    fi
}
