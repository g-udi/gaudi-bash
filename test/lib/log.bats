#!/usr/bin/env bats
# shellcheck shell=bats
# shellcheck disable=SC2034

load "$GAUDI_TEST_DIRECTORY"/helper.bash

load "$GAUDI_BASH"/lib/composure.bash
load "$GAUDI_BASH"/lib/gaudi-bash.bash
load "$GAUDI_BASH"/lib/colors.bash

cite about param example group priority

load "$GAUDI_BASH"/lib/log.bash

@test "gaudi-bash log: _gaudi-bash-get-component-name-from-path extract component name from path" {

	run _gaudi-bash-get-component-name-from-path "/Users/ahmadassaf/.gaudi_bash/lib/alias-completions.plugins.bash"
	assert_success
	assert_output "alias-completions"

	run _gaudi-bash-get-component-name-from-path "/Users/ahmadassaf/.gaudi_bash/lib/colors.aliases.bash"
	assert_success
	assert_output "colors"

	run _gaudi-bash-get-component-name-from-path "/Users/ahmadassaf/.gaudi_bash/lib/colors.completions.bash"
	assert_success
	assert_output "colors"

	run _gaudi-bash-get-component-name-from-path "/Users/ahmadassaf/.gaudi_bash/lib/150___colors.completions.bash"
	assert_success
	assert_output "colors"

	run _gaudi-bash-get-component-name-from-path "/Users/ahmadassaf/.gaudi_bash/lib/950___alias-completions.plugins.bash"
	assert_success
	assert_output "alias-completions"

}

@test "gaudi-bash log: _gaudi-bash-get-component-type-from-path extract component type from path" {

	run _gaudi-bash-get-component-type-from-path "/Users/ahmadassaf/.gaudi_bash/lib/alias-completions.plugins.bash"
	assert_success
	assert_output "plugin"

	run _gaudi-bash-get-component-type-from-path "/Users/ahmadassaf/.gaudi_bash/lib/colors.aliases.bash"
	assert_success
	assert_output "alias"

	run _gaudi-bash-get-component-type-from-path "/Users/ahmadassaf/.gaudi_bash/lib/colors.completions.bash"
	assert_success
	assert_output "completion"

	run _gaudi-bash-get-component-type-from-path "/Users/ahmadassaf/.gaudi_bash/lib/150___colors.completions.bash"
	assert_success
	assert_output "completion"

	run _gaudi-bash-get-component-type-from-path "/Users/ahmadassaf/.gaudi_bash/lib/950___alias-completions.plugins.bash"
	assert_success
	assert_output "plugin"

	run _gaudi-bash-get-component-type-from-path "/Users/ahmadassaf/.gaudi_bash/lib/950___alias-completions.aliases.bash"
	assert_success
	assert_output "alias"

}

@test "gaudi-bash log: _log_general should not log anything if no message is passed" {

	run _log_general
	assert_success
	refute_output
}

@test "gaudi-bash log: _log_general should print default prefix and type if only a message is passed" {

	run _log_general "this is a test log"
	assert_success
	assert_output " [ GENERAL ] [CORE] this is a test log"
}

@test "gaudi-bash log: _log_general should print default type and custom prefix" {

	GAUDI_BASH_LOG_PREFIX="TEST"

	run _log_general "this is a test log"
	assert_success
	assert_output " [ GENERAL ] [TEST] this is a test log"
}

@test "gaudi-bash log: _log_general should print custom type and custom prefix" {

	GAUDI_BASH_LOG_PREFIX="TEST"

	run _log_general "this is a test log" "debug"
	assert_success
	assert_output " [ DEBUG ] [TEST] this is a test log"
}

@test "gaudi-bash log: _log_general should print default prefix and custom type" {

	run _log_general "this is a test log" "debug"
	assert_success
	assert_output " [ DEBUG ] [CORE] this is a test log"
}

@test "gaudi-bash log: _log_debug should print a debug log message" {

	GAUDI_BASH_LOG_LEVEL=$GAUDI_BASH_LOG_LEVEL_ALL

	run _log_debug "this is a test log"
	assert_success
	assert_output " [ DEBUG ] [CORE] this is a test log"

	GAUDI_BASH_LOG_PREFIX="TEST"
	run _log_debug "this is a test log"
	assert_success
	assert_output " [ DEBUG ] [TEST] this is a test log"
}

@test "gaudi-bash log: _log_warn should print a warn log message" {

	GAUDI_BASH_LOG_LEVEL=$GAUDI_BASH_LOG_LEVEL_WARNING

	run _log_warning "this is a test log"
	assert_success
	assert_output " [ WARNING ] [CORE] this is a test log"

	GAUDI_BASH_LOG_PREFIX="TEST"
	run _log_warning "this is a test log"
	assert_success
	assert_output " [ WARNING ] [TEST] this is a test log"
}

@test "gaudi-bash log: _log_error should print an error log message" {

	GAUDI_BASH_LOG_LEVEL=$GAUDI_BASH_LOG_LEVEL_ERROR

	run _log_error "this is a test log"
	assert_success
	assert_output " [ ERROR ] [CORE] this is a test log"

	GAUDI_BASH_LOG_PREFIX="TEST"
	run _log_error "this is a test log"
	assert_success
	assert_output " [ ERROR ] [TEST] this is a test log"
}

@test "gaudi-bash log: _log_component should log proper loading message for gaudi-bash components" {

	GAUDI_BASH_LOG_LEVEL=$GAUDI_BASH_LOG_LEVEL_ALL

	run _log_component "/Users/ahmadassaf/.gaudi_bash/enabled/150___alias-completion.plugins.bash"
	assert_success
	assert_output " [ DEBUG ] [CORE] Loading plugin: alias-completion"

	run _log_component "/Users/ahmadassaf/.gaudi_bash/enabled/base.plugins.bash"
	assert_success
	assert_output " [ DEBUG ] [CORE] Loading plugin: base"

	run _log_component "/Users/ahmadassaf/.gaudi_bash/enabled/250___base.aliases.bash"
	assert_success
	assert_output " [ DEBUG ] [CORE] Loading alias: base"

	run _log_component "/Users/ahmadassaf/.gaudi_bash/enabled/250___base.completions.bash"
	assert_success
	assert_output " [ DEBUG ] [CORE] Loading completion: base"
}

@test "gaudi-bash log: _log_component should log proper loading message for gaudi-bash components with a custom prefix" {

	GAUDI_BASH_LOG_LEVEL=$GAUDI_BASH_LOG_LEVEL_ALL
	GAUDI_BASH_LOG_PREFIX="LOADER"

	run _log_component "/Users/ahmadassaf/.gaudi_bash/enabled/150___alias-completion.plugins.bash"
	assert_success
	assert_output " [ DEBUG ] [LOADER] Loading plugin: alias-completion"

	run _log_component "/Users/ahmadassaf/.gaudi_bash/enabled/base.plugins.bash"
	assert_success
	assert_output " [ DEBUG ] [LOADER] Loading plugin: base"

	run _log_component "/Users/ahmadassaf/.gaudi_bash/enabled/250___base.aliases.bash"
	assert_success
	assert_output " [ DEBUG ] [LOADER] Loading alias: base"

	run _log_component "/Users/ahmadassaf/.gaudi_bash/enabled/250___base.completions.bash"
	assert_success
	assert_output " [ DEBUG ] [LOADER] Loading completion: base"
}

@test "gaudi-bash log: _log_component should log proper loading message for gaudi-bash libraries, themes and custom components" {

	GAUDI_BASH_LOG_LEVEL=$GAUDI_BASH_LOG_LEVEL_ALL

	run _log_component "/Users/ahmadassaf/.gaudi_bash/enabled/colors.bash" "library"
	assert_success
	assert_output " [ DEBUG ] [CORE] Loading library: colors"

	run _log_component "gaudi" "theme"
	assert_success
	assert_output " [ DEBUG ] [CORE] Loading theme: gaudi"

	run _log_component "/Users/ahmadassaf/.gaudi_bash/enabled/alias-completion.bash" "library"
	assert_success
	assert_output " [ DEBUG ] [CORE] Loading library: alias-completion"
}

@test "gaudi-bash log: _log_component should log proper loading message for gaudi-bash libraries, themes and custom components with a custom prefix" {

	GAUDI_BASH_LOG_LEVEL=$GAUDI_BASH_LOG_LEVEL_ALL
	GAUDI_BASH_LOG_PREFIX="LOADER"

	run _log_component "/Users/ahmadassaf/.gaudi_bash/enabled/colors.bash" "library"
	assert_success
	assert_output " [ DEBUG ] [LOADER] Loading library: colors"

	run _log_component "gaudi" "theme"
	assert_success
	assert_output " [ DEBUG ] [LOADER] Loading theme: gaudi"
}

@test "gaudi-bash log: basic debug logging with GAUDI_BASH_LOG_LEVEL_ALL" {

	GAUDI_BASH_LOG_LEVEL=$GAUDI_BASH_LOG_LEVEL_ALL

	run _log_debug "test test test"
	assert_output " [ DEBUG ] [CORE] test test test"
}

@test "gaudi-bash log: basic warning logging with GAUDI_BASH_LOG_LEVEL_ALL" {

	GAUDI_BASH_LOG_LEVEL=$GAUDI_BASH_LOG_LEVEL_ALL

	run _log_warning "test test test"
	assert_output " [ WARNING ] [CORE] test test test"
}

@test "gaudi-bash log: basic error logging with GAUDI_BASH_LOG_LEVEL_ALL" {

	GAUDI_BASH_LOG_LEVEL=$GAUDI_BASH_LOG_LEVEL_ALL

	run _log_error "test test test"
	assert_output " [ ERROR ] [CORE] test test test"
}

@test "gaudi-bash log: basic debug logging with GAUDI_BASH_LOG_LEVEL_WARNING" {

	GAUDI_BASH_LOG_LEVEL=$GAUDI_BASH_LOG_LEVEL_WARNING

	run _log_debug "test test test"
	refute_output
}

@test "gaudi-bash log: basic warning logging with GAUDI_BASH_LOG_LEVEL_WARNING" {

	GAUDI_BASH_LOG_LEVEL=$GAUDI_BASH_LOG_LEVEL_WARNING

	run _log_warning "test test test"
	assert_output " [ WARNING ] [CORE] test test test"
}

@test "gaudi-bash log: basic error logging with GAUDI_BASH_LOG_LEVEL_WARNING" {

	GAUDI_BASH_LOG_LEVEL=$GAUDI_BASH_LOG_LEVEL_WARNING

	run _log_error "test test test"
	assert_output " [ ERROR ] [CORE] test test test"
}

@test "gaudi-bash log: basic debug logging with GAUDI_BASH_LOG_LEVEL_ERROR" {

	GAUDI_BASH_LOG_LEVEL=$GAUDI_BASH_LOG_LEVEL_ERROR

	run _log_debug "test test test"
	refute_output
}

@test "gaudi-bash log: basic warning logging with GAUDI_BASH_LOG_LEVEL_ERROR" {

	GAUDI_BASH_LOG_LEVEL=$GAUDI_BASH_LOG_LEVEL_ERROR

	run _log_warning "test test test"
	refute_output
}

@test "gaudi-bash log: basic error logging with GAUDI_BASH_LOG_LEVEL_ERROR" {

	GAUDI_BASH_LOG_LEVEL=$GAUDI_BASH_LOG_LEVEL_ERROR

	run _log_error "test test test"
	assert_output " [ ERROR ] [CORE] test test test"
}

@test "gaudi-bash log: basic debug silent logging" {

	run _log_debug "test test test"
	refute_output
}

@test "gaudi-bash log: basic warning silent logging" {

	run _log_warning "test test test"
	refute_output
}

@test "gaudi-bash log: basic error silent logging" {

	run _log_error "test test test"
	refute_output
}

@test "gaudi-bash log: logging with prefix" {

	GAUDI_BASH_LOG_LEVEL=$GAUDI_BASH_LOG_LEVEL_ALL
	GAUDI_BASH_LOG_PREFIX="nice: prefix:"

	run _log_debug "test test test"
	assert_output " [ DEBUG ] [nice: prefix:] test test test"
}
