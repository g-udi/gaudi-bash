# #!/usr/bin/env bats

# load ../helper

# load ../../lib/composure

# cite about param example group

# load ../../lib/helpers
# load ../../lib/helpers/bash-it

# local_setup () {
#   setup_test_fixture

#   # Copy the test fixture to the bash-it folder
#   if command -v rsync &> /dev/null
#   then
#     rsync -a "$BASH_IT/test/fixtures/bash_it/" "$BASH_IT/"
#   else
#     find "$BASH_IT/test/fixtures/bash_it" \
#       -mindepth 1 -maxdepth 1 \
#       -exec cp -r {} "$BASH_IT/" \;
#   fi
# }

# @test "bash-it helpers: _bash-it-describe: should display proper table headers" {

#   # Should display plugins help (we are piping to sed to remove redundant white spaces for consistency)
#   _get-description-header () {
#     echo "$(_bash-it-describe "$1")" | head -n 2 | sed 's/  */ /g'
#   }

#   # Make sure the columns headers are capitalized
#   run _get-description-header plugin
#   assert_success
#   assert_line --index 0 "Plugin Enabled? Description"
#   refute_line --index 0 "plugin Enabled? Description"

#   run _get-description-header plugins
#   assert_line --index 0 "Plugin Enabled? Description"
#   refute_line --index 0 "plugin Enabled? Description"

#   run _get-description-header aliases
#   assert_success
#   assert_line --index 0 "Alias Enabled? Description"
#   refute_line --index 0 "alias Enabled? Description"

# }

# @test "bash-it helpers: _bash-it-describe: should display a component name" {
#   run _bash-it-describe plugins
#   assert_success
#   assert_output --partial "base"

# }

# @test "bash-it helpers: _bash-it-describe: should display a component description" {
#   run _bash-it-describe plugins
#   assert_success
#   assert_output --partial "miscellaneous tools"

# }

# @test "bash-it helpers: _bash-it-describe: should list all components (enabled/disabled)" {

#   local BASH_IT_DESCRIPTION_MIN_LINE_COUNT=2

#   # Returns true if the no. lines for description is more than the BASH_IT_DESCRIPTION_MIN_LINE_COUNT
#   _check-results-count () {
#     [[ $(_bash-it-describe "$1" | grep "^.*$" -c) -gt $BASH_IT_DESCRIPTION_MIN_LINE_COUNT ]] && return 0
#     return 1
#   }

#   # Make sure we have a number of results more than 3 (header, separator and base plugin)
#   run _check-results-count plugins
#   assert_success
#   run _check-results-count aliases
#   assert_success
#   run _check-results-count completion
#   assert_success

#   bash-it disable all &> /dev/null
#   run _check-results-count plugins
#   assert_success

# }
