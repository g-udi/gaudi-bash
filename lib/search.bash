#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2034,SC1090,SC2091,SC2207,SC2059

# @function _gaudi-bash-search
# @description  returns list of aliases, plugins and completions in gaudi-bash
#               name or description should match one of the search terms provided as arguments
# @usage:
#    ❯ gaudi-bash search [-|@]term1 [-|@]term2 ... \
#       [[ --enable   | -e ]] \
#       [[ --disable  | -d ]] \
#       [[ --no-color | -c ]] \
#       [[ --refresh  | -r ]] \
#       [[ --help     | -h ]]
#
#    Single dash, as in "-chruby", indicates a negative search term.
#    Double dash indicates a command that is to be applied to the search result.
#    At the moment only --help, --enable and --disable are supported.
#    An '@' sign indicates an exact (not partial) match.
#
# @example
#    ❯ gaudi-bash search ruby rbenv rvm gem rake
#          aliases:  bundler
#          plugins:  chruby rbenv ruby rvm
#      completions:  gem rake rvm
#
#    ❯ gaudi-bash search ruby rbenv rvm gem rake -chruby
#          aliases:  bundler
#          plugins:  rbenv ruby rvm
#      completions:  gem rake rvm
#
# Examples of enabling or disabling results of the search:
#
#    ❯ gaudi-bash search ruby
#          aliases:  bundler
#          plugins:  chruby chruby-auto ruby
#
#    ❯ gaudi-bash search ruby -chruby --enable
#          aliases:  bundler
#          plugins:  ruby
#
# Examples of using exact match:
#
#    ❯ gaudi-bash search @git @ruby
#          aliases:  git
#          plugins:  git ruby
#      completions:  git
#
_gaudi-bash-search() {
	about "searches for given terms amongst gaudi-bash plugins, aliases and completions"
	group "gaudi-bash:search"

	[[ -z "$(type _array-contains 2> /dev/null)" ]]

	local GAUDI_BASH_SEARCH_USE_COLOR="${GAUDI_BASH_SEARCH_USE_COLOR:=true}"
	: "${GAUDI_BASH_GREP:=$(_gaudi-bash-grep)}"
	export GAUDI_BASH_GREP=${GAUDI_BASH_GREP:-$(which egrep)}
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
				_gaudi-bash-clean-component-cache
				;;
			'-c' | '--no-color')
				GAUDI_BASH_SEARCH_USE_COLOR=false
				;;
			*)
				args+=("${word}")
				;;
		esac
	done

	if [[ ${#args} -gt 0 ]]; then
		for component in "${GAUDI_BASH_COMPONENTS[@]}"; do
			_gaudi-bash-search-component "${component}" "${args[@]}"
		done
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

# @function     _gaudi-bash-component-component
# @description  searches a component to match the search terms
# @param $1     component: the component to search in e.g., alias, completion, plugin
# @param $2     search terms: the terms we want to search for
# @return       Results that match our search term
# @example      ❯ _gaudi-bash-search-component aliases @git rake bundler -chruby
_gaudi-bash-search-component() {
	about "searches for given terms amongst a given component"
	group "gaudi-bash:search"

	local component="$1"
	shift

	# If one of the search terms is --enable or --disable, we will apply this action to the matches further down.
	local component_singular action action_func
	local -a search_commands=(enable disable)

	# check if the arguments has a --enable or --disable flags passed
	for search_command in "${search_commands[@]}"; do
		if $(_array-contains "--${search_command}" "$@"); then
			action="${search_command}"
			action_func="_gaudi-bash-${action} ${component}"
			break
		fi
	done

	local -a terms=("$@")

	unset exact_terms
	unset partial_terms
	unset negative_terms

	# Terms that should be included only if they match exactly
	local -a exact_terms=()
	# Terms that should be included if they match partially
	local -a partial_terms=()
	# Negated partial terms that should be excluded
	local -a negative_terms=()

	unset component_list
	local -a component_list=($(_gaudi-bash-component-list "${component}"))
	local term

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

	unset matches
	declare -a matches=()
	for match in "${total_matches[@]}"; do
		local include_match=true

		if [[ ${#negative_terms[@]} -gt 0 ]]; then
			(_gaudi-bash-component-term-matches-negation "${match}" "${negative_terms[@]}") && include_match=false
		fi
		(${include_match}) && matches=("${matches[@]}" "${match}")
	done
	_gaudi-bash-search-print-result "${component}" "${action}" "${action_func}" "${matches[@]}"
	unset matches final_matches terms
}

# @function     _gaudi-bash-search-print-result
# @description  prints the results of search result
# @param $1     component: the component to search in e.g., alias, completion, plugin
# @param $2     action: the action to apply on the results (enable or disable)
# @param $3     action function: the function to apply for the action e.g., _gaudi-bash-enable <component_name>
# @param $4     search terms: the search result terms
# @return       print the search results formatted and colored
# @example      ❯ _gaudi-bash-search-print-result "${component}" "${action}" "${action_func}" "${matches[@]}"
_gaudi-bash-search-print-result() {
	local component="$1"
	shift
	local action="$1"
	shift
	local action_func="$1"
	shift
	local -a matches=("$@")
	local color_component color_enable color_disable color_off

	color_sep=':'

	(${GAUDI_BASH_SEARCH_USE_COLOR}) && {
		color_component="${BLUE}"
		color_enable="${GREEN}"
		suffix_enable=' ✓ '
		suffix_disable=''
		color_disable="${CYAN}"
		color_off="${NC}"
	}

	(${GAUDI_BASH_SEARCH_USE_COLOR}) || {
		color_component=''
		suffix_enable=' ✓ '
		suffix_disable='  '
		color_enable=''
		color_disable=''
		color_off=''
	}

	local match
	local modified=0

	if [[ "${#matches[@]}" -gt 0 ]]; then
		printf "${color_component}%13s${color_sep} ${color_off}" "${component}"

		for match in "${matches[@]}"; do
			local enabled=0

			(_gaudi-bash-component-item-is-enabled "${component}" "${match}") && enabled=1

			local match_color compatible_action suffix opposite_suffix

			(("${enabled}")) && {
				match_color=${color_enable}
				suffix=${suffix_enable}
				opposite_suffix=${suffix_disable}
				compatible_action="disable"
			}

			(("${enabled}")) || {
				match_color=${color_disable}
				suffix=${suffix_disable}
				opposite_suffix=${suffix_enable}
				compatible_action="enable"
			}

			local m="${match}${suffix}"
			local len
			len=${#m}

			printf " ${match_color}${match}${suffix}"
			if [[ "${action}" == "${compatible_action}" ]]; then
				if [[ ${action} == "enable" && ${GAUDI_BASH_SEARCH_USE_COLOR} == false ]]; then
					printf "${match}${suffix}"
				else
					_gaudi-bash-erase-term "${len}"
				fi
				modified=1
				result=$(${action_func} "${match}")
				local temp="color_${compatible_action}"

				match_color=${!temp}
				_gaudi-bash-rewind "${len}"
				printf "${match_color}${match}${opposite_suffix}"
			fi

			printf "${color_off}"
		done

		[[ ${modified} -gt 0 ]] && _gaudi-bash-component-cache-clean "${component}"
		printf "\n"
	fi
}

# @function     _gaudi-bash-search-help
# @description  displays the gaudi-bash search help
# @return       Help manual for the search function
_gaudi-bash-search-help() {

	printf "${NC}%b" "

${YELLOW}USAGE${NC}

   gaudi-bash search [-|@]term1 [-|@]term2 ... \\
     [[ --enable   | -e ]] \\
     [[ --disable  | -d ]] \\
     [[ --no-color | -c ]] \\
     [[ --refresh  | -r ]] \\
     [[ --help     | -h ]]

${YELLOW}DESCRIPTION${NC}

   Use ${GREEN}search${NC} gaudi-bash command to search for a list of terms or term negations
   across all components: aliases, completions and plugins. Components that are
   enabled are shown in green (or with a check box if --no-color option is used).

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
   --enable   | -e    ${MAGENTA}Enable all matching componenents${NC}
   --disable  | -d    ${MAGENTA}Disable all matching componenents${NC}
   --help     | -h    ${MAGENTA}Print this help${NC}
   --refresh  | -r    ${MAGENTA}Force a refresh of the search cache${NC}
   --no-color | -c    ${MAGENTA}Disable color output and use monochrome text${NC}

${YELLOW}EXAMPLES${NC}

   For example, ${GREEN}gaudi-bash search git${NC} would match any alias, completion
   or plugin that has the word 'git' in either the module name or
   it's description. You should see something like this when you run this
   command:

         ${GREEN}❯ gaudi-bash search git${NC}
               ${YELLOW}aliases:  ${GREEN}git ${NC}gitsvn
               ${YELLOW}plugins:  ${NC}autojump ${GREEN}git ${NC}git-subrepo jgitflow jump
           ${YELLOW}completions:  ${GREEN}git ${NC}git_flow git_flow_avh${NC}

   You can exclude some terms by prefixing a term with a minus, eg:

         ${GREEN}❯ gaudi-bash search git -flow -svn${NC}
               ${YELLOW}aliases:  ${NC}git
               ${YELLOW}plugins:  ${NC}autojump git git-subrepo jump
           ${YELLOW}completions:  ${NC}git${NC}

   Finally, if you prefix a term with '@' symbol, that indicates an exact
   match. Note, that we also pass the '--enable' flag, which would ensure
   that all matches are automatically enabled. The example is below:

         ${GREEN}❯ gaudi-bash search @git --enable${NC}
               ${YELLOW}aliases:  ${NC}git
               ${YELLOW}plugins:  ${NC}git
           ${YELLOW}completions:  ${NC}git${NC}

${YELLOW}SUMMARY${NC}

   Take advantage of the search functionality to discover what Bash-It can do
   for you. Try searching for partial term matches, mix and match with the
   negative terms, or specify an exact matches of any number of terms. Once
   you created the search command that returns ONLY the modules you need,
   simply append '--enable' or '--disable' at the end to activate/deactivate
   each module.

"
}
