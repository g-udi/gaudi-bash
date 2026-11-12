#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2207

# @function _gaudi-bash-search
# @description  returns list of aliases, plugins and completions in gaudi-bash
#               name or description should match one of the search terms provided as arguments
# @usage:
#    ❯ gbash search [-|@]term1 [-|@]term2 ... \
#       [[ --enable ]] \
#       [[ --disable ]] \
#       [[ --no-color   | -x ]] \
#       [[ --refresh    | -r ]] \
#       [[ --alias      | -a ]] \
#       [[ --plugin     | -p ]] \
#       [[ --completion | -c ]] \
#       [[ --help       | -h ]]
#
#    Single dash, as in "-chruby", indicates a negative search term.
#    Double dash indicates a command or option that is applied to the search.
#    --enable and --disable have no short form (a single dash is a negative term).
#    An '@' sign indicates an exact (not partial) match.
#
# @example
#    ❯ gbash search ruby rbenv rvm gem rake
#          aliases:  bundler
#          plugins:  chruby rbenv ruby rvm
#      completions:  gem rake rvm
#
#    ❯ gbash search ruby rbenv rvm gem rake -chruby
#          aliases:  bundler
#          plugins:  rbenv ruby rvm
#      completions:  gem rake rvm
#
# Examples of enabling or disabling results of the search:
#
#    ❯ gbash search ruby
#          aliases:  bundler
#          plugins:  chruby ruby
#
#    ❯ gbash search ruby -chruby --enable
#          aliases:  bundler
#          plugins:  ruby
#
# Examples of using exact match:
#
#    ❯ gbash search @git @ruby
#          aliases:  git
#          plugins:  git ruby
#      completions:  git
#

_gaudi-bash-search() {
	about "searches for given terms amongst gaudi-bash plugins, aliases and completions"
	group "gaudi-bash:search"

	local GAUDI_BASH_SEARCH_USE_COLOR="${GAUDI_BASH_SEARCH_USE_COLOR:-true}"
	local COMPONENT component word found=""
	local -a GAUDI_BASH_COMPONENTS=(aliases plugins completions)

	if [[ -z "$*" ]]; then
		_gaudi-bash-search-help
		return 0
	fi

	local -a args=()
	for word in "$@"; do
		case "${word}" in
			'-h' | '--help')
				_gaudi-bash-search-help
				return 0
				;;
			'-r' | '--refresh')
				_gaudi-bash-component-cache-clean
				;;
			'-x' | '--no-color')
				GAUDI_BASH_SEARCH_USE_COLOR=false
				;;
			'-p' | '--plugin')
				COMPONENT="plugins"
				;;
			'-a' | '--alias')
				COMPONENT="aliases"
				;;
			'-c' | '--completion')
				COMPONENT="completions"
				;;
			*)
				args+=("${word}")
				;;
		esac
	done

	[[ ${#args[@]} -gt 0 ]] || return 0

	# The search succeeds when one of the component types has a match
	if [[ -n $COMPONENT ]]; then
		_gaudi-bash-search-component "${COMPONENT}" "${args[@]}" && found=true
	else
		for component in "${GAUDI_BASH_COMPONENTS[@]}"; do
			_gaudi-bash-search-component "${component}" "${args[@]}" && found=true
		done
	fi

	if [[ -z "$found" ]]; then
		printf "%s\n" "No components match your search"
		return 1
	fi
	return 0
}

# @function     _gaudi-bash-component-term-matches-negation
# @description  matches the negation of the search term entered
# @param $1     search match: the search results matches
# @param $2     negation terms <array>: the terms we need to negate/remove from the search matches (result set)
# @return       String of search results without the negated terms
# @example      ❯ _gaudi-bash-component-term-matches-negation "${match}" "${negative_terms[@]}"
_gaudi-bash-component-term-matches-negation() {
	about "matches the negation of the search term entered"
	group "gaudi-bash:search"

	local match="$1"
	shift
	local negative

	for negative in "$@"; do
		[[ "${match}" =~ ${negative} ]] && return 0
	done
	return 1
}

# @function     _gaudi-bash-search-component
# @description  searches a component to match the search terms
# @param $1     component: the component to search in e.g., alias, completion, plugin
# @param $2     search terms: the terms we want to search for
# @return       Results that match our search term
# @example      ❯ _gaudi-bash-search-component aliases @git rake bundler -chruby
_gaudi-bash-search-component() {
	about "searches for given terms amongst a given component"
	group "gaudi-bash:search"

	local component="$1" && shift

	# If one of the search terms is --enable or --disable, we will apply this action to the matches further down.
	local action

	if _array-contains "--enable" "$@"; then
		action="enable"
	elif _array-contains "--disable" "$@"; then
		action="disable"
	fi

	local -a terms=("$@")

	# Terms that should be included only if they match exactly
	local -a exact_terms=()
	# Terms that should be included if they match partially
	local -a partial_terms=()
	# Negated partial terms that should be excluded
	local -a negative_terms=()

	# The component list is the list/array of all components for each category (alias, plugin and completion)
	local -a component_list=($(_gaudi-bash-component-list "${component}"))
	local term line match

	for term in "${terms[@]}"; do
		local search_term="${term:1}"
		if [[ "${term:0:2}" == "--" ]]; then
			continue
		elif [[ "${term:0:1}" == "-" ]]; then
			negative_terms+=("${search_term}")
		elif [[ "${term:0:1}" == "@" ]]; then
			if _array-contains "${search_term}" "${component_list[@]:-}"; then
				exact_terms+=("${search_term}")
			fi
		else
			while IFS='' read -r line; do
				partial_terms+=("$line")
			done < <(_gaudi-bash-component-list-matching "${component}" "${term}")
		fi
	done

	local -a total_matches=($(_array-dedupe "${exact_terms[@]}" "${partial_terms[@]}"))

	[[ ${#total_matches[@]} -eq 0 ]] && return 1

	local -a matches=()
	for match in "${total_matches[@]}"; do
		if [[ ${#negative_terms[@]} -gt 0 ]] && _gaudi-bash-component-term-matches-negation "${match}" "${negative_terms[@]}"; then
			continue
		fi
		matches+=("${match}")
	done

	[[ ${#matches[@]} -eq 0 ]] && return 1

	if [[ -n "${action:-}" ]]; then
		# The action runs in this shell (so that a plugin's disable callback takes effect) with its own reload
		# switched off: the shell is reloaded once, after every match was handled
		for match in "${matches[@]}"; do
			GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE="" _gaudi-bash-"$action" "$component" "$match" > /dev/null
		done
		if [[ -n "$GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE" ]]; then
			_gaudi-bash-reload-after-change
		fi
	fi

	_gaudi-bash-search-print-result "${component}" "${matches[@]}"
}

# @function     _gaudi-bash-search-print-result
# @description  prints the results of search result
# @param $1     component: the component that was searched e.g., aliases, completions, plugins
# @param $2     matches <array>: the names of the components that matched the search
# @return       print the search results formatted and colored
# @example      ❯ _gaudi-bash-search-print-result "${component}" "${matches[@]}"
_gaudi-bash-search-print-result() {
	local component="$1" && shift
	local -a matches=("$@")
	local match use_color=""

	[[ "${GAUDI_BASH_SEARCH_USE_COLOR}" == "true" ]] && use_color=true

	if [[ "${#matches[@]}" -gt 0 ]]; then

		if [[ -n "$use_color" ]]; then
			printf "${YELLOW}%s:${NC}\t" "${component}"
		else
			printf "%s:\t" "${component}"
		fi

		for match in "${matches[@]}"; do
			if _gaudi-bash-component-item-is-enabled "${component}" "${match}"; then
				if [[ -n "$use_color" ]]; then
					match="${GREEN}${match} ✓${NC}"
				else
					match="${match} ✓"
				fi
			fi
			if [[ -n "$use_color" ]]; then
				echo -ne "${CYAN}$match  ${NC}"
			else
				printf "%s\t" "$match"
			fi
		done

		printf "\n"
	fi
}

# @function     _gaudi-bash-search-help
# @description  displays the gaudi-bash search help
# @return       Help manual for the search function
_gaudi-bash-search-help() {

	printf "${NC}%b" "

${YELLOW}USAGE${NC}

   gbash search [-|@]term1 [-|@]term2 ... \\
     [[ --enable ]] \\
     [[ --disable ]] \\
     [[ --no-color   | -x ]] \\
     [[ --refresh    | -r ]] \\
     [[ --alias      | -a ]] \\
     [[ --plugin     | -p ]] \\
     [[ --completion | -c ]] \\
     [[ --help       | -h ]]

${YELLOW}DESCRIPTION${NC}

   Use ${GREEN}search${NC} gbash command to search for a list of terms or term negations
   across all components: aliases, completions and plugins. Components that are
   enabled are marked with a check mark (and shown in green unless --no-color is used).

   In addition to simply finding the right component, you can use the results
   of the search to enable or disable all components that the search returns.

   When search is used to enable/disable components it becomes clear that
   you must be able to perform not just a partial match, but an exact match,
   as well as be able to exclude some components.

      * To exclude a component (or all components matching a substring) use
        a search term with minus as a prefix, eg '-flow'

      * To perform an exact match, use character '@' in front of the term,
        eg. '@git' would only match aliases, plugins and completions named 'git'.

${YELLOW}FLAGS${NC}
   --enable             ${MAGENTA}Enable all matching components${NC}
   --disable            ${MAGENTA}Disable all matching components${NC}
   --help       | -h    ${MAGENTA}Print this help${NC}
   --refresh    | -r    ${MAGENTA}Force a refresh of the search cache${NC}
   --no-color   | -x    ${MAGENTA}Disable color output and use monochrome text${NC}
   --alias      | -a    ${MAGENTA}Search aliases only${NC}
   --plugin     | -p    ${MAGENTA}Search plugins only${NC}
   --completion | -c    ${MAGENTA}Search completions only${NC}

${YELLOW}EXAMPLES${NC}

   For example, ${GREEN}gbash search git${NC} would match any alias, completion
   or plugin that has the word 'git' in either the module name or
   it's description. You should see something like this when you run this
   command:

         ${GREEN}❯ gbash search git${NC}
               ${YELLOW}aliases:  ${GREEN}git ${NC}gitsvn
               ${YELLOW}plugins:  ${NC}autojump ${GREEN}git ${NC}git-subrepo jgitflow jump
           ${YELLOW}completions:  ${GREEN}git ${NC}git_flow github-cli${NC}

   You can exclude some terms by prefixing a term with a minus, eg:

         ${GREEN}❯ gbash search git -flow -svn${NC}
               ${YELLOW}aliases:  ${NC}git
               ${YELLOW}plugins:  ${NC}autojump git git-subrepo jump
           ${YELLOW}completions:  ${NC}git${NC}

   Finally, if you prefix a term with '@' symbol, that indicates an exact
   match. Note, that we also pass the '--enable' flag, which would ensure
   that all matches are automatically enabled. The example is below:

         ${GREEN}❯ gbash search @git --enable${NC}
               ${YELLOW}aliases:  ${NC}git
               ${YELLOW}plugins:  ${NC}git
           ${YELLOW}completions:  ${NC}git${NC}

${YELLOW}SUMMARY${NC}

   Take advantage of the search functionality to discover what gaudi-bash can do
   for you. Try searching for partial term matches, mix and match with the
   negative terms, or specify an exact matches of any number of terms. Once
   you created the search command that returns ONLY the modules you need,
   simply append '--enable' or '--disable' at the end to activate/deactivate
   each module.

"
}
