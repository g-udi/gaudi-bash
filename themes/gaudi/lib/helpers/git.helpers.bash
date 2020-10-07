#!/usr/bin/env bash

GAUDI_SCM_GIT_SHOW_DETAILS=${GAUDI_SCM_GIT_SHOW_DETAILS:=true}
GAUDI_SCM_GIT_SHOW_REMOTE_INFO=${GAUDI_SCM_GIT_SHOW_REMOTE_INFO:=auto}
GAUDI_SCM_GIT_IGNORE_UNTRACKED=${GAUDI_SCM_GIT_IGNORE_UNTRACKED:=false}
GAUDI_SCM_GIT_SHOW_CURRENT_USER=${GAUDI_SCM_GIT_SHOW_CURRENT_USER:=false}
GAUDI_SCM_GIT_SHOW_COMMIT_SHA=${GAUDI_SCM_GIT_SHOW_COMMIT_SHA:=false}

GAUDI_SCM_GIT='git'
GAUDI_SCM_GIT_CHAR='\ue727'
GAUDI_SCM_GIT_USER_CHAR='\uf7a3'
GAUDI_SCM_GIT_AHEAD_CHAR="⇡ "
GAUDI_SCM_GIT_BEHIND_CHAR="⇣ "
GAUDI_SCM_GIT_UNTRACKED_CHAR="?:"
GAUDI_SCM_GIT_UNSTAGED_CHAR="U:"
GAUDI_SCM_GIT_STAGED_CHAR="S:"
GAUDI_SCM_GIT_STASH_CHAR='\uf5e1'
GAUDI_SCM_GIT_SHA_CHAR='\uf417'

_git-symbolic-ref () {
 git symbolic-ref -q HEAD 2> /dev/null
}

# When on a branch, this is often the same as _git-commit-description,
# but this can be different when two branches are pointing to the
# same commit. _git-branch is used to explicitly choose the checked-out
# branch.
_git-branch () {
 git symbolic-ref -q --short HEAD 2> /dev/null || return 1
}

_git-tag () {
  git describe --tags --exact-match 2> /dev/null
}

_git-commit-description () {
  git describe --contains --all 2> /dev/null
}

_git-short-sha () {
  git rev-parse --short HEAD
}

# Try the checked-out branch first to avoid collision with branches pointing to the same ref.
_git-friendly-ref () {
  _git-branch || _git-tag || _git-commit-description || _git-short-sha
}

_git-num-remotes () {
  git remote | wc -l
}

_git-upstream () {
  local ref
  ref="$(_git-symbolic-ref)" || return 1
  git for-each-ref --format="%(upstream:short)" "${ref}"
}

_git-upstream-remote () {
  local upstream
  upstream="$(_git-upstream)" || return 1

  local branch
  branch="$(_git-upstream-branch)" || return 1
  echo -e -n "${upstream%"/${branch}"}"
}

_git-upstream-branch () {
  local ref
  ref="$(_git-symbolic-ref)" || return 1

  # git versions < 2.13.0 do not support "strip" for upstream format
  # regex replacement gives the wrong result for any remotes with slashes in the name,
  # so only use when the strip format fails.
  git for-each-ref --format="%(upstream:strip=3)" "${ref}" 2> /dev/null || git for-each-ref --format="%(upstream)" "${ref}" | sed -e "s/.*\/.*\/.*\///"
}

_git-upstream-behind-ahead () {
  git rev-list --left-right --count "$(_git-upstream)...HEAD" 2> /dev/null
}

_git-upstream-branch-gone () {
  [[ "$(git status -s -b | sed -e 's/.* //')" == "[gone]" ]]
}

_git-hide-status () {
  [[ "$(git config --get bash-it.hide-status)" == "1" ]]
}

_git-status () {
  local git_status_flags=
  [[ "${GAUDI_SCM_GIT_IGNORE_UNTRACKED}" = "true" ]] && git_status_flags='-uno'
  git status --porcelain ${git_status_flags} 2> /dev/null
}

_git-status-counts () {
  _git-status | awk '
  BEGIN {
    untracked=0;
    unstaged=0;
    staged=0;
  }
  {
    if ($0 ~ /^\?\? .+/) {
      untracked += 1
    } else {
      if ($0 ~ /^.[^ ]] .+/) {
        unstaged += 1
      }
      if ($0 ~ /^[^ ]]. .+/) {
        staged += 1
      }
    }
  }
  END {
    print untracked "\t" unstaged "\t" staged
  }'
}

_git-remote-info () {
  [[ "$(_git-upstream)" == "" ]] && return

  local same_branch_name=
  [[ "$(_git-branch)" == "$(_git-upstream-branch)" ]] && same_branch_name=true
  if ([[ "${GAUDI_SCM_GIT_SHOW_REMOTE_INFO}" = "auto" ]] && [[ "$(_git-num-remotes)" -ge 2 ]]) ||
      [[ "${GAUDI_SCM_GIT_SHOW_REMOTE_INFO}" = "true" ]]; then
    if [[ "${same_branch_name}" != "true" ]]; then
      remote_info="\$(_git-upstream)"
    else
      remote_info="$(_git-upstream-remote)"
    fi
  elif [[ ${same_branch_name} != "true" ]]; then
    remote_info="\$(_git-upstream-branch)"
  fi
  if [[ -n "${remote_info}" ]];then
    echo -e -n "${remote_info}"
  fi
}

# Unused by bash-it, present for API compatibility
git_status_summary () {
  awk '
  BEGIN {
    untracked=0;
    unstaged=0;
    staged=0;
  }
  {
    if (!after_first && $0 ~ /^##.+/) {
      print $0
      seen_header = 1
    } else if ($0 ~ /^\?\? .+/) {
      untracked += 1
    } else {
      if ($0 ~ /^.[^ ]] .+/) {
        unstaged += 1
      }
      if ($0 ~ /^[^ ]]. .+/) {
        staged += 1
      }
    }
    after_first = 1
  }
  END {
    if (!seen_header) {
      print
    }
    print untracked "\t" unstaged "\t" staged
  }'
}

git_user_info () {
  # support two or more initials, set by 'git pair' plugin
  GAUDI_SCM_CURRENT_USER=$(git config user.initials | sed 's% %+%')
  # if `user.initials` weren't set, attempt to extract initials from `user.name`
  [[ -z "${GAUDI_SCM_CURRENT_USER}" ]] && GAUDI_SCM_CURRENT_USER=$(printf "%s" $(for word in $(git config user.name | PERLIO=:utf8 perl -pe '$_=lc'); do printf "%s" "${word:0:1}"; done))
  [[ -n "${GAUDI_SCM_CURRENT_USER}" ]] && printf "%b" "$GAUDI_SCM_GIT_USER_CHAR $GAUDI_SCM_CURRENT_USER"
}

git_prompt_minimal_info () {

  GAUDI_SCM_STATE=${GAUDI_SCM_THEME_PROMPT_CLEAN}

  _git-hide-status && return

  GAUDI_SCM_BRANCH="$(_git-friendly-ref)"

  if [[ -n "$(_git-status | tail -n1)" ]]; then
    GAUDI_SCM_DIRTY=1
    GAUDI_SCM_STATE=${GAUDI_SCM_THEME_PROMPT_DIRTY}
  fi

  # Output the git prompt
  echo -e -n "${GAUDI_SCM_BRANCH}${GAUDI_SCM_STATE}"
}

git_prompt_vars () {
  # Make sure we do a fetch to get all the information needed form the upstream
  [[ $GAUDI_SCM_FETCH == true ]] && git fetch &> /dev/null;

  if _git-branch &> /dev/null; then
    GAUDI_SCM_GIT_DETACHED="false"
    GAUDI_SCM_BRANCH="$(_git-friendly-ref)$(_git-remote-info)"
  else
    GAUDI_SCM_GIT_DETACHED="true"
    GAUDI_SCM_BRANCH="$(_git-friendly-ref)"
  fi

  IFS=$'\t' read -r commits_behind commits_ahead <<< "$(_git-upstream-behind-ahead)"
  [[ "${commits_ahead}" -gt 0 ]] && GAUDI_SCM_BRANCH+=" ${GAUDI_SCM_GIT_AHEAD_CHAR}${commits_ahead}"
  [[ "${commits_behind}" -gt 0 ]] && GAUDI_SCM_BRANCH+=" ${GAUDI_SCM_GIT_BEHIND_CHAR}${commits_behind}"

  local stash_count
  stash_count="$(git stash list 2> /dev/null | wc -l | tr -d ' ')"
  [[ "${stash_count}" -gt 0 ]] && GAUDI_SCM_BRANCH+=" ${GAUDI_SCM_GIT_STASH_CHAR} ${stash_count}"

  GAUDI_SCM_STATE=${GIT_THEME_PROMPT_CLEAN:-$GAUDI_SCM_THEME_PROMPT_CLEAN}
  if ! _git-hide-status; then
    IFS=$'\t' read -r untracked_count unstaged_count staged_count <<< "$(_git-status-counts)"
    if [[ "${untracked_count}" -gt 0 || "${unstaged_count}" -gt 0 || "${staged_count}" -gt 0 ]]; then
      GAUDI_SCM_DIRTY=1
      if [[ "${GAUDI_SCM_GIT_SHOW_DETAILS}" = "true" ]]; then
        [[ "${staged_count}" -gt 0 ]] && GAUDI_SCM_BRANCH+=" ${GAUDI_SCM_GIT_STAGED_CHAR}${staged_count}" && GAUDI_SCM_DIRTY=3
        [[ "${unstaged_count}" -gt 0 ]] && GAUDI_SCM_BRANCH+=" ${GAUDI_SCM_GIT_UNSTAGED_CHAR}${unstaged_count}" && GAUDI_SCM_DIRTY=2
        [[ "${untracked_count}" -gt 0 ]] && GAUDI_SCM_BRANCH+=" ${GAUDI_SCM_GIT_UNTRACKED_CHAR}${untracked_count}" && GAUDI_SCM_DIRTY=1
      fi
      GAUDI_SCM_STATE=${GIT_THEME_PROMPT_DIRTY:-$GAUDI_SCM_THEME_PROMPT_DIRTY}
    fi
  fi

  if [[ "${GAUDI_SCM_GIT_SHOW_COMMIT_SHA}" == true ]]; then
    GAUDI_SCM_BRANCH+=$(echo -e -n " ${GAUDI_SCM_GIT_SHA_CHAR} $(_git-short-sha)")
  fi

  [[ "${GAUDI_SCM_GIT_SHOW_CURRENT_USER}" == "true" ]] && GAUDI_SCM_BRANCH+="$(git_user_info)"

  GAUDI_SCM_CHANGE=$(_git-short-sha 2>/dev/null || echo "")
}
