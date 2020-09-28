cite about-alias
about-alias 'gls enhanced ls (port from Linux using coreutils)'

# List all files colorized in long format
alias ll="gls -lFX --color"
# List all files colorized in long format, including dot files
alias la="gls --color -lXAhF --ignore={.DS_Store,.git}"
# List only directories
alias lsd="gls -lF --color | grep --color=never '^d'"
# Always use color output for `ls`
alias ls="command gls --color"
alias l='gls -aX'
alias l1='gls -1X'
