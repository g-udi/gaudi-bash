#!/usr/bin/env bats

#!/usr/bin/env bats

load ../helper
load ../../lib/composure
load ../../lib/helpers
load ../../lib/colors

cite about param example group

load ../../lib/log

@test "bash-it log: _bash-it-get-component-name-from-path extract component name from path" {
  run _bash-it-get-component-name-from-path "/Users/ahmadassaf/.bash_it/lib/alias-completions.plugins.bash"
  assert_success
  assert_output "alias-completions"

  run _bash-it-get-component-name-from-path "/Users/ahmadassaf/.bash_it/lib/colors.aliases.bash"
  assert_success
  assert_output "colors"

  run _bash-it-get-component-name-from-path "/Users/ahmadassaf/.bash_it/lib/colors.completions.bash"
  assert_success
  assert_output "colors"

  run _bash-it-get-component-name-from-path "/Users/ahmadassaf/.bash_it/lib/150___colors.completions.bash"
  assert_success
  assert_output "colors"

  run _bash-it-get-component-name-from-path "/Users/ahmadassaf/.bash_it/lib/950___alias-completions.plugins.bash"
  assert_success
  assert_output "alias-completions"

}

@test "bash-it log: _bash-it-get-component-type-from-path extract component name from path" {
  run _bash-it-get-component-type-from-path "/Users/ahmadassaf/.bash_it/lib/alias-completions.plugins.bash"
  assert_success
  assert_output "plugin"

  run _bash-it-get-component-type-from-path "/Users/ahmadassaf/.bash_it/lib/colors.aliases.bash"
  assert_success
  assert_output "alias"

  run _bash-it-get-component-type-from-path "/Users/ahmadassaf/.bash_it/lib/colors.completions.bash"
  assert_success
  assert_output "completion"

  run _bash-it-get-component-type-from-path "/Users/ahmadassaf/.bash_it/lib/150___colors.completions.bash"
  assert_success
  assert_output "completion"

  run _bash-it-get-component-type-from-path "/Users/ahmadassaf/.bash_it/lib/950___alias-completions.plugins.bash"
  assert_success
  assert_output "plugin"

  run _bash-it-get-component-type-from-path "/Users/ahmadassaf/.bash_it/lib/950___alias-completions.aliases.bash"
  assert_success
  assert_output "alias"

}

@test "bash-it log: _log_general should not log anything if no message is passed" {
  run _log_general
  assert_success
  refute_output
}

@test "bash-it log: _log_general should print default prefix and type if only a message is passed" {
  run _log_general "this is a test log"
  assert_success
  assert_output " [ GENERAL ] [CORE] this is a test log"
}

@test "bash-it log: _log_general should print default type and custom prefix" {
  BASH_IT_LOG_PREFIX="TEST"

  run _log_general "this is a test log"
  assert_success
  assert_output " [ GENERAL ] [TEST] this is a test log"
}

@test "bash-it log: _log_general should print custom type and custom prefix" {
  BASH_IT_LOG_PREFIX="TEST"

  run _log_general "this is a test log" "debug"
  assert_success
  assert_output " [ DEBUG ] [TEST] this is a test log"
}

@test "bash-it log: _log_general should print default prefix and custom type" {
  run _log_general "this is a test log" "debug"
  assert_success
  assert_output " [ DEBUG ] [CORE] this is a test log"
}

@test "bash-it log: _log_debug should print a debug log message" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ALL

  run _log_debug "this is a test log"
  assert_success
  assert_output " [ DEBUG ] [CORE] this is a test log"

  BASH_IT_LOG_PREFIX="TEST"
  run _log_debug "this is a test log"
  assert_success
  assert_output " [ DEBUG ] [TEST] this is a test log"
}

@test "bash-it log: _log_warn should print a warn log message" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_WARNING

  run _log_warning "this is a test log"
  assert_success
  assert_output " [ WARNING ] [CORE] this is a test log"

  BASH_IT_LOG_PREFIX="TEST"
  run _log_warning "this is a test log"
  assert_success
  assert_output " [ WARNING ] [TEST] this is a test log"
}

@test "bash-it log: _log_error should print an error log message" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ERROR

  run _log_error "this is a test log"
  assert_success
  assert_output " [ ERROR ] [CORE] this is a test log"

  BASH_IT_LOG_PREFIX="TEST"
  run _log_error "this is a test log"
  assert_success
  assert_output " [ ERROR ] [TEST] this is a test log"
}

@test "bash-it log: _log_component should log proper loading message for bash-it components" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ALL

  run _log_component "/Users/ahmadassaf/.bash_it/enabled/150___alias-completion.plugins.bash"
  assert_success
  assert_output " [ DEBUG ] [CORE] Loading plugin: alias-completion"

  run _log_component "/Users/ahmadassaf/.bash_it/enabled/base.plugins.bash"
  assert_success
  assert_output " [ DEBUG ] [CORE] Loading plugin: base"

  run _log_component "/Users/ahmadassaf/.bash_it/enabled/250___base.aliases.bash"
  assert_success
  assert_output " [ DEBUG ] [CORE] Loading alias: base"

  run _log_component "/Users/ahmadassaf/.bash_it/enabled/250___base.completions.bash"
  assert_success
  assert_output " [ DEBUG ] [CORE] Loading completion: base"
}

@test "bash-it log: _log_component should log proper loading message for bash-it components with a custom prefix" {

  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ALL
  BASH_IT_LOG_PREFIX="LOADER"

  run _log_component "/Users/ahmadassaf/.bash_it/enabled/150___alias-completion.plugins.bash"
  assert_success
  assert_output " [ DEBUG ] [LOADER] Loading plugin: alias-completion"

  run _log_component "/Users/ahmadassaf/.bash_it/enabled/base.plugins.bash"
  assert_success
  assert_output " [ DEBUG ] [LOADER] Loading plugin: base"

  run _log_component "/Users/ahmadassaf/.bash_it/enabled/250___base.aliases.bash"
  assert_success
  assert_output " [ DEBUG ] [LOADER] Loading alias: base"

  run _log_component "/Users/ahmadassaf/.bash_it/enabled/250___base.completions.bash"
  assert_success
  assert_output " [ DEBUG ] [LOADER] Loading completion: base"
}

@test "bash-it log: _log_component should log proper loading message for bash-it libraries, themes and custom components" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ALL

  run _log_component "/Users/ahmadassaf/.bash_it/enabled/colors.bash" "library"
  assert_success
  assert_output " [ DEBUG ] [CORE] Loading library: colors"

  run _log_component "gaudi" "theme"
  assert_success
  assert_output " [ DEBUG ] [CORE] Loading theme: gaudi"

  run _log_component "/Users/ahmadassaf/.bash_it/enabled/alias-completion.bash" "library"
  assert_success
  assert_output " [ DEBUG ] [CORE] Loading library: alias-completion"
}

@test "bash-it log: _log_component should log proper loading message for bash-it libraries, themes and custom components with a custom prefix" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ALL
  BASH_IT_LOG_PREFIX="LOADER"

  run _log_component "/Users/ahmadassaf/.bash_it/enabled/colors.bash" "library"
  assert_success
  assert_output " [ DEBUG ] [LOADER] Loading library: colors"

  run _log_component "gaudi" "theme"
  assert_success
  assert_output " [ DEBUG ] [LOADER] Loading theme: gaudi"
}

@test "lib log: basic debug logging with BASH_IT_LOG_LEVEL_ALL" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ALL

  run _log_debug "test test test"
  assert_output " [ DEBUG ] [CORE] test test test"
}

@test "lib log: basic warning logging with BASH_IT_LOG_LEVEL_ALL" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ALL

  run _log_warning "test test test"
  assert_output " [ WARNING ] [CORE] test test test"
}

@test "lib log: basic error logging with BASH_IT_LOG_LEVEL_ALL" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ALL

  run _log_error "test test test"
  assert_output " [ ERROR ] [CORE] test test test"
}

@test "lib log: basic debug logging with BASH_IT_LOG_LEVEL_WARNING" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_WARNING

  run _log_debug "test test test"
  refute_output
}

@test "lib log: basic warning logging with BASH_IT_LOG_LEVEL_WARNING" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_WARNING

  run _log_warning "test test test"
  assert_output " [ WARNING ] [CORE] test test test"
}

@test "lib log: basic error logging with BASH_IT_LOG_LEVEL_WARNING" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_WARNING

  run _log_error "test test test"
  assert_output " [ ERROR ] [CORE] test test test"
}


@test "lib log: basic debug logging with BASH_IT_LOG_LEVEL_ERROR" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ERROR

  run _log_debug "test test test"
  refute_output
}

@test "lib log: basic warning logging with BASH_IT_LOG_LEVEL_ERROR" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ERROR

  run _log_warning "test test test"
  refute_output
}

@test "lib log: basic error logging with BASH_IT_LOG_LEVEL_ERROR" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ERROR

  run _log_error "test test test"
  assert_output " [ ERROR ] [CORE] test test test"
}

@test "lib log: basic debug silent logging" {
  run _log_debug "test test test"
  refute_output
}

@test "lib log: basic warning silent logging" {
  run _log_warning "test test test"
  refute_output
}

@test "lib log: basic error silent logging" {
  run _log_error "test test test"
  refute_output
}

@test "lib log: logging with prefix" {
  BASH_IT_LOG_LEVEL=$BASH_IT_LOG_LEVEL_ALL
  BASH_IT_LOG_PREFIX="nice: prefix:"

  run _log_debug "test test test"
  assert_output " [ DEBUG ] [nice: prefix:] test test test"
}
