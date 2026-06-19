#!/usr/bin/env bats
# shellcheck shell=bats

load "$GAUDI_TEST_DIRECTORY"/helper.bash

@test "gaudi-bash install: verify that the install script exists" {

	assert_file_exist "$GAUDI_BASH/install.sh"
}

@test "gaudi-bash install: verify that the setup script exists" {

	assert_file_exist "$GAUDI_BASH/setup.sh"
}

@test "gaudi-bash install: run the install script silently by skipping prompts" {

	run ./setup.sh --silent
	[[ -z $output ]]
}

@test "gaudi-bash install: run the install script silently and check that config file exists" {

	cd "$GAUDI_BASH"

	./setup.sh --silent
	assert_file_exist "$HOME/$GAUDI_BASH_PROFILE"
}

@test "gaudi-bash install: run the install script silently and enable sane defaults" {

	cd "$GAUDI_BASH"

	./setup.sh --silent

	assert_file_exist "$GAUDI_BASH/components/enabled/150___general.aliases.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/250___base.plugins.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/350___gaudi-bash.completions.bash"
	assert_file_exist "$GAUDI_BASH/components/enabled/325___system.completions.bash"
}

@test "gaudi-bash install: run the install script silently and don't modify configs" {
	rm -rf "${HOME:?}/${GAUDI_BASH_PROFILE:?}"

	cd "$GAUDI_BASH"
	./setup.sh --silent --no-modify-config

	assert_file_not_exist "$HOME/${GAUDI_BASH_PROFILE}"
}

@test "gaudi-bash install: setup defaults GAUDI_BASH from the setup script directory" {

	local repo="$GAUDI_BASH"

	run env -u GAUDI_BASH HOME="$HOME" "$repo/setup.sh" --silent --basic
	assert_success

	assert_file_exist "$HOME/$GAUDI_BASH_PROFILE"
	run grep -F "export GAUDI_BASH=\"$repo\"" "$HOME/$GAUDI_BASH_PROFILE"
	assert_success
}

@test "gaudi-bash install: sourced setup resolves the setup script directory" {

	local wrapper="$BATS_TEST_TMPDIR/source-setup.sh"

	cat > "$wrapper" << WRAPPER
#!/usr/bin/env bash
source "$GAUDI_BASH/setup.sh" --silent --basic
WRAPPER
	chmod +x "$wrapper"

	run "$wrapper"
	assert_success

	assert_file_exist "$HOME/$GAUDI_BASH_PROFILE"
	run grep -F "export GAUDI_BASH=\"$GAUDI_BASH\"" "$HOME/$GAUDI_BASH_PROFILE"
	assert_success
}

@test "gaudi-bash install: setup rejects unknown options" {

	run "$GAUDI_BASH/setup.sh" --not-a-real-option
	assert_failure
	assert_output --partial "Unknown argument: --not-a-real-option"
}

@test "gaudi-bash install: installer executes cloned setup" {

	local fakebin="$BATS_TEST_TMPDIR/fakebin"
	local install_home="$BATS_TEST_TMPDIR/install-home"

	mkdir -p "$fakebin" "$install_home"
	cat > "$fakebin/git" << 'GIT'
#!/usr/bin/env bash
if [[ "$1" == "clone" ]]; then
	destination=""
	for arg in "$@"; do
		destination="$arg"
	done

	mkdir -p "$destination"
	tar -C "$GAUDI_BASH_ORIGIN" \
		--exclude='.git' \
		--exclude='test/gaudi-bash' \
		-cf - . | tar -C "$destination" -xf -
	exit 0
fi

exit 1
GIT
	chmod +x "$fakebin/git"

	run env PATH="$fakebin:$PATH" HOME="$install_home" "$GAUDI_BASH_ORIGIN/install.sh" --silent --basic
	assert_success

	assert_file_exist "$install_home/.gaudi_bash/setup.sh"
	assert_file_exist "$install_home/$GAUDI_BASH_PROFILE"
	run grep -F "export GAUDI_BASH=\"$install_home/.gaudi_bash\"" "$install_home/$GAUDI_BASH_PROFILE"
	assert_success
}

@test "gaudi-bash install: verify that a backup file is created" {

	local md5_orig
	local md5_bak

	cd "$GAUDI_BASH" || exit

	touch "$HOME/$GAUDI_BASH_PROFILE"
	echo "test file content" > "$HOME/$GAUDI_BASH_PROFILE"
	md5_orig=$(md5sum "$HOME/$GAUDI_BASH_PROFILE" | awk '{print $1}')

	./setup.sh --silent

	assert_file_exist "$HOME/$GAUDI_BASH_PROFILE"
	assert_file_exist "$HOME/$GAUDI_BASH_PROFILE.bak"

	md5_bak=$(md5sum "$HOME/$GAUDI_BASH_PROFILE.bak" | awk '{print $1}')

	assert_equal "$md5_orig" "$md5_bak"
}
