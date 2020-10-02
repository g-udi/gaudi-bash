cite about-plugin
about-plugin 'Custom Text Editors'

s () {
	about '`s` with no arguments opens the current directory in Sublime Text, otherwise opens the given location'
  group 'editors'

	if [[ $# -eq 0 ]]; then
		sublime .;
	else
		sublime "$@";
	fi;
}

a () {
	about '`a` with no arguments opens the current directory in Atom Editor, otherwise opens the given location'
  group 'editors'

	if [[ $# -eq 0 ]]; then
		atom .;
	else
		atom "$@";
	fi;
}

v () {
	about '`v` with no arguments opens the current directory in Vim, otherwise opens the given location'
  group 'editors'

	if [[ $# -eq 0 ]]; then
		vim .;
	else
		vim "$@";
	fi;
}

# set the global edit mode using the EDIT_MODE global variable e.g., vi, emacs
[[ -z $EDIT_MODE ]] && set -o "$EDIT_MODE"
