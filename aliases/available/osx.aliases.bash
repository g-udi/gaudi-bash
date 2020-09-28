cite about-alias
about-alias 'osx-specific aliases'

# Requires growlnotify, which can be found in the Growl DMG under "Extras"
alias grnot='growlnotify -s -t Terminal -m "Done"'

# Get rid of those pesky .DS_Store files recursively
alias dsclean='find . -type f -name .DS_Store -delete'

# Track who is listening to your iTunes music
alias whotunes='lsof -r 2 -n -P -F n -c iTunes -a -i TCP@`hostname`:3689'

# Flush your dns cache
alias flush='dscacheutil -flushcache'

# Show/hide hidden files (for Mac OS X Mavericks)
alias showhidden="defaults write com.apple.finder AppleShowAllFiles TRUE"
alias hidehidden="defaults write com.apple.finder AppleShowAllFiles FALSE"

# Use Finder's Quick Look on a file (^C or space to close)
alias ql='qlmanage -p 2>/dev/null'

# Mute/Unmute the system volume. Plays nice with all other volume settings.
alias mute="osascript -e 'set volume output muted true'"
alias unmute="osascript -e 'set volume output muted false'"
