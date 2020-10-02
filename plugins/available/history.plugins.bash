cite about-plugin
about-plugin 'history manipulation'
# enter a few characters and press UpArrow/DownArrow
# to search backwards/forwards through the history
if [[ -t 1 ]]
then
    bind '"[A":history-search-backward'
    bind '"[B":history-search-forward'
fi

# Preserve bash history in multiple terminal windows (https://unix.stackexchange.com/questions/1288/preserve-bash-history-in-multiple-terminal-windows)

# Explanation:

# Append the just entered line to the $HISTFILE (default is .bash_history). This will cause $HISTFILE to grow by one line.
# Setting the special variable $HISTFILESIZE to some value will cause Bash to truncate $HISTFILE to be no longer than $HISTFILESIZE lines by removing the oldest entries.
# Clear the history of the running session. This will reduce the history counter by the amount of $HISTSIZE.
# Read the contents of $HISTFILE and insert them in to the current running session history. this will raise the history counter by the amount of lines in $HISTFILE. Note that the line count of $HISTFILE is not necessarily $HISTFILESIZE.
# The history() function overrides the builtin history to make sure that the history is synchronised before it is displayed. This is necessary for the history expansion by number (more about this later).
#
# More explanation:
#   Step 1 ensures that the command from the current running session gets written to the global history file.
#   Step 4 ensures that the commands from the other sessions gets read in to the current session history.
#   Because step 4 will raise the history counter, we need to reduce the counter in some way. This is done in step 3.
#   In step 3 the history counter is reduced by $HISTSIZE. In step 4 the history counter is raised by the number of lines in $HISTFILE. In step 2 we make sure that the line count of $HISTFILE is exactly $HISTSIZE (this means that $HISTFILESIZE must be the same as $HISTSIZE).
#
# About the constraints of the history expansion:
#
# When using history expansion by number, you should always look up the number immediately before using it. That means no bash prompt display between looking up the number and using it. That usually means no enter and no ctrl+c.
# Generally, once you have more than one Bash session, there is no guarantee whatsoever that a history expansion by number will retain its value between two Bash prompt displays. Because when PROMPT_COMMAND is executed the history from all other Bash sessions are integrated in the history of the current session. If any other bash session has a new command then the history numbers of the current session will be different.
# I find this constraint reasonable. I have to look the number up every time anyway because I can't remember arbitrary history numbers.
# Usually I use the history expansion by number like this
#
# $ history | grep something #note number
# $ !number
# I recommend using the following Bash options.
#
# ## reedit a history substitution line if it failed
# shopt -s histreedit
# ## edit a recalled history line before executing
# shopt -s histverify
#
# Strange bugs:
# Running the history command piped to anything will result that command to be listed in the history twice. For example:
#
# $ history | head
# $ history | tail
# $ history | grep foo
# $ history | true
# $ history | false
# All will be listed in the history twice. I have no idea why.
#
# Ideas for improvements:
# Modify the function _bash_history_sync() so it does not execute every time. For example it should not execute after a CTRL+C on the prompt. I often use CTRL+C to discard a long command line when I decide that I do not want to execute that line. Sometimes I have to use CTRL+C to stop a Bash completion script.
#
# Commands from the current session should always be the most recent in the history of the current session. This will also have the side effect that a given history number keeps its value for history entries from this session.

HISTSIZE=9000
HISTFILESIZE=$HISTSIZE
HISTCONTROL=ignorespace:ignoredups

_bash_history_sync () {
  builtin history -a         #1
  HISTFILESIZE=$HISTSIZE     #2
  builtin history -c         #3
  builtin history -r         #4
}

history () {                  #5
  _bash_history_sync
  builtin history "$@"
}

PROMPT_COMMAND=_bash_history_sync

# Save and reload the history after each command finishes
export PROMPT_COMMAND="_bash_history_sync; $PROMPT_COMMAND"
