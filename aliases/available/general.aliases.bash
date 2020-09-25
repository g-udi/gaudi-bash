cite about-alias
about-alias 'general aliases'

if ls --color -d . &> /dev/null
then
  alias ls="ls --color=auto"
elif ls -G -d . &> /dev/null
then
  alias ls='ls -G'        # Compact view, show colors
fi

# List directory contents
alias sl=ls
# List all files colorized in long format
alias ll="ls -lF --color"
# List all files colorized in long format, including dot files
alias la="ls -laF --color"
# List only directories
alias lsd="ls -lF --color | grep --color=never '^d'"
# Always use color output for `ls`
alias ls="command ls --color"
alias l='ls -a'
alias l1='ls -1'
alias llt="ls -lFt --color"
alias count="ls -1 | wc -l"

alias _="sudo"

# Shortcuts to edit startup files
alias vbrc="vim ~/.bashrc"
alias vbpf="vim ~/.bash_profile"

# colored grep
# Need to check an existing file for a pattern that will be found to ensure
# that the check works when on an OS that supports the color option
if grep --color=auto "a" "${BASH_IT}/"*.md &> /dev/null
then
  alias grep='grep --color=auto'
fi

if which gshuf &> /dev/null
then
  alias shuf=gshuf
fi

alias c='clear'
alias k='clear'
alias cls='clear'

alias edit="$EDITOR"
alias pager="$PAGER"
alias q='exit'

alias irc="${IRC_CLIENT:=irc}"

# Language aliases
alias rb='ruby'
alias py='python'
alias ipy='ipython'

alias ..='cd ..'         # Go up one directory
alias cd..='cd ..'       # Common misspelling for going up one directory
alias ...='cd ../..'     # Go up two directories
alias ....='cd ../../..' # Go up three directories
alias -- -='cd -'        # Go back
alias ~="cd ~"

# Shell History
alias h='history'

# Tree
if [ ! -x "$(which tree 2>/dev/null)" ]
then
  alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
fi

# Directory
alias md='mkdir -p'
alias rd='rmdir'

# Shorten extract
alias xt="extract"

# sudo editors
alias svim="sudo vim"
alias snano="sudo nano"

# Display whatever file is regular file or folder
catt () {
  for i in "$@"; do
    if [ -d "$i" ]; then
      ls "$i"
    else
      cat "$i"
    fi
  done
}
