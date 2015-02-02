# Bash-it

**Bash-it** is a mash up of my own bash commands and scripts, other bash stuff I have found and a shameless ripoff of [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh)

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

```shell
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

```shell
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

There are a few bash-it themes.  If you've created your own custom prompts, I'd love it if you shared with everyone else!  Just submit a Pull Request to me (revans).

You can see the theme screenshots  [here](https://github.com/revans/bash-it/wiki/Themes)

Alternatively, you can preview the themes in your own shell using `BASH_PREVIEW=true reload`

## Misc

### Bash Profile Aliases
Bash-it creates a 'reload' alias that makes it convenient to reload
your bash profile when you make changes. You can use it to reflect any changes you made simply by executing `reload` in the terminal.

### Prompt Version Control Check
Bash-it provides prompt themes the ability to check and display version control information for the current directory. The information is retrieved for each directory and can slow down the navigation of projects with a large number of files and folders. Turn version control checking off to prevent slow directory navigation within large projects. 

Bash-it provides a flag (`SCM_CHECK`) within the `~/.bash_profile` file that turns off/on version control information checking and display within all themes. Version control checking is on by default unless explicitly turned off. 

Set `SCM_CHECK` to 'false' to **turn off** version control checks for all themes: 

* `export SCM_CHECK=false`

Set `SCM_CHECK` to 'true' (the default value) to **turn on** version control checks for all themes: 

* `export SCM_CHECK=true`

**NOTE:**
It is possible for themes to ignore the `SCM_CHECK` flag and query specific version control information directly. For example, themes that use functions like `git_prompt_vars` skip the `SCM_CHECK` flag to retrieve and display git prompt information. If you turned version control checking off and you still see version control information  within your prompt, then functions like `git_prompt_vars` are most likely the reason why. 

## Changes from [Forked Repo](https://github.com/revans/bash-it)

Due to the fact that the original repo's maintenance is not active, i have decided to host a fork and integrate to it my additional files and also those mentioned in any pull request of the original repo that i find useful. so far the list is:

### Plugins

- **base.plugin.bash**
    + `fs` determines the size of a file or total size of a directory
    + `o` with no arguments opens the current directory, otherwise opens the given location
    + `tre` is a shorthand for `tree` with hidden files and color enabled.
    + `colors` prints the color palette in the terminal
- **compress.plugin.bash [NEW]**
    + `targz` creates a .tar.gz archive, using `zopfli`, `pigz` or `gzip` for compression
    + `gz` compares original and gzipped file size
- **editors.plugin.bash [NEW]**
    + `s` with no arguments opens the current directory in Sublime Text, otherwise opens the given location
    + `a` with no arguments opens the current directory in Atom Editor, otherwise opens the given location
    + `v` with no arguments opens the current directory in Vim, otherwise opens the given location
- **encode.plugin.bash [NEW]**
    + `escape` UTF-8-encodes a string of Unicode symbols
    + `unidecode` decodes \x{ABCD}-style Unicode escape sequences
- Updated the `extract.plugin.bash` function
- **git.plugin.bash**
    + `gitio` creates a git.io short URL
- **java.plugin.bash**
    + `setjdk` changes the JAVA SDK [More info](http://www.jayway.com/2014/01/15/how-to-switch-jdk-version-on-mac-os-x-maverick/)
- **json.plugin.bash [NEW]**
    + `json` offers syntax-highlight JSON strings or files
- **pyenv.plugin.bash**
    + `mkpvenv` creates a new virtualenv for this directory
    + `mkpvbranch` creates a new virtualenv for the current branch
    + `wopvbranch` sets workon branch
    + `wopvenv` works on the virtualenv for this directory 
    + `rmpvenv` removes virtualenv for this directory
    + `rmpvenvbranch` removes virtualenv for this directory
- **gls.aliases.bash**
    + This enables the better `ls` command `gls`

## A better `ls` for Bash Terminal

The default `ls` on OS X comes from BSD and compared to the GNU/Linux alternative is slightly lacking when it comes to changing how things look – so what I like to do is replace it with the GNU `ls`

To install that in OS X you can easily do that via the `coreutils` brew recipe (it is included in my `.brefile`). The default `ls` and other tools will have a ‘g’ prefix – i.e. `ls` would be `gls`. But **why ?!**

Well i simply like to have a structured view over directories, so when i do an `ls` i would like to see things grouped by type, so files for each type are underneath each other. For example:

![bash-it structured ls](https://github.com/ahmadassaf/configurations/blob/master/screenshots/bash-it_structured_ls.png)

You can notice how folders are on top, followed by the `.pdf` files and then the `.sparql` and so on. This is done via the `gls -X` parameter.

### Activating type-based `ls` 

I have created a `gls.plugin.bash` alias file. The file contains aliases that convert all of my `ls` aliases into `gls` ones. If you would like to keep them separate then simply do not activate this alias and you will have to call always `gls` instead. 
This alias is located in the `aliases/available` folder as we want those aliases to **override** the ones defined in the `aliases/` folder in the `general.aliases.bash`. Activating the plugin can be done via:

```shell
bash-it enable alias gls
```

## But what about the colors?

Its true that by now, we are able only to group similar types together, but this will not really improve the readability of the result. To make things better, we need to assign different color values for groups of types. For that, we need to use [dircolors](http://github.com/ahmadassaf/dircolors).

The installation is done automatically via this script if you wish so, but go ahead to the [repo](http://github.com/ahmadassaf/dircolors) and check the readme for manual installation configuration.

## This looks cool, I want more ... 

Well then, behold the [Generic Colouriser](http://kassiopeia.juls.savba.sk/~garabik/software/grc/README.txt). It is a great utility which can be used for colourising many different types of output and log files. If you installed Homebrew , installing grc is as simple as typing:

```shell
brew install grc
```

but hey, don't worry too much, it is already included in my [dotfiles](http://github.com/ahmadassaf/dotfiles).

afterwards, you need to add:

```shell
# If we have grc enabled this is used to add coloring to various commands
source "`brew --prefix grc`/etc/grc.bashrc"
```

I have included this line in `lib\appearance.bash`. 

Now when you use certain commands such as `traceroute`, the output should be colourised:

![bash-it grc](https://github.com/ahmadassaf/configurations/blob/master/screenshots/bash-it_grc.png)


## What about normal `ls`

If you don't want all of those fancy settings, then at least you should consider coloring the result of `ls`. This can be done easily as there are some global variables that hold what each type color is. For example, you can specific colors for `directory` `symbolic link` `executable` ... etc.

This is done by enabling `CLICOLOR` and defining `LS_COLORS`:

```shell
export CLICOLOR=1
export LS_COLORS=Exfxcxdxbxegedabagacad
```

Enabling `ls` color can now be easily enabled with the `-color` parameter in Mac OSX and `-G` in Linux. i.e. `ls -l --color`

`grep` results can be also colored as well by having `export GREP_OPTIONS='--color=auto'`. This is also automatically done in the `lib\appearance.bash`.

**NOTE** for Mac OSX you have to replace the `e` character in color codes with `033` for the colors and styles like in [here](http://misc.flogisoft.com/bash/tip_colors_and_formatting) to work.

For more information about alias coloring, these resources are very helpful:

- [Bash tips: Colors and formatting](http://misc.flogisoft.com/bash/tip_colors_and_formatting)
- [How to Fix Colors on Mac OSX Terminal](http://it.toolbox.com/blogs/lim/how-to-fix-colors-on-mac-osx-terminal-37214)
- [Setting LS_COLORS colors of directory listings in bash terminal](http://leocharre.com/articles/setting-ls_colors-colors-of-directory-listings-in-bash-terminal/)
- [OS X Lion Terminal Colours](http://backup.noiseandheat.com/blog/2011/12/os-x-lion-terminal-colours/)
- [A better ls for Mac OS X](http://hocuspokus.net/2008/01/a-better-ls-for-mac-os-x/)

### Fancy `vim` as well ?

For `vim` i have also included the [powerline](https://github.com/Lokaltog/powerline) visual styling which will include a status line.

**Important Notes** 

- I haven't included `powerline` in my main installation script, so if you wish to have it, then please proceed with installing it separately with the fonts dependency.
- The `--user` parameter should be removed if you got an error while installation especially if you have python installed via Homebrew.
- A dependency is the [powerline fonts](https://github.com/ahmadassaf/powerline-fonts) pack. Installation instructions can be found directly in the repository.

after installing powerline enable it by adding to the `.vimrc`:

```shell
set rtp+=/usr/local/lib/python2.7/site-packages/powerline/bindings/vim
```
 
This can be change **depending on the path to the `python` directory**

### Git repository info in the prompt
Bash it can show some information about Git repositories in the shell prompt: the current branch, tag or commit you are at, how many commits the local branch is ahead or behind from the remote branch, and if you have changes stashed.

Additionally, you can view the status of your working copy and get the count of staged, unstaged and untracked files. This feature is controlled through the flag `SCM_GIT_SHOW_DETAILS` as follows:

Set `SCM_GIT_SHOW_DETAILS` to 'true' (the default value) to **show** the working copy details in your prompt:

* `export SCM_GIT_SHOW_DETAILS=true`

Set `SCM_GIT_SHOW_DETAILS` to 'false' to **don't show** it:

* `export SCM_GIT_SHOW_DETAILS=false`

#### pass function renamed to passgen

The Bash it `pass` function has been renamed to `passgen` in order to avoid a naming conflict with the [pass password manager]. In order to minimize the impact on users of the legacy Bash it `pass` function, Bash it will create the alias `pass` that calls the new `passgen` function if the `pass` password manager command is not found on the `PATH` (default behavior).

This behavior can be overridden with the `BASH_IT_LEGACY_PASS` flag as follows:

Set `BASH_IT_LEGACY_PASS` to 'true' to force Bash it to always **create** the `pass` alias to `passgen`:

* `export BASH_IT_LEGACY_PASS=true`

Unset `BASH_IT_LEGACY_PASS` to have Bash it **return to default behavior**:

* `unset BASH_IT_LEGACY_PASS`

### Themes

- Added **colourful** theme [screenshot below]
![bash-it Colourful Theme](https://github.com/ahmadassaf/configurations/blob/master/screenshots/bash-it_theme_colourful.png)

### Aliases

- Added a bunch of new aliases to `general.aliases.bash` and `osx.aliases.bash` and `git.aliases.bash`
- Added custom alias colors 
