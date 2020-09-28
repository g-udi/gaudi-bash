cite about-alias
about-alias 'ls aliases to add coloring and extra arguments'

if ls -G -d . &> /dev/null
then
  alias ls="ls -G=auto"
elif ls -G -d . &> /dev/null
then
  alias ls='ls -G'
fi

# Always use color output for `ls`
alias ls="command ls -G"
# List all files colorized in long format
alias ll="ls -lFG"
# List all files colorized in long format, including dot files
alias la="ls -laFG"
# List only directories
alias lsd="ls -lFG | grep -G=never '^d'"
alias l='ls -a'
alias l1='ls -1'
alias llt="ls -lFtG"
