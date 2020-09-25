#!/usr/bin/env bash

# LSCOLORS

# The value of this variable describes what color to use for which attribute when colors are enabled with CLICOLOR.  This string is a concatenation of pairs of
# the format fb, where f is the foreground color and b is the background color.

# The color designators are as follows:

#     a     black
#     b     red
#     c     green
#     d     brown
#     e     blue
#     f     magenta
#     g     cyan
#     h     light grey
#     A     bold black, usually shows up as dark grey
#     B     bold red
#     C     bold green
#     D     bold brown, usually shows up as yellow
#     E     bold blue
#     F     bold magenta
#     G     bold cyan
#     H     bold light grey; looks like bright white
#     x     default foreground or background

# Note that the above are standard ANSI colors.  The actual display may differ depending on the color capabilities of the terminal in use.

# The order of the attributes are as follows:

#     1.   directory
#     2.   symbolic link
#     3.   socket
#     4.   pipe
#     5.   executable
#     6.   block special
#     7.   character special
#     8.   executable with setuid bit set
#     9.   executable with setgid bit set
#     10.  directory writable to others, with sticky bit
#     11.  directory writable to others, without sticky bit

# The default is `exfxcxdxbxegedabagacad`, i.e. blue foreground and default background for regular directories, black foreground and red background for setuid
# executables, etc.




# # LS_COLORS

# LS_COLORS='di=1:fi=0:ln=31:pi=5:so=5:bd=5:cd=5:or=31'

# The parameters for LS_COLORS (di, fi, ln, pi, etc) refer to different file types:

#     di 	Directory
#     fi 	File
#     ln 	Symbolic Link
#     pi 	Fifo file
#     so 	Socket file
#     bd 	Block (buffered) special file
#     cd 	Character (unbuffered) special file
#     or 	Symbolic Link pointing to a non-existent file (orphan)
#     mi 	Non-existent file pointed to by a symbolic link (visible when you type ls -l)
#     ex 	File which is executable (ie. has 'x' set in permissions).

# ### Color Codes

# Through trial and error I worked out the color codes for `LS_COLORS` to be:

#     0 =	Default Colour
#     1 =	Bold
#     4 =	Underlined
#     5 =	Flashing Text
#     7 =	Reverse Field
#     31 =	Red
#     32 =	Green
#     33 =	Orange
#     34 =	Blue
#     35 =	Purple
#     36 =	Cyan
#     37 =	Grey
#     40 =	Black Background
#     41 =	Red Background
#     42 =	Green Background
#     43 =	Orange Background
#     44 =	Blue Background
#     45 =	Purple Background
#     46 =	Cyan Background
#     47 =	Grey Background
#     90 =	Dark Grey
#     91 =	Light Red
#     92 =	Light Green
#     93 =	Yellow
#     94 =	Light Blue
#     95 =	Light Purple
#     96 =	Turquoise
#     100 =	Dark Grey Background
#     101 =	Light Red Background
#     102 =	Light Green Background
#     103 =	Yellow Background
#     104 =	Light Blue Background
#     105 =	Light Purple Background
#     106 =	Turquoise Background

# These codes can also be combined with one another:
# di=5;34;43
# alternatively use: http://geoff.greer.fm/lscolors/

# Enable coloring of your terminal by using ANSI color sequences to distinguish file types
export CLICOLOR=1
export LSCOLORS='cxfxdxgxbxegedabagacad'

# colored grep
GREP_OPTIONS="--color=auto"
alias grep="grep $GREP_OPTIONS"

# Load the theme
if [[ $BASH_IT_THEME ]]; then
  source "$BASH_IT/themes/$BASH_IT_THEME/$BASH_IT_THEME.theme.bash"
fi
