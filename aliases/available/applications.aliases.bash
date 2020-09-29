cite about-alias
about-alias 'Aliases to some common desktop applications and editors e.g., git editor, vi, IRC client'

# Assign the default editor and Git editor
export EDITOR="vi";
export GIT_EDITOR="vi";
export IRC_CLIENT='irssi'

alias edit="\$EDITOR"
alias irc="\${IRC_CLIENT:=irc}"

# sudo editors
alias svim="sudo vim"
alias snano="sudo nano"

# Desktop Programs
alias preview="open -a '\$PREVIEW'"
alias xcode="open -a '/Applications/XCode.app'"
alias filemerge="open -a '/Developer/Applications/Utilities/FileMerge.app'"
alias safari="open -a safari"
alias firefox="open -a firefox"
alias chrome="open -a google\ chrome"
alias chromium="open -a chromium"
alias dashcode="open -a dashcode"
alias f='open -a Finder '
alias fh='open -a Finder .'
alias textedit='open -a TextEdit'
alias hex='open -a "Hex Fiend"'
alias skype='open -a Skype'
alias mou='open -a Mou'
alias subl='open -a Sublime\ Text'

if [[ -s /usr/bin/firefox ]] ; then
  unalias firefox
fi
