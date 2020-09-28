cite about-alias
about-alias 'fuck/please to retry last command with sudo'

if ! _command_exists fuck ; then
    alias fuck='sudo $(fc -ln -1)'
fi
alias please=fuck
alias plz=please
alias fucking=sudo

