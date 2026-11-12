#!/usr/bin/env bash
# shellcheck shell=bash

# @function     _gaudi-bash-profile-write
# @description  writes the enabled components to a profile file, one "<type> <name>" line per component
#               an existing file is replaced
# @param $1     file: path of the profile file to write
# @return       fail status (1) when the file can not be written
# @example      ❯ _gaudi-bash-profile-write "$GAUDI_BASH/profiles/mysetup.gaudi-bash"
_gaudi-bash-profile-write() {
	about "writes the enabled components to a profile file"
	group "gaudi-bash:core"

	local profile_file="$1" _file _component _type

	[[ -n "$profile_file" ]] || return 1

	mkdir -p "${profile_file%/*}" || return 1
	: > "${profile_file}" || return 1

	for _file in "${GAUDI_BASH}"/components/enabled/*.bash; do
		# Nothing is enabled when the pattern itself comes back
		[[ -e "$_file" || -L "$_file" ]] || continue

		_component="${_file##*"$GAUDI_BASH_LOAD_PRIORITY_SEPARATOR"}"
		_component="${_component%.bash}"
		_type=$(_gaudi-bash-singularize-component "${_component##*.}") || continue
		_component=${_component%%.*}

		printf "%s\n" "${_type} ${_component}" >> "${profile_file}"
	done
}

# @function     _gaudi-bash-profile-valid-name
# @description  checks a profile name: letters, digits, "_" and "-" only, so that a profile is always a file
#               directly under $GAUDI_BASH/profiles
# @param $1     name: the profile name
# @return       fail status (1) and a message when the name is not valid
# @example      ❯ _gaudi-bash-profile-valid-name mysetup
_gaudi-bash-profile-valid-name() {
	[[ "$1" =~ ^[a-zA-Z0-9_-]+$ ]] && return 0
	printf "${RED}%s${NC}\n" "A profile name can only hold letters, digits, '_' and '-'"
	return 1
}

# @function     _gaudi-bash-profile-save
# @description  saves the current enabled components to a named profile
#               writes each enabled component as "<type> <name>" to $GAUDI_BASH/profiles/<name>.gaudi-bash
# @param $1     name: the profile name to save as
# @return       message to indicate the outcome
# @example      ❯ _gaudi-bash-profile-save mysetup
_gaudi-bash-profile-save() {
	about "saves current enabled components to a named profile"
	group "gaudi-bash:core"

	local profile_name="$1"

	[[ -z "$profile_name" ]] && printf "${RED}%s${NC}\n" "Please provide a profile name" && return 1
	_gaudi-bash-profile-valid-name "$profile_name" || return 1

	local profile_dir="${GAUDI_BASH}/profiles"
	local profile_file="${profile_dir}/${profile_name}.gaudi-bash"

	if [[ -f "$profile_file" ]]; then
		_read_input "Profile '${profile_name}' already exists. Overwrite? [yY/nN]"
		if [[ ! $REPLY =~ ^[yY]$ ]]; then
			printf "${CYAN}%s${NC}\n" "Profile save cancelled"
			return 0
		fi
	fi

	local _count

	_gaudi-bash-profile-write "${profile_file}" || return 1
	_count=$(wc -l < "${profile_file}" | tr -d ' ')

	printf "${GREEN}%s${NC} %s ${CYAN}%s${NC} %s\n" "Profile saved:" "${_count} component(s) written to" "${profile_name}" "(${profile_file})"

	return 0
}

# @function     _gaudi-bash-profile-load
# @description  loads a named profile by disabling all components and re-enabling from profile
#               validates the profile file before applying changes: every line has to be "<type> <name>" and
#               name a component that exists
# @param $1     name: the profile name to load
# @return       message to indicate the outcome
# @example      ❯ _gaudi-bash-profile-load mysetup
_gaudi-bash-profile-load() {
	about "loads a named profile by disabling all components and re-enabling from profile"
	group "gaudi-bash:core"

	local profile_name="$1"

	[[ -z "$profile_name" ]] && printf "${RED}%s${NC}\n" "Please provide a profile name" && return 1
	_gaudi-bash-profile-valid-name "$profile_name" || return 1

	local profile_file="${GAUDI_BASH}/profiles/${profile_name}.gaudi-bash"

	if [[ ! -f "$profile_file" ]]; then
		printf "${RED}%s ${CYAN}%s${RED}%s${NC}\n" "Profile" "${profile_name}" " not found"
		return 1
	fi

	# Dry run: validate all entries in the profile
	local _line_num=0
	local _errors=0
	local line file_type _type _component _plural _failed=""

	while IFS= read -r line || [[ -n "$line" ]]; do
		_line_num=$((_line_num + 1))
		# Skip empty lines
		[[ -z "$line" ]] && continue
		# Validate format: "<type> <name>"
		if [[ ! "$line" =~ ^(alias|plugin|completion)[[:space:]]+([a-zA-Z0-9_-]+)$ ]]; then
			printf "${RED}%s${NC} %s: %s\n" "Invalid entry" "line ${_line_num}" "${line}"
			_errors=$((_errors + 1))
			continue
		fi
		# The component has to exist, otherwise everything would be disabled for a profile that can not be loaded
		_plural="$(_gaudi-bash-pluralize-component "${BASH_REMATCH[1]}")"
		if [[ ! -e "${GAUDI_BASH}/components/${_plural}/lib/${BASH_REMATCH[2]}.${_plural}.bash" ]]; then
			printf "${RED}%s${NC} %s: %s\n" "Unknown component" "line ${_line_num}" "${line}"
			_errors=$((_errors + 1))
		fi
	done < "${profile_file}"

	if [[ $_errors -gt 0 ]]; then
		printf "${RED}%s${NC} %s\n" "Profile validation failed:" "${_errors} invalid entry/entries found. Aborting."
		return 1
	fi

	printf "${MAGENTA}%s ${CYAN}%s${MAGENTA}%s${NC}\n" "Loading profile" "${profile_name}" "..."

	# Disable all currently enabled components
	for file_type in "aliases" "plugins" "completions"; do
		_gaudi-bash-disable "$file_type" "all"
	done

	# Re-enable components from profile
	while IFS= read -r line || [[ -n "$line" ]]; do
		[[ -z "$line" ]] && continue
		read -r _type _component <<< "$line"
		_gaudi-bash-enable "$(_gaudi-bash-pluralize-component "$_type")" "$_component" || _failed=true
	done < "${profile_file}"

	if [[ -n "$_failed" ]]; then
		printf "${RED}%s ${CYAN}%s${RED}%s${NC}\n" "Profile" "${profile_name}" " was loaded only in part, see the messages above"
		return 1
	fi

	printf "${GREEN}%s ${CYAN}%s${GREEN}%s${NC}\n" "Profile" "${profile_name}" " loaded successfully"

	return 0
}

# @function     _gaudi-bash-profile-list
# @description  lists all available profiles from $GAUDI_BASH/profiles/
# @return       list of profile names
# @example      ❯ _gaudi-bash-profile-list
_gaudi-bash-profile-list() {
	about "lists all available gaudi-bash profiles"
	group "gaudi-bash:core"

	local profile_dir="${GAUDI_BASH}/profiles" _profile

	if [[ ! -d "$profile_dir" ]] || [[ -z "$(command ls -A "${profile_dir}"/*.gaudi-bash 2> /dev/null)" ]]; then
		printf "${CYAN}%s${NC}\n" "No profiles found"
		return 0
	fi

	printf "${GREEN}%s${NC}\n" "Available profiles:"

	for _profile in "${profile_dir}"/*.gaudi-bash; do
		local _name _count
		_name="$(basename "$_profile" .gaudi-bash)"
		_count=$(wc -l < "$_profile" | tr -d ' ')
		printf "  ${CYAN}%s${NC} (%s component(s))\n" "$_name" "$_count"
	done

	return 0
}

# @function     _gaudi-bash-profile-rm
# @description  removes a named profile
# @param $1     name: the profile name to remove
# @return       message to indicate the outcome
# @example      ❯ _gaudi-bash-profile-rm mysetup
_gaudi-bash-profile-rm() {
	about "removes a named gaudi-bash profile"
	group "gaudi-bash:core"

	local profile_name="$1"

	[[ -z "$profile_name" ]] && printf "${RED}%s${NC}\n" "Please provide a profile name to remove" && return 1
	_gaudi-bash-profile-valid-name "$profile_name" || return 1

	local profile_file="${GAUDI_BASH}/profiles/${profile_name}.gaudi-bash"

	if [[ ! -f "$profile_file" ]]; then
		printf "${RED}%s ${CYAN}%s${RED}%s${NC}\n" "Profile" "${profile_name}" " not found"
		return 1
	fi

	rm "${profile_file}"
	printf "${GREEN}%s ${CYAN}%s${GREEN}%s${NC}\n" "Profile" "${profile_name}" " removed"

	return 0
}

# @function     _gaudi-bash-profile
# @description  dispatches profile subcommands (save, load, list, rm)
# @param $1     action: one of save, load, list, rm
# @param $2     name: the profile name (required for save, load, rm)
# @return       message to indicate the outcome
_gaudi-bash-profile() {
	about "manages gaudi-bash profiles for saving and loading component configurations"
	group "gaudi-bash:core"

	local action="$1"
	shift

	case "$action" in
		save)
			_gaudi-bash-profile-save "$@"
			;;
		load)
			_gaudi-bash-profile-load "$@"
			;;
		list)
			_gaudi-bash-profile-list
			;;
		rm)
			_gaudi-bash-profile-rm "$@"
			;;
		*)
			printf "${RED}%s${NC}\n" "Unknown profile action: ${action:-<none>}"
			printf "%s\n" "Usage: gbash profile [save|load|list|rm] [name]"
			return 1
			;;
	esac
}
