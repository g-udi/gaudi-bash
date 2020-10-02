cite about-plugin
about-plugin 'virtualenvwrapper and pyenv-virtualenvwrapper helper functions'

# make sure virtualenvwrapper is enabled if available

if _command_exists pyenv; then
  pyenv virtualenvwrapper
else
  [[ `which virtualenvwrapper.sh` ]] && . virtualenvwrapper.sh
fi


mkvenv () {
  about 'create a new virtualenv for this directory'
  group 'virtualenv'

  cwd=$(basename "$(pwd)")
  mkvirtualenv --distribute $cwd
}


mkvbranch () {
  about 'create a new virtualenv for the current branch'
  group 'virtualenv'

  mkvirtualenv --distribute "$(basename "$(pwd)")@$SCM_BRANCH"
}

wovbranch () {
  about 'sets workon branch'
  group 'virtualenv'

  workon "$(basename "$(pwd)")@$SCM_BRANCH"
}

wovenv () {
  about 'works on the virtualenv for this directory'
  group 'virtualenv'

  workon "$(basename "$(pwd)")"
}
