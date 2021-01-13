# gaudi-bash

**gaudi-bash** is a fork from the infamous [bash-it](https://github.com/bash-it/bash-it) with lots of opinionated changes in the code to suit my OCD-like nature. I am by no means a bash expert but I tried my best to conform to the best practices in [here](http://mywiki.wooledge.org/BashPitfalls).

**bash-it** itself is inspired by [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh) and includes autocompletion, themes, aliases, custom functions, and more. It provides a solid framework for using, developing and maintaining shell scripts and custom commands for your daily work.
If you're using the _Bourne Again Shell_ (Bash) on a regular basis and have been looking for an easy way on how to keep all of these nice little scripts and aliases under control, then gaudi-bash is for you!
Stop polluting your `~/bin` directory and your `.bashrc` file, fork/clone gaudi-bash and start hacking away.

## Contributing

Please take a look at the [Contribution Guidelines](CONTRIBUTING.md) before reporting a bug or providing a new feature.

The [Development Guidelines](DEVELOPMENT.md) have more information on some of the internal workings of gaudi-bash,
please feel free to read through this page if you're interested in how gaudi-bash loads its components.

## Installation

gaudi-bash is installed by running the following commands in your terminal. You can install this via the command-line with either `curl` or `wget`, whichever is installed on your machine.

```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ahmadassaf/gaudi-bash/master/install.sh)"
```

> **Manual inspection**: 
  It's a good idea to inspect the install script from projects you don't yet know. You can do that by downloading the install script first, looking through it so everything looks normal, then running it.


If you wish to do a standalone installation then you proceed with the following steps:

1. Check a clone of this repo: `git clone https://github.com/ahmadassaf/gaudi-bash.git ~/.bash_it`
2. Run `~/.bash_it/setup.sh` (it automatically backs up your `~/.bash_profile`)
3. Edit your `~/.bash_profile` file in order to customize gaudi-bash.

The install script can take the following options:

* `--silent`: Ask nothing and install using default settings.
* `--no-modify-config`: Do not modify the existing config file (`~/.bash_profile` or `~/.bashrc`).

When run without the `--silent` switch, gaudi-bash only enables a sane default set of functionality to keep your shell clean and to avoid issues with missing dependencies. Feel free to enable the tools you want to use after the installation.

When you run without the `--no-modify-config` switch, the gaudi-bash installer automatically modifies/replaces your existing config file.
Use the `--no-modify-config` switch to avoid unwanted modifications, e.g. if your Bash config file already contains the code that loads gaudi-bash.

**NOTE**: Keep in mind how Bash loads its configuration files,
`.bash_profile` for login shells (and in macOS in terminal emulators like [Terminal.app](http://www.apple.com/osx/apps/) or [iTerm2](https://www.iterm2.com/)) and `.bashrc` for interactive shells (default mode in most of the GNU/Linux terminal emulators), to ensure that gaudi-bash is loaded correctly.

A good "practice" is sourcing `.bashrc` into `.bash_profile` to keep things working in all the scenarios.

To achieve this, you can add this snippet in your `.bash_profile`:

```
if [[ -f ~/.bashrc ]]; then
  . ~/.bashrc
fi
```

> Refer to the official [Bash documentation](https://www.gnu.org/software/bash/manual/bashref.html#Bash-Startup-Files) to get more info.

### Updating

To update gaudi-bash to the latest version, simply run:

```bash
gaudi-bash update
```

gaudi-bash separates the core engine from the components (plugins, aliases, completions, etc.) _more on that to come in the design section_. the `gaudi-bash`
will make sure the latest **core** code is pulled, if you would like to make sure that latest components are being pulled as well then you need to pass the `all` parameter `bash-it update all`.

### Uninstalling

To uninstall gaudi-bash, run the `uninstall.sh` script found in the `$BASH_IT` directory:

```
cd $BASH_IT
./uninstall.sh
```

This will restore your previous Bash profile.
After the uninstall script finishes, remove the gaudi-bash directory from your machine (`rm -rf $BASH_IT`) and start a new shell.

## Architecture & Design
> or why did I fork bash-it

I am a huge fan of bash-it, but the more I used it, the more I ran into some issues. Thats when I started to dig into the codebase, open PRs and contribute to the codebase. It is however, after digging deeper into some areas that I found myself moving lots of parts and restructuring big chunks the code. Moreover, I found various inconsistencies when it came to code style and adherence to bash best practices (some examples outlined in this [issue](https://github.com/Bash-it/bash-it/issues/194)). 

I also found lots of unused and redundant code, a huge part of that was to ensure backward compatibility with the older versions of bash-it. Sometimes, it is better to start fresh and put the past behind us!

The main changes in this repo are:

 - Split the core engine from the components (plugins, aliases, completions and themes to be done soon)
 - Split the code into smaller set of files e.g., components, helpers, utils, etc.
 - Ensure consistent way of writing bash code (function definitions, comments, etc.)
 - Following as much as possible [bash best practices](http://mywiki.wooledge.org/BashPitfalls)
 - Make sure to comply with [shellcheck](http://shellcheck.net) as much as possible
 - Ensure high coverage unit tests for all core functions and split test functions as well into small units
 - Merged some of the work from bash-it issues and openPRs that made sense to me

I will discuss more the code structure and functions in [DEVELOPMENT](https://github.com/ahmadassaf/gaudi-bash/blob/master/DEVELOPMENT.md)


## Help Screens

```bash
gaudi-bash show aliases        # shows installed and available aliases
gaudi-bash show completions    # shows installed and available completions
gaudi-bash show plugins        # shows installed and available plugins
gaudi-bash help aliases        # shows help for installed aliases
gaudi-bash help completions    # shows help for installed completions
gaudi-bash help plugins        # shows help for installed plugins
```

## Search

If you need to quickly find out which of the plugins, aliases or completions are available for a specific framework, programming language, or an environment, you can _search_ for multiple terms related to the commands you use frequently.
Search will find and print out modules with the name or description matching the terms provided.

### Syntax

```bash
  gaudi-bash search term1 [[-]term2] [[-]term3]....
```

As an example, a ruby developer might want to enable everything related to the commands such as `ruby`, `rake`, `gem`, `bundler`, and `rails`.
Search command helps you find related modules so that you can decide which of them you'd like to use:

```bash
❯ gaudi-bash search ruby rake gem bundle irb rails
      aliases:  bundler rails
      plugins:  chruby chruby-auto ruby
  completions:  bundler gem rake
```

Currently enabled modules will be shown in green.

### Searching with Negations

You can prefix a search term with a "-" to exclude it from the results.
In the above example, if we wanted to hide `chruby` and `chruby-auto`,
we could change the command as follows:

```bash
❯ gaudi-bash search ruby rake gem bundle irb rails -chruby
      aliases:  bundler rails
      plugins:  ruby
  completions:  bundler gem rake
```

### Using Search to Enable or Disable Components

By adding a `--enable` or `--disable` to the search command, you can automatically enable all modules that come up as a result of a search query.
This could be quite handy if you like to enable a bunch of components related to the same topic.

### Disabling ASCII Color

To remove non-printing non-ASCII characters responsible for the coloring of the search output, you can set environment variable `NO_COLOR`.
Enabled components will then be shown with a checkmark:

```bash
❯ NO_COLOR=1 gaudi-bash search ruby rake gem bundle irb rails -chruby
      aliases  =>   ✓bundler ✓rails
      plugins  =>   ✓ruby
  completions  =>   bundler gem rake
```

## Custom scripts, aliases, themes, and functions

For custom scripts, and aliases, just create the following files (they'll be ignored by the git repo):

* `aliases/custom.aliases.bash`
* `completion/custom.completion.bash`
* any file insude the `custom` folder
* `plugins/custom.plugins.bash`

Now, if you want to change any of the main configuration and have it saved in your own fork, then i recommend you edit the `template/bash-profile.template.bash` as this is the main `bash_profile` file that will be copied and sourced in your home folder. For example, i have changed the theme and the default editors so that i will not have to change them every time i do a fresh install.

Alternately, if you would like to keep your custom scripts under version control, you can set `BASH_IT_CUSTOM` in your `~/.bashrc` to another location outside of the `$BASH_IT` folder.
In this case, any `*.bash` file under every directory below `BASH_IT_CUSTOM` folder will be used.
