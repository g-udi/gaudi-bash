# Bash it

**Bash it** is a mash up of my own bash commands and scripts, other bash stuff I have found and a shameless ripoff of [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)

Includes autocompletion, themes, aliases, custom functions, a few stolen pieces from Steve Losh, and more.

## Install

The preferred installation method is using the main script in the [main configuration repo](http://github.com/ahmadassaf/configurations). However, if you wish to do a standalone installation then you proceed with the following steps:

1. Check a clone of this repo: `git clone https://github.com/ahmadassaf/bash-it.git ~/.bash_it`
2. Run `~/.bash_it/install.sh` (it automatically backs up your `~/.bash_profile`)
3. Edit your `~/.bash_profile` file in order to customize bash-it.

**NOTE:**
The install script will also prompt you asking if you use [Jekyll](https://github.com/mojombo/jekyll).
This is to set up the `.jekyllconfig` file, which stores info necessary to use the Jekyll plugin.


## Help Screens

```
bash-it show aliases        # shows installed and available aliases
bash-it show completions    # shows installed and available completions
bash-it show plugins        # shows installed and available plugins
bash-it help aliases        # shows help for installed aliases
bash-it help completions    # shows help for installed completions
bash-it help plugins        # shows help for installed plugins
```

## Your Custom scripts, aliases, and functions

For custom scripts, and aliases, just create the following files (they'll be ignored by the git repo):

* `aliases/custom.aliases.bash`
* `lib/custom.bash`
* `plugins/custom.plugins.bash`

I recommend putting the extra bash configuration in the `lib/custom.bash`, for example my custom configuration is:

```
# Git credentials
# Not in the repository, to prevent people from accidentally committing under my name
GIT_AUTHOR_NAME="Ahmad Assaf"
GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
git config --global user.name "$GIT_AUTHOR_NAME"
GIT_AUTHOR_EMAIL="ahmad.a.assaf@gmail.com"
GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
git config --global user.email "$GIT_AUTHOR_EMAIL"

# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;

# Make Sublime the default editor
export EDITOR="sublime";
export GIT_EDITOR='sublime'

# Larger bash history (allow 32³ entries; default is 500)
export HISTSIZE=32768;
export HISTFILESIZE=$HISTSIZE;
export HISTCONTROL=ignoredups;
# Make some commands not show up in history
export HISTIGNORE="ls:cd:cd -:pwd:exit:date:* --help";

# Prefer US English and use UTF-8
export LANG="en_US.UTF-8";
export LC_ALL="en_US.UTF-8";

# Highlight section titles in manual pages
export LESS_TERMCAP_md="${yellow}";

# Don’t clear the screen after quitting a manual page
export MANPAGER="less -X";

# Link Homebrew casks in `/Applications` rather than `~/Applications`
export HOMEBREW_CASK_OPTS="--appdir=/Applications";

# Add MySQL and MAMPP to path
export PATH=$PATH:/Applications/MAMP/Library/bin

### Added by the Heroku Toolbelt
export PATH="/usr/local/heroku/bin:$PATH"
```

now, if you want to change any of the main configuration and have it saved in your own fork, then i recommend you edit the `template/bash-profile.template.bash` as this is the main `bash_profile` file that will be copied and sourced in your home folder. For example, i have changed the theme and the default editors so that i will not have to change them every time i do a fresh install.

Anything in the custom directory will be ignored, with the exception of `custom/example.bash`.

## Themes

There are a few bash it themes.  If you've created your own custom prompts, I'd love it if you shared with everyone else!  Just submit a Pull Request to me (revans).

You can see the theme screenshots  [here](https://github.com/revans/bash-it/wiki/Themes)

## Misc

### Bash Profile Aliases
Bash it creates a 'reload' alias that makes it convenient to reload
your bash profile when you make changes. You can use it to reflect any changes you made simply by executing `reload` in the terminal.

### Prompt Version Control Check
Bash it provides prompt themes the ability to check and display version control information for the current directory. The information is retrieved for each directory and can slow down the navigation of projects with a large number of files and folders. Turn version control checking off to prevent slow directory navigation within large projects. 

Bash it provides a flag (`SCM_CHECK`) within the `~/.bash_profile` file that turns off/on version control information checking and display within all themes. Version control checking is on by default unless explicitly turned off. 

Set `SCM_CHECK` to 'false' to **turn off** version control checks for all themes: 

* `export SCM_CHECK=false`

Set `SCM_CHECK` to 'true' (the default value) to **turn on** version control checks for all themes: 

* `export SCM_CHECK=true`

**NOTE:**
It is possible for themes to ignore the `SCM_CHECK` flag and query specific version control information directly. For example, themes that use functions like `git_prompt_vars` skip the `SCM_CHECK` flag to retrieve and display git prompt information. If you turned version control checking off and you still see version control information  within your prompt, then functions like `git_prompt_vars` are most likely the reason why. 

## Changes from [Forked Repo](https://github.com/revans/bash-it)

Due to the fact that the original repo's maintenance is not active, i have decided to host a fork and integrate to it my additional files and also those mentioned in any pull request of the original repo that i find useful. so far the list is:

### Plugins

- base.plugin.bash
    + `fs` determines the size of a file or total size of a directory
    + `o` with no arguments opens the current directory, otherwise opens the given location
    + `tre` is a shorthand for `tree` with hidden files and color enabled.
    + `colors` prints the color palette in the terminal
- compress.plugin.bash **[NEW]**
    + `targz` creates a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
    + `gz` compares original and gzipped file size
- editors.plugin.bash **[NEW]**
    + `s` with no arguments opens the current directory in Sublime Text, otherwise opens the given location
    + `a` with no arguments opens the current directory in Atom Editor, otherwise opens the given location
    + `v` with no arguments opens the current directory in Vim, otherwise opens the given location
- encode.plugin.bash **[NEW]**
    + `escape` UTF-8-encodes a string of Unicode symbols
    + `unidecode` decodes \x{ABCD}-style Unicode escape sequences
- Updated the `extract.plugin.bash` function
- git.plugin.bash
    + `gitio` creates a git.io short URL
- java.plugin.bash
    + `setjdk` changes the JAVA SDK [More info](http://www.jayway.com/2014/01/15/how-to-switch-jdk-version-on-mac-os-x-maverick/)
- json.plugin.bash **[NEW]**
    + `json` offers syntax-highlight JSON strings or files
- pyenv.plugin.bash
    + `mkpvenv` creates a new virtualenv for this directory
    + `mkpvbranch` creates a new virtualenv for the current branch
    + `wopvbranch` sets workon branch
    + `wopvenv` works on the virtualenv for this directory 
    + `rmpvenv` removes virtualenv for this directory
    + `rmpvenvbranch` removes virtualenv for this directory

### Themes

- Added colourful theme [screenshot below]
![bash-it Colourful Theme](http://github.com/ahmadassaf/Configurations/screenhots/bash-it_theme_colourful.png)


### Aliases

- Added a bunch of new aliases to `general.aliases.bash` and `osx.aliases.bash`

