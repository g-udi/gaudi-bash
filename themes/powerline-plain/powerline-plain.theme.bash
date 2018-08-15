#!/usr/bin/env bash

. "$BASH_IT/themes/powerline-plain/powerline-plain.base.bash"

USER_INFO_SSH_CHAR=${POWERLINE_USER_INFO_SSH_CHAR:="⌁ "}
USER_INFO_THEME_PROMPT_COLOR=32
USER_INFO_THEME_PROMPT_COLOR_SUDO=202

PYTHON_VENV_CHAR=${POWERLINE_PYTHON_VENV_CHAR:="ⓔ "}
CONDA_PYTHON_VENV_CHAR=${POWERLINE_CONDA_PYTHON_VENV_CHAR:="ⓔ "}
PYTHON_VENV_THEME_PROMPT_COLOR=35

SCM_NONE_CHAR=""
SCM_GIT_CHAR="⎇  "
SCM_GIT_BEHIND_CHAR="↓"
SCM_GIT_AHEAD_CHAR="↑"
SCM_GIT_UNTRACKED_CHAR="?:"
SCM_GIT_UNSTAGED_CHAR="U:"
SCM_GIT_STAGED_CHAR="S:"

if [[ -z "$THEME_SCM_TAG_PREFIX" ]]; then
    SCM_TAG_PREFIX="tag > "
else
    SCM_TAG_PREFIX="$THEME_SCM_TAG_PREFIX"
fi

SCM_THEME_PROMPT_CLEAN=""
SCM_THEME_PROMPT_DIRTY=""
SCM_THEME_PROMPT_CLEAN_COLOR=25
SCM_THEME_PROMPT_DIRTY_COLOR=88
SCM_THEME_PROMPT_STAGED_COLOR=30
SCM_THEME_PROMPT_UNSTAGED_COLOR=92
SCM_THEME_PROMPT_COLOR=${SCM_THEME_PROMPT_CLEAN_COLOR}

RVM_THEME_PROMPT_PREFIX=""
RVM_THEME_PROMPT_SUFFIX=""
RBENV_THEME_PROMPT_PREFIX=""
RBENV_THEME_PROMPT_SUFFIX=""
RUBY_THEME_PROMPT_COLOR=161
RUBY_CHAR=${POWERLINE_RUBY_CHAR:="💎 "}

CWD_THEME_PROMPT_COLOR=240

LAST_STATUS_THEME_PROMPT_COLOR=52

function set_rgb_color {
    if [[ "${1}" != "-" ]]; then
        fg="38;5;${1}"
    fi
    if [[ "${2}" != "-" ]]; then
        bg="48;5;${2}"
        [[ -n "${fg}" ]] && bg=";${bg}"
    fi
    echo -e "\[\033[${fg}${bg}m\]"
}

function powerline_shell_prompt {
    if [[ -n "${SSH_CLIENT}" ]]; then
        SHELL_PROMPT="${bold_white}$(set_rgb_color - ${SHELL_SSH_THEME_PROMPT_COLOR}) ${SHELL_SSH_CHAR}\u@\h ${normal}"
    else
        SHELL_PROMPT="${bold_white}$(set_rgb_color - ${SHELL_THEME_PROMPT_COLOR}) \u ${normal}"
    fi
}

function powerline_virtualenv_prompt {
    local environ=""

    if [[ -n "$CONDA_DEFAULT_ENV" ]]; then
        environ="conda: $CONDA_DEFAULT_ENV"
    elif [[ -n "$VIRTUAL_ENV" ]]; then
        environ=$(basename "$VIRTUAL_ENV")
    fi

    if [[ -n "$environ" ]]; then
        VIRTUALENV_PROMPT="$(set_rgb_color ${LAST_THEME_COLOR} ${VIRTUALENV_THEME_PROMPT_COLOR})${THEME_PROMPT_SEPARATOR}${normal}$(set_rgb_color - ${VIRTUALENV_THEME_PROMPT_COLOR}) ${VIRTUALENV_CHAR}$environ ${normal}"
        LAST_THEME_COLOR=${VIRTUALENV_THEME_PROMPT_COLOR}
    else
        VIRTUALENV_PROMPT=""
    fi
}

function powerline_gemset_prompt {
    local gemset=$(rvm-prompt 2>/dev/null)

    if [[ -n "$gemset" ]]; then
        GEMSET_PROMPT="$(set_rgb_color ${LAST_THEME_COLOR} ${GEMSET_THEME_PROMPT_COLOR})${THEME_PROMPT_SEPARATOR}${normal}$(set_rgb_color - ${GEMSET_THEME_PROMPT_COLOR}) ${VIRTUALENV_CHAR}$gemset ${normal}"
        LAST_THEME_COLOR=${GEMSET_THEME_PROMPT_COLOR}
    else
        GEMSET_PROMPT=""
    fi
}

function powerline_scm_prompt {
    scm_prompt_vars

    if [[ "${SCM_NONE_CHAR}" != "${SCM_CHAR}" ]]; then
        if [[ "${SCM_DIRTY}" -eq 1 ]]; then
            if [[ -n "${SCM_GIT_STAGED}" ]]; then
                SCM_PROMPT="$(set_rgb_color ${SCM_THEME_PROMPT_STAGED_COLOR} ${SCM_THEME_PROMPT_COLOR})"
            elif [[ -n "${SCM_GIT_UNSTAGED}" ]]; then
                SCM_PROMPT="$(set_rgb_color ${SCM_THEME_PROMPT_UNSTAGED_COLOR} ${SCM_THEME_PROMPT_COLOR})"
            else
                SCM_PROMPT="$(set_rgb_color ${SCM_THEME_PROMPT_DIRTY_COLOR} ${SCM_THEME_PROMPT_COLOR})"
            fi
        else
            SCM_PROMPT="$(set_rgb_color ${SCM_THEME_PROMPT_CLEAN_COLOR} ${SCM_THEME_PROMPT_COLOR})"
        fi
        if [[ "${SCM_GIT_CHAR}" == "${SCM_CHAR}" ]]; then
            local tag=""
            if [[ $SCM_IS_TAG -eq "1" ]]; then
                tag=$SCM_TAG_PREFIX
            fi
            SCM_PROMPT+=" ${SCM_CHAR}${tag}${SCM_BRANCH}${SCM_STATE} "
            [[ -n "${SCM_GIT_AHEAD}" ]] && SCM_PROMPT+="${SCM_GIT_AHEAD} "
            [[ -n "${SCM_GIT_BEHIND}" ]] && SCM_PROMPT+="${SCM_GIT_BEHIND} "
            [[ -n "${SCM_GIT_STAGED}" ]] && SCM_PROMPT+="${SCM_GIT_STAGED} "
            [[ -n "${SCM_GIT_UNSTAGED}" ]] && SCM_PROMPT+="${SCM_GIT_UNSTAGED} "
            [[ -n "${SCM_GIT_UNTRACKED}" ]] && SCM_PROMPT+="${SCM_GIT_UNTRACKED} "
            [[ -n "${SCM_GIT_STASH}" ]] && SCM_PROMPT+="${SCM_GIT_STASH} "
        fi
        SCM_PROMPT="${SCM_PROMPT}${normal}"
    else
        SCM_PROMPT=""
    fi
}

BATTERY_AC_CHAR=${BATTERY_AC_CHAR:="+ "}
BATTERY_STATUS_THEME_PROMPT_GOOD_COLOR=70
BATTERY_STATUS_THEME_PROMPT_LOW_COLOR=208
BATTERY_STATUS_THEME_PROMPT_CRITICAL_COLOR=160

THEME_CLOCK_FORMAT=${THEME_CLOCK_FORMAT:="%H:%M:%S"}

IN_VIM_THEME_PROMPT_COLOR=245
IN_VIM_THEME_PROMPT_TEXT="vim"

HOST_THEME_PROMPT_COLOR=0

POWERLINE_PROMPT=${POWERLINE_PROMPT:="user_info scm python_venv ruby cwd"}

safe_append_prompt_command __powerline_prompt_command

