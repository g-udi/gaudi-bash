cite about-plugin
about-plugin 'history manipulation'
# enter a few characters and press UpArrow/DownArrow
# to search backwards/forwards through the history
if [ -t 1 ]
then
    bind '"[A":history-search-backward'
    bind '"[B":history-search-forward'
fi


export HISTCONTROL=ignoredups:erasedups  # no duplicate entries
export HISTSIZE=100000                   # big big history
export HISTFILESIZE=100000               # big big history
shopt -s histappend                      # append to history, don't overwrite it

# Save and reload the history after each command finishes
export PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"