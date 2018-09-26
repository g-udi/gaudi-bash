#!/usr/bin/env bash

# Put the last command's run time in your Bash prompt
gaudi::execution_time() {
    echo "Running exectuin trap"
    timer_start() {
        timer=${timer:-$SECONDS}
    }

    timer_stop() {
        timer_show=$(($SECONDS - $timer))
        unset timer
    }
    
    trap 'timer_start' DEBUG
    if [ "$PROMPT_COMMAND" == "" ]; then
        PROMPT_COMMAND="timer_stop"
    else
        PROMPT_COMMAND="$PROMPT_COMMAND; timer_stop"
    fi
}