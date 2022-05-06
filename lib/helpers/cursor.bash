#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2163

# @function     __gaudi-get-cursor-column
# @description  get the column number of the current cursor position
# @return       success (0) or failure status (1)
# @example      ❯ __gaudi-get-cursor-row
function __gaudi-get-cursoer-row() {
    local COL
    local ROW
    IFS=';' read -sdrR -p $'\E[6n' ROW COL
    echo "${ROW#*[}"
}

# @function     __gaudi-get-cursor-column
# @description  get the row number of the current cursor position
# @return       success (0) or failure status (1)
# @example      ❯ __gaudi-get-cursor-column
function __gaudi-get-cursor-column() {
    local COL
    local ROW
    IFS=';' read -sdrR -p $'\E[6n' ROW COL
    echo "${COL}"
}

# @function     __gaudi-get-cursor-position
# @description  get the current position of the cursor in row and column numbers (based on a script from http://invisible-island.net/xterm/xterm.faq.html)
# @param $1     the position array to return the values in
# @return       the position array with array[0] being the cursor's row number and array[1] is the cursor's column number
# @example      ❯ __gaudi-get-cursor-position cursor_position
function __gaudi-get-cursor-position() {
    export "$1"
    
    exec < /dev/tty
    oldstty=$(stty -g)
    stty raw -echo min 0
    echo -en "\033[6n" > /dev/tty
    # tput u7 > /dev/tty    # when TERM=xterm (and relatives)
    IFS=';' read -r -d R -a pos
    stty "$oldstty"

    # change from one-based to zero based so they work with: tput cup $row $col
    eval "$1[0]=$((${pos[0]:2} - 1))"
    eval "$1[1]=$((pos[1] - 1))"
}