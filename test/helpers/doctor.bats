# #!/usr/bin/env bats
# # shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

local_setup() {
	load_gaudi_libs gaudi-bash doctor

	"$GAUDI_BASH/setup.sh" --silent
	load "$GAUDI_BASH"/gaudi_bash.sh
}

@test "gaudi-bash helpers: doctor: _gaudi-bash-doctor should show all logs by default" {

	run gaudi-bash doctor
	assert_success
}

@test "gaudi-bash helpers: doctor: _gaudi-bash-doctor should show only warning logs" {

	run _gaudi-bash-doctor warning
	assert_success
}

@test "gaudi-bash helpers: doctor: _gaudi-bash-doctor should only error logs" {

	run _gaudi-bash-doctor errors
	assert_success
	refute_output
}
