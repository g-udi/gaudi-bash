#!/usr/bin/env bash
# shellcheck shell=bash

GAUDI_BASH_COMPONENT_TYPES=(plugins aliases completions)

# Component-specific functions (component is either an alias, a plugin, or a completion).

# @function     __check-function-parameters
# @description  check the passed parameter to make sure its valid and matches a component type
# @param $1     component: the component type (plugin, alias, completion)
# @return       success (0) or failure status (1)
# @example      ❯ __check-function-parameters plugin
__check-function-parameters() {
	about "check the passed parameter to make sure its valid and matches a component type"
	group "gaudi-bash:core:components"

	[[ -z "$1" ]] && return 1
	_array-contains "$(_gaudi-bash-pluralize-component "${1}")" "${GAUDI_BASH_COMPONENT_TYPES[@]}" && return 0
	return 1
}

# @function     _gaudi-bash-pluralize-component
# @description  pluralize component name for consistency especially for search
# @param $1     component: the component type (plugin, alias, completion)
# @return       plural form of the component type
# @example      ❯ _gaudi-bash-pluralize-component plugin
_gaudi-bash-pluralize-component() {
	about "pluralize component name for consistency especially for search"
	group "gaudi-bash:core:components"

	local component="${1}"
	local len=$((${#component} - 1))

	[[ -n $component ]] || return 1

	[[ ${component:${len}:1} != 's' ]] && component="${component}s"
	[[ ${component} == "alias" ]] && component="aliases"

	printf "%s" "${component}"
}

# @function     _gaudi-bash-singularize-component
# @description  singularize component name for consistency especially for search
# @param $1     component: the component type (plugin, alias, completion)
# @return       singular form of the component type
# @example      ❯ _gaudi-bash-singularize-component plugins
_gaudi-bash-singularize-component() {
	about "singularize component name for consistency especially for search"
	group "gaudi-bash:core:components"

	__check-function-parameters "$1" || return 1

	local component="${1}"
	local component_singular

	# Handle aliases -> alias and plugins -> plugin, etc.
	[[ "$component" == *es ]] && component_singular=${component%es}
	[[ "$component" == *ns ]] && component_singular=${component%s}

	printf "%s" "${component_singular:-$component}"
}

# @function     _gaudi-bash-component-enabled-file
# @description  finds the enabled file (the link in components/enabled) of a component, whatever its load priority
#               this is the one place that knows how an enabled component is named: <priority>___<name>.<type>.bash
# @param $1     type: the component type in its plural form (plugins, aliases, completions)
# @param $2     component: the component name
# @return       path of the enabled file and a success status (0), or a fail status (1) when the component is not enabled
# @example      ❯ _gaudi-bash-component-enabled-file plugins git
_gaudi-bash-component-enabled-file() {
	about "finds the enabled file of a component, whatever its load priority"
	group "gaudi-bash:core:components"

	[[ -n "$1" && -n "$2" ]] || return 1

	local file
	for file in "${GAUDI_BASH}/components/enabled/"*"${GAUDI_BASH_LOAD_PRIORITY_SEPARATOR:-___}${2}.${1}.bash"; do
		# A link whose target is gone still counts, so that it can be disabled
		[[ -e "$file" || -L "$file" ]] || continue
		printf "%s" "$file"
		return 0
	done
	return 1
}

# @function     _gaudi-bash-component-link-target
# @description  prints what the link of an enabled component points to: a path relative to components/enabled,
#               so that the link keeps working when the installation is moved or renamed
# @param $1     type: the component type in its plural form (plugins, aliases, completions)
# @param $2     file: the file name of the component, e.g., git.plugins.bash
# @return       the link target, e.g., ../plugins/lib/git.plugins.bash
# @example      ❯ _gaudi-bash-component-link-target plugins git.plugins.bash
_gaudi-bash-component-link-target() {
	printf '%s' "../${1}/lib/${2}"
}

# @function     _gaudi-bash-migrate-enabled-links
# @description  rewrites the links in components/enabled that older versions made with an absolute path, and the
#               ones that point to a missing file, as relative links to the component of the same name
#               links that point somewhere else on purpose (an existing file outside this installation) are left alone
# @return       a line per rewritten link, and a line per link that has no component to point to
# @example      ❯ _gaudi-bash-migrate-enabled-links
_gaudi-bash-migrate-enabled-links() {
	about "rewrites absolute and broken links of enabled components as relative links"
	group "gaudi-bash:core:components"

	local separator="${GAUDI_BASH_LOAD_PRIORITY_SEPARATOR:-___}"
	local link file type component target count=0

	for link in "${GAUDI_BASH}"/components/enabled/*.bash; do
		[[ -L "$link" ]] || continue

		file="${link##*/}"
		file="${file#*"${separator}"}"
		type="${file%.bash}"
		type="${type##*.}"
		component="${GAUDI_BASH}/components/${type}/lib/${file}"
		target="$(readlink "$link")"

		if [[ -e "$link" ]]; then
			# A working link is only rewritten when it is an absolute path to this installation's own component
			[[ "$target" == /* && "$link" -ef "$component" ]] || continue
		elif [[ ! -e "$component" ]]; then
			printf '%s\n' "${link##*/} points to a missing file and there is no such component, remove it with: gbash disable $(_gaudi-bash-singularize-component "$type") ${file%%.*}"
			continue
		fi

		target="$(_gaudi-bash-component-link-target "$type" "$file")"
		rm -f "$link"
		ln -s "$target" "$link" || continue
		printf '%s\n' "migrated ${link##*/} -> ${target}"
		count=$((count + 1))
	done

	[[ $count -gt 0 ]] || printf '%s\n' "Nothing to migrate, every enabled component is linked with a relative path"
	return 0
}

# @function     _gaudi-bash-component-descriptions
# @description  lists every item of a component type with its composure about description, one "<name><tab><description>" per line
#               the list is read from the component files (components/<type>/lib/*.bash) and cached, since reading the
#               descriptions is the slow part; the cache is rebuilt when a component file is newer than it
#               whether an item is enabled is never cached, it is always looked up in components/enabled
# @param $1     type: the component type (plugin, alias, completion)
# @return       list of "<name><tab><description>" lines
# @example      ❯ _gaudi-bash-component-descriptions plugins
_gaudi-bash-component-descriptions() {
	about "lists every item of a component type with its about description"
	group "gaudi-bash:core:components"

	__check-function-parameters "$1" || return 1

	local type type_singular directory cache file name about_text descriptions stale newline=$'\n'
	local -a files=()

	type=$(_gaudi-bash-pluralize-component "$1")
	type_singular=$(_gaudi-bash-singularize-component "$type")
	directory="${GAUDI_BASH}/components/${type}/lib"
	cache=$(_gaudi-bash-component-cache-add "${type}-descriptions")

	for file in "$directory"/*.bash; do
		[[ -e "$file" ]] && files+=("$file")
	done

	[[ -s "$cache" && ! "$directory" -nt "$cache" ]] || stale=true
	for file in "${files[@]}"; do
		[[ -n "${stale:-}" ]] && break
		[[ "$file" -nt "$cache" ]] && stale=true
	done

	if [[ -z "${stale:-}" ]]; then
		cat "$cache"
		return 0
	fi

	for file in "${files[@]}"; do
		name="${file##*/}"
		name="${name%%.*}"
		about_text="$(metafor about-"$type_singular" < "$file")"
		descriptions+="${name}"$'\t'"${about_text%%"$newline"*}${newline}"
	done

	# A cache that can not be written only costs time on the next call
	printf "%s" "${descriptions:-}" > "$cache" 2> /dev/null || true
	printf "%s" "${descriptions:-}"
}

# @function     _gaudi-bash-component-help
# @description  show the about description for a component
#               if no component is passed then the descriptions of all components of the passed type will be shown
# @param $1     type: the component type (plugin, alias, completion)
# @param $2     component: the component name
# @return       component name and description, fail status (1) when the component does not exist
# @example      ❯ _gaudi-bash-component-help plugins git
_gaudi-bash-component-help() {
	about "show the about description for a component"
	group "gaudi-bash:core:components"

	__check-function-parameters "$1" || return 1

	local name about_text found

	while IFS=$'\t' read -r name about_text; do
		[[ -n "$name" ]] || continue
		[[ -z "${2:-}" || "$name" == "$2" ]] || continue
		printf "%-20s%s\n" "$name" "$about_text"
		found=true
	done < <(_gaudi-bash-component-descriptions "$1")

	[[ -n "${found:-}" ]]
}

# @function     _gaudi-bash-component-list
# @description  returns a list of items within each component (plugin, alias, completion)
#               the list is the files found in components/<type>/lib
# @param $1     type: the component type (plugin, alias, completion)
# @return       <array> list of components
# @example      ❯ _gaudi-bash-component-list plugins
_gaudi-bash-component-list() {
	about "returns a list of items within each component (plugin, alias, completion)"
	group "gaudi-bash:core:components"

	__check-function-parameters "$1" || return 1

	local type file

	type=$(_gaudi-bash-pluralize-component "$1")
	for file in "${GAUDI_BASH}/components/${type}/lib/"*.bash; do
		[[ -e "$file" ]] || continue
		file="${file##*/}"
		printf "%s " "${file%%.*}"
	done
}

# @function     _gaudi-bash-component-list-matching
# @description  returns a list of items within each component (plugin, alias, completion) that match a string
#               an item matches when its name or its description contains the string (case insensitive, extended regular expression)
# @param $1     type: the component type (plugin, alias, completion)
# @param $2     component: the component name (search string) to match against
# @return       <array> list of matched components
# @example      ❯ _gaudi-bash-component-list-matching plugins git
_gaudi-bash-component-list-matching() {
	about "returns a list of items within each component (plugin, alias, completion) that match a string"
	group "gaudi-bash:core:components"

	__check-function-parameters "$1" || return 1
	[[ -n "$2" ]] || return 1

	local term name about_text match

	term=$(printf "%s" "$2" | tr "[:upper:]" "[:lower:]")
	while IFS=$'\t' read -r name about_text; do
		[[ -n "$name" ]] || continue
		[[ "${name} ${about_text}" =~ $term ]] && match+="${name} "
	done < <(_gaudi-bash-component-descriptions "$1" | tr "[:upper:]" "[:lower:]")

	[[ -n "${match:-}" ]] && echo "$match" && return 0
	return 1
}

# @function     _gaudi-bash-component-list-enabled
# @description  returns a list of enabled items within each component (plugin, alias, completion)
#               the list is the links found in components/enabled
# @param $1     type: the component type (plugin, alias, completion)
# @return       <array> list of enabled components
# @example      ❯ _gaudi-bash-component-list-enabled plugins
_gaudi-bash-component-list-enabled() {
	about "returns a list of enabled items within each component (plugin, alias, completion)"
	group "gaudi-bash:core:components"

	__check-function-parameters "$1" || return 1

	local type file

	type=$(_gaudi-bash-pluralize-component "$1")
	# The enabled files are ordered by load priority, the list is ordered by name
	for file in "${GAUDI_BASH}/components/enabled/"*"${GAUDI_BASH_LOAD_PRIORITY_SEPARATOR:-___}"*".${type}.bash"; do
		[[ -e "$file" || -L "$file" ]] || continue
		file="${file##*/}"
		file="${file#*"${GAUDI_BASH_LOAD_PRIORITY_SEPARATOR:-___}"}"
		printf "%s\n" "${file%%.*}"
	done | sort | tr '\n' ' '
}

# @function     _gaudi-bash-component-list-disabled
# @description  returns a list of disabled items within each component (plugin, alias, completion)
# @param $1     type: the component type (plugin, alias, completion)
# @return       <array> list of disabled components
# @example      ❯ _gaudi-bash-component-list-disabled plugins
_gaudi-bash-component-list-disabled() {
	about "returns a list of disabled items within each component (plugin, alias, completion)"
	group "gaudi-bash:core:components"

	__check-function-parameters "$1" || return 1

	local type name

	type=$(_gaudi-bash-pluralize-component "$1")
	for name in $(_gaudi-bash-component-list "$type"); do
		_gaudi-bash-component-enabled-file "$type" "$name" > /dev/null || printf "%s " "$name"
	done
}

# @function     _gaudi-bash-component-item-is-enabled
# @description  checks if a given item is enabled for a particular component/file-type
# @param $1     type: the component type (plugin, alias, completion)
# @param $2     component: the component name to check
# @return       success status (0) if an item of the component is enabled, fail status (1) otherwise.
# @example      ❯ _gaudi-bash-component-item-is-enabled alias git && echo "git alias is enabled"
_gaudi-bash-component-item-is-enabled() {
	about "checks if a given item is enabled for a particular component/file-type"
	group "gaudi-bash:core:components"

	__check-function-parameters "$1" || return 1
	[[ -n "$2" ]] || return 1

	_gaudi-bash-component-enabled-file "$(_gaudi-bash-pluralize-component "$1")" "$2" > /dev/null
}

# @function     _gaudi-bash-component-item-is-disabled
# @description  checks if a given item is disabled for a particular component/file-type
#               an item that does not exist is neither enabled nor disabled
# @param $1     type: the component type (plugin, alias, completion)
# @param $2     component: the component name to check
# @return       success status (0) if an item of the component is disabled, fail status (1) otherwise.
# @example      ❯ _gaudi-bash-component-item-is-disabled alias git && echo "git aliases are disabled"
_gaudi-bash-component-item-is-disabled() {
	about "checks if a given item is disabled for a particular component/file-type"
	group "gaudi-bash:core:components"

	__check-function-parameters "$1" || return 1
	[[ -n "$2" ]] || return 1

	local type

	type=$(_gaudi-bash-pluralize-component "$1")
	[[ -e "${GAUDI_BASH}/components/${type}/lib/${2}.${type}.bash" ]] || return 1
	! _gaudi-bash-component-enabled-file "$type" "$2" > /dev/null
}
