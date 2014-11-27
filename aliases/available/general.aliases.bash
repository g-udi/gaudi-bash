cite about-alias
about-alias 'general aliases'

# List directory contents
alias sl=ls
# List all files colorized in long format
alias ll="ls -lF ${colorflag}"
# List all files colorized in long format, including dot files
alias la="ls -laF ${colorflag}"
# List only directories
alias lsd="ls -lF ${colorflag} | grep --color=never '^d'"
# Always use color output for `ls`
alias ls="command ls ${colorflag}"
alias l='ls -a'
alias l1='ls -1'

alias _="sudo"
# Enable aliases to be sudo’ed
alias sudo='sudo '
# Get week number
alias week='date +%V'

alias c='clear'
alias cls='clear'

alias edit="$EDITOR"
alias pager="$PAGER"
alias q='exit'
alias irc="$IRC_CLIENT"
alias rb='ruby'
alias screenshot='webkit2png'

# Pianobar can be found here: http://github.com/PromyLOPh/pianobar/
alias piano='pianobar'

# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~" # `cd` is probably faster to type though
alias -- -="cd -"

# Shell History
alias h='history'

# Tree
if [ ! -x "$(which tree 2>/dev/null)" ]
then
  alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
fi

# Directory
alias	md='mkdir -p'
alias	rd='rmdir'

which gshuf &> /dev/null
if [ $? -eq 0 ]
then
  alias shuf=gshuf
fi
