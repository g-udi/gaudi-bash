#!/usr/bin/env bats
# shellcheck shell=bats
# shellcheck disable=SC2034,SC1090,SC1091,SC2030,SC2031,SC2154

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	export TERM="xterm-256color"
	export XDG_CACHE_HOME="${BATS_TEST_TMPDIR}/cache"
	export PATH="${BATS_TEST_TMPDIR}/fakebin:$PATH"
	export GAUDI_REDRAW_LOG="${BATS_TEST_TMPDIR}/redraw.log"

	unset GAUDI_SCM_GIT_CHAR GAUDI_SCM_GIT_USER_CHAR GAUDI_SCM_GIT_AHEAD_CHAR
	unset GAUDI_SCM_GIT_BEHIND_CHAR GAUDI_SCM_GIT_UNTRACKED_CHAR GAUDI_SCM_GIT_CHANGED_CHAR
	unset GAUDI_SCM_GIT_STAGED_CHAR GAUDI_SCM_GIT_CONFLICTED_CHAR GAUDI_SCM_GIT_STASH_CHAR
	unset GAUDI_SCM_GIT_SHA_CHAR GAUDI_SCM_GIT_GONE_CHAR GAUDI_SCM_THEME_PROMPT_DIRTY
	unset GAUDI_SCM_THEME_BRANCH_PREFIX GAUDI_SCM_THEME_DETACHED_PREFIX GAUDI_SCM_THEME_TAG_PREFIX

	mkdir -p "${BATS_TEST_TMPDIR}/fakebin" "$XDG_CACHE_HOME"
}

local_teardown() {
	wait || true
}

source_gaudi_theme() {
	source "$GAUDI_BASH/components/themes/gaudi/gaudi.theme.bash"
}

count_array_entries() {
	local needle="$1"
	shift

	local count=0
	local value
	for value in "$@"; do
		[[ "$value" == "$needle" ]] && count=$((count + 1))
	done

	printf "%s" "$count"
}

disable_terminal_redraw() {
	gaudi::redraw_prompt() {
		printf "%s\n" "$(gaudi::render_cached_async_prompt GAUDI_PROMPT_ASYNC[@])" >> "$GAUDI_REDRAW_LOG"
	}
}

strip_ansi() {
	perl -pe 's/\e\[[0-9;]*[[:alpha:]]//g; s/\e\([A-Z]//g; s/\e\][^\a]*(\a|\e\\)//g'
}

create_git_repo() {
	local repo="$1"

	mkdir -p "$repo"
	git -C "$repo" init > /dev/null
}

@test "gaudi theme: uncached global async segments render on the first prompt without kube version calls" {
	local kubectl_calls="${BATS_TEST_TMPDIR}/kubectl.calls"

	cat > "${BATS_TEST_TMPDIR}/fakebin/aws" << 'EOF'
#!/usr/bin/env bash
exit 0
EOF
	chmod +x "${BATS_TEST_TMPDIR}/fakebin/aws"

	cat > "${BATS_TEST_TMPDIR}/fakebin/kubectl" << 'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$KUBECTL_CALLS"

if [[ "$1" == "config" && "$2" == "current-context" ]]; then
	printf '%s' 'dev-cluster'
	exit 0
fi

if [[ "$1" == "config" && "$2" == "view" ]]; then
	printf '%s' 'payments'
	exit 0
fi

exit 1
EOF
	chmod +x "${BATS_TEST_TMPDIR}/fakebin/kubectl"

	export AWS_DEFAULT_PROFILE="dev-profile"
	export KUBECTL_CALLS="$kubectl_calls"

	source_gaudi_theme
	GAUDI_PROMPT_LEFT=(cwd)
	GAUDI_PROMPT_RIGHT=()
	GAUDI_PROMPT_ASYNC=(aws kubecontext)

	gaudi::prompt

	[[ "$PS1" == *"dev-profile"* ]]
	[[ "$PS1" == *"dev-cluster | payments"* ]]

	wait

	run grep -Fq "version" "$kubectl_calls"
	assert_failure
}

@test "gaudi theme: scm uses readable git markers for staged changed and untracked files" {
	local repo="${BATS_TEST_TMPDIR}/scm-readable"

	create_git_repo "$repo"
	(
		cd "$repo" \
			&& printf 'base\n' > tracked.txt \
			&& git add tracked.txt \
			&& git commit -m 'initial' > /dev/null \
			&& git checkout -b 'codex/web' > /dev/null \
			&& printf 'staged\n' > staged.txt \
			&& git add staged.txt \
			&& printf 'changed\n' >> tracked.txt \
			&& printf 'untracked\n' > scratch.txt
	)

	source_gaudi_theme
	cd "$repo"

	run gaudi::render_segment scm
	assert_success
	assert_output --partial "codex/web"
	assert_output --partial "+:1"
	assert_output --partial "!:1"
	assert_output --partial "?:1"
	refute_output --partial "S:"
	refute_output --partial "U:"
	refute_output --partial "\\u"

	local stripped_output
	stripped_output="$(printf '%s' "$output" | strip_ansi)"
	[[ "$stripped_output" == " codex/web"* ]]
}

@test "gaudi theme: scm shows merge conflicts with an explicit conflict counter" {
	local repo="${BATS_TEST_TMPDIR}/scm-conflict"

	create_git_repo "$repo"
	(
		cd "$repo" \
			&& printf 'base\n' > conflict.txt \
			&& git add conflict.txt \
			&& git commit -m 'initial' > /dev/null \
			&& git checkout -b feature > /dev/null \
			&& printf 'feature\n' > conflict.txt \
			&& git commit -am 'feature change' > /dev/null \
			&& git checkout master > /dev/null \
			&& printf 'master\n' > conflict.txt \
			&& git commit -am 'master change' > /dev/null \
			&& ! git merge feature > /dev/null 2>&1
	)

	source_gaudi_theme
	cd "$repo"

	run gaudi::render_segment scm
	assert_success
	assert_output --partial "merge"
	assert_output --partial "x:1"
}

@test "gaudi theme: kubecontext defaults the namespace and hides when no context exists" {
	local kubectl_calls="${BATS_TEST_TMPDIR}/kubectl.calls"

	cat > "${BATS_TEST_TMPDIR}/fakebin/kubectl" << 'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >> "$KUBECTL_CALLS"

case "$1 $2" in
  "config current-context")
    if [[ -n "$GAUDI_TEST_KUBE_CONTEXT" ]]; then
      printf '%s' "$GAUDI_TEST_KUBE_CONTEXT"
    fi
    exit 0
    ;;
  "config view")
    if [[ -n "$GAUDI_TEST_KUBE_NAMESPACE" ]]; then
      printf '%s' "$GAUDI_TEST_KUBE_NAMESPACE"
    fi
    exit 0
    ;;
esac

exit 1
EOF
	chmod +x "${BATS_TEST_TMPDIR}/fakebin/kubectl"

	export KUBECTL_CALLS="$kubectl_calls"

	source_gaudi_theme

	export GAUDI_TEST_KUBE_CONTEXT="prod-cluster"
	unset GAUDI_TEST_KUBE_NAMESPACE

	run gaudi::render_segment kubecontext
	assert_success
	assert_output --partial "prod-cluster | default"

	unset GAUDI_TEST_KUBE_CONTEXT

	run gaudi::render_segment kubecontext
	assert_failure
	assert_output ""

	run grep -Fq "version" "$kubectl_calls"
	assert_failure
}

@test "gaudi theme: sourcing preserves bash-preexec and avoids duplicate prompt hooks" {
	existing_prompt_command() {
		:
	}

	PROMPT_COMMAND="existing_prompt_command"
	# bash-preexec may not be available in the test worktree (bin/ is excluded)
	if [[ ! -s "$GAUDI_BASH/bin/preexec/bash-preexec.sh" ]]; then
		skip "bash-preexec not available in test worktree"
	fi
	source "$GAUDI_BASH/bin/preexec/bash-preexec.sh"

	source_gaudi_theme
	source_gaudi_theme

	[[ "$PROMPT_COMMAND" == *"__bp_precmd_invoke_cmd"* ]]
	[[ "$PROMPT_COMMAND" == *"existing_prompt_command"* ]]
	[[ "$PROMPT_COMMAND" != "gaudi::prompt" ]]
	assert_equal "$(count_array_entries "gaudi::prompt" "${precmd_functions[@]}")" "1"
}

@test "gaudi theme: segment files are sourced once per shell session" {
	cat > "$GAUDI_BASH/components/themes/gaudi/segments/countsource.bash" << 'EOF'
#!/usr/bin/env bash
GAUDI_TEST_SOURCE_COUNT=$(( ${GAUDI_TEST_SOURCE_COUNT:-0} + 1 ))

gaudi_countsource() {
	printf '%s' 'countsource'
}
EOF

	source_gaudi_theme

	gaudi::render_segment countsource > /dev/null
	gaudi::render_segment countsource > /dev/null

	assert_equal "${GAUDI_TEST_SOURCE_COUNT:-0}" "1"
}

@test "gaudi theme: cached async content is reused before a fresh job finishes" {
	cat > "$GAUDI_BASH/components/themes/gaudi/segments/slowasync.bash" << 'EOF'
#!/usr/bin/env bash

gaudi_slowasync() {
	sleep "${GAUDI_SLOWASYNC_DELAY:-0}"
	printf '%s' "${GAUDI_SLOWASYNC_VALUE:-}"
}
EOF

	source_gaudi_theme
	disable_terminal_redraw

	GAUDI_PROMPT_LEFT=()
	GAUDI_PROMPT_RIGHT=()
	GAUDI_PROMPT_ASYNC=(slowasync)

	export GAUDI_SLOWASYNC_VALUE="one"
	export GAUDI_SLOWASYNC_DELAY="0"

	gaudi::prompt
	wait

	local cache_file
	cache_file="$(gaudi::async_segment_cache_file slowasync)"
	assert_file_exist "$cache_file"
	assert_equal "$(< "$cache_file")" "one"

	export GAUDI_SLOWASYNC_VALUE="two"
	export GAUDI_SLOWASYNC_DELAY="0.3"

	gaudi::prompt

	[[ "$PS1" == *"one"* ]]

	wait
	assert_equal "$(< "$cache_file")" "two"
}

@test "gaudi theme: stale async jobs cannot overwrite a newer generation or repaint" {
	cat > "$GAUDI_BASH/components/themes/gaudi/segments/raceasync.bash" << 'EOF'
#!/usr/bin/env bash

gaudi_raceasync() {
	sleep "${GAUDI_RACEASYNC_DELAY:-0}"
	printf '%s' "${GAUDI_RACEASYNC_VALUE:-}"
}
EOF

	source_gaudi_theme
	disable_terminal_redraw

	GAUDI_PROMPT_LEFT=()
	GAUDI_PROMPT_RIGHT=()
	GAUDI_PROMPT_ASYNC=(raceasync)

	export GAUDI_RACEASYNC_VALUE="old"
	export GAUDI_RACEASYNC_DELAY="0.3"
	gaudi::prompt

	export GAUDI_RACEASYNC_VALUE="new"
	export GAUDI_RACEASYNC_DELAY="0"
	gaudi::prompt

	wait

	local cache_file
	cache_file="$(gaudi::async_segment_cache_file raceasync)"
	assert_file_exist "$cache_file"
	assert_equal "$(< "$cache_file")" "new"
	run grep -Fxq "old" "$GAUDI_REDRAW_LOG"
	assert_failure
	run grep -Fxq "new" "$GAUDI_REDRAW_LOG"
	assert_success
}
