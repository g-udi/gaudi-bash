# shellcheck shell=bash
#
# Functions for measuring and reporting how long a command takes to run.
# Uses EPOCHREALTIME for sub-second precision, falls back to $SECONDS.

# Get current time in decimal format regardless of runtime locale.
# EPOCHREALTIME decimal separator varies by locale, so we normalize it.
function _command_duration_current_time() {
	local current_time
	if [[ -n "${EPOCHREALTIME:-}" ]]; then
		current_time="${EPOCHREALTIME//[!0-9]/.}"
	else
		current_time="$SECONDS"
	fi
	echo "$current_time"
}

: "${COMMAND_DURATION_START_SECONDS:=$(_command_duration_current_time)}"
: "${COMMAND_DURATION_ICON:=🕘}"
: "${COMMAND_DURATION_MIN_SECONDS:=1}"
: "${COMMAND_DURATION_PRECISION:=1}"

function _command_duration_pre_exec() {
	COMMAND_DURATION_START_SECONDS="$(_command_duration_current_time)"
}

function _command_duration_pre_cmd() {
	COMMAND_DURATION_START_SECONDS=""
}

function _dynamic_clock_icon() {
	local clock_hand duration="$1"

	if ((duration < 1)); then
		duration=1
	fi

	# Clock emoji codepoints: U+1F550 to U+1F55B (12 positions)
	printf -v clock_hand '%x' $((((${duration:-${SECONDS}} - 1) % 12) + 144))
	printf -v 'COMMAND_DURATION_ICON' '%b' "\xf0\x9f\x95\x$clock_hand"
}

# Main function: computes elapsed time and formats output.
# Set GAUDI_BASH_COMMAND_DURATION=true to enable.
function _command_duration() {
	[[ -n "${GAUDI_BASH_COMMAND_DURATION:-}" ]] || return
	[[ -n "${COMMAND_DURATION_START_SECONDS:-}" ]] || return

	local current_time
	current_time="$(_command_duration_current_time)"

	local -i command_duration=0
	local -i minutes=0 seconds=0
	local microseconds=""

	local -i command_start_seconds=${COMMAND_DURATION_START_SECONDS%.*}
	local -i current_time_seconds=${current_time%.*}

	command_duration=$((current_time_seconds - command_start_seconds))

	# Calculate microseconds if both timestamps have fractional parts
	if [[ "$COMMAND_DURATION_START_SECONDS" == *.* ]] && [[ "$current_time" == *.* ]] && ((COMMAND_DURATION_PRECISION > 0)); then
		local -i command_start_microseconds=$((10#${COMMAND_DURATION_START_SECONDS##*.}))
		local -i current_time_microseconds=$((10#${current_time##*.}))

		if ((current_time_microseconds >= command_start_microseconds)); then
			microseconds=$((current_time_microseconds - command_start_microseconds))
		else
			((command_duration -= 1))
			microseconds=$((1000000 + current_time_microseconds - command_start_microseconds))
		fi

		printf -v microseconds '%06d' "$microseconds"
		microseconds="${microseconds:0:$COMMAND_DURATION_PRECISION}"
	fi

	if ((command_duration >= COMMAND_DURATION_MIN_SECONDS)); then
		minutes=$((command_duration / 60))
		seconds=$((command_duration % 60))

		_dynamic_clock_icon "${command_duration}"
		if ((minutes > 0)); then
			printf "%s %s%dm %ds" "${COMMAND_DURATION_ICON:-}" "${COMMAND_DURATION_COLOR:-}" "$minutes" "$seconds"
		else
			printf "%s %s%ss" "${COMMAND_DURATION_ICON:-}" "${COMMAND_DURATION_COLOR:-}" "$seconds${microseconds:+.$microseconds}"
		fi
	fi
}

# Register hooks via bash-preexec (loaded by lib/preexec.bash)
_gaudi_bash_command_duration_init() {
	preexec_functions+=(_command_duration_pre_exec)
	precmd_functions+=(_command_duration_pre_cmd)
}

GAUDI_BASH_LIBRARY_FINALIZE_HOOK+=("_gaudi_bash_command_duration_init")
