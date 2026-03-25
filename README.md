# gaudi-bash

**gaudi-bash** is a fork of the popular [bash-it](https://github.com/Bash-it/bash-it) framework, rebuilt with opinionated changes to the codebase for consistency, maintainability and adherence to [bash best practices](http://mywiki.wooledge.org/BashPitfalls).

Inspired by [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh), gaudi-bash provides autocompletion, themes, aliases, plugins and custom functions. It gives you a solid framework for using, developing and maintaining shell scripts and custom commands for your daily work.
If you're using the _Bourne Again Shell_ (Bash) on a regular basis and have been looking for an easy way to keep all of these nice little scripts and aliases under control, then gaudi-bash is for you.
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

1. Check a clone of this repo: `git clone https://github.com/g-udi/gaudi-bash.git ~/.gaudi_bash`
2. Run `~/.gaudi_bash/setup.sh` (it automatically backs up your `~/.bash_profile`)
3. Edit your `~/.bash_profile` file in order to customize gaudi-bash.

The install script can take the following options:

* `--silent`: Ask nothing and install using default settings.
* `--no-modify-config`: Do not modify the existing config file (`~/.bash_profile` or `~/.bashrc`).

When run without the `--silent` switch, gaudi-bash only enables a sane default set of functionality to keep your shell clean and to avoid issues with missing dependencies. Feel free to enable the tools you want to use after the installation.

When you run without the `--no-modify-config` switch, the gaudi-bash installer automatically modifies/replaces your existing config file.
Use the `--no-modify-config` switch to avoid unwanted modifications, e.g. if your Bash config file already contains the code that loads gaudi-bash.

**NOTE**: Keep in mind how Bash loads its configuration files,
`.bash_profile` for login shells (and in macOS in terminal emulators like [Terminal.app](http://www.apple.com/osx/apps/) or [iTerm2](https://www.iterm2.com/)) and `.bashrc` for interactive shells (default mode in most of the GNU/Linux terminal emulators), to ensure that gaudi-bash is loaded correctly.

A good practice is sourcing `.bashrc` into `.bash_profile` to keep things working in all scenarios.

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

gaudi-bash separates the core engine from the components (plugins, aliases, completions, themes). The `gaudi-bash update` command pulls the latest **core** code. If you would like to also pull the latest components, pass the `all` parameter:

```bash
gaudi-bash update all
```

### Uninstalling

To uninstall gaudi-bash, run the `uninstall.sh` script found in the `$GAUDI_BASH` directory:

```
cd $GAUDI_BASH
./uninstall.sh
```

This will restore your previous Bash profile.
After the uninstall script finishes, remove the gaudi-bash directory from your machine (`rm -rf $GAUDI_BASH`) and start a new shell.

## Architecture

gaudi-bash is structured around a clear separation between the core engine and user-facing components:

```
gaudi-bash/
  gaudi_bash.sh          # Entry point, sourced from your .bash_profile/.bashrc
  lib/
    gaudi-bash.bash      # Main command dispatcher (gaudi-bash show, enable, disable, ...)
    composure.bash       # Function metadata (about, group, param, example)
    log.bash             # Logging subsystem
    appearance.bash      # Theme loading
    colors.bash          # Terminal color definitions
    command_duration.bash # Command duration tracking
    history.bash         # History configuration
    preexec.bash         # Pre-exec hook support
    search.bash          # Search engine for components
    helpers/
      components.bash    # Component listing and description
      core.bash          # Core utility functions
      cache.bash         # Component cache management
      enabler.bash       # Component enabling logic
      disabler.bash      # Component disabling logic
      doctor.bash        # Diagnostics (gaudi-bash doctor)
      generic.bash       # Shared helper functions
      help.bash          # Help display for components
      updater.bash       # Update logic (gaudi-bash update)
      utils.bash         # General utilities
  components/
    aliases/lib/         # Alias definitions
    completions/lib/     # Completion definitions
    plugins/lib/         # Plugin definitions
    themes/              # Prompt themes
    enabled/             # Symlinks to enabled components
  scripts/
    loader.bash          # Loads all enabled components at startup
  bin/                   # Vendored dependencies (bats, composure, preexec)
```

The core engine loads libraries from `lib/`, then the loader walks `components/enabled/` to source every enabled alias, completion and plugin. Components are enabled and disabled by creating or removing symlinks in the `enabled/` directory, managed through the `gaudi-bash enable` and `gaudi-bash disable` commands.

Key design principles:

- Core engine is separated from components so each can be updated independently.
- Code is split into small, focused files rather than monolithic scripts.
- Consistent coding style: function definitions, comments and variable naming follow a single convention.
- Compliance with [shellcheck](http://shellcheck.net) wherever possible.
- Comprehensive unit tests (via [bats](https://github.com/bats-core/bats-core)) for all core functions.

## Components

gaudi-bash ships with a large collection of community-contributed components organized into three categories.

### Plugins

Plugins add new shell functions, behaviors and integrations. Some highlights:

- **sudo** -- press Escape twice to prepend `sudo` to the current command
- **fzf** -- fuzzy finder integration
- **history-eternal** -- persist unlimited command history across sessions
- **history-substring-search** -- search history by substring with arrow keys
- **cmd-returned-notify** -- desktop notification when a long-running command finishes
- **python** -- virtualenv helpers and Python utilities
- **url** -- URL encoding/decoding functions
- **fasd** / **zoxide** / **autojump** -- fast directory jumping
- **extract** -- extract any archive format with a single command
- **git** / **gitstatus** -- Git helpers and status information
- **node** / **nvm** / **nodenv** -- Node.js version management
- **docker** / **docker-compose** -- Docker workflow helpers
- **ssh** / **sshagent** -- SSH agent management
- **tmux** / **tmuxinator** -- Tmux session management
- **direnv** -- per-directory environment variables

### Completions

Tab-completion definitions for common tools:

- **git** / **git_flow** / **github-cli** -- Git ecosystem
- **docker** / **docker-compose** / **docker-machine** -- Docker
- **cargo** / **rustup** -- Rust toolchain
- **dotnet** -- .NET CLI
- **yarn** / **npm** / **nvm** -- JavaScript package managers
- **kubectl** / **helm** / **kind** / **minikube** -- Kubernetes
- **terraform** / **vault** / **consul** -- HashiCorp tools
- **system** -- system-level completions (kill, mount, etc.)
- **ssh** / **brew** / **pip** / **gem** / **rake** -- Common CLI tools
- **gcloud** / **awscli** -- Cloud provider CLIs

### Aliases

Shortcut aliases for frequently used commands:

- **git** -- extensive set of short Git aliases
- **docker** / **docker-compose** -- Docker shortcuts
- **terraform** / **vault** -- Infrastructure as code
- **tmux** -- Tmux session shortcuts
- **composer** -- PHP Composer aliases
- **directory** -- quick directory navigation (`..`, `...`, `mkcd`, etc.)
- **kubectl** -- Kubernetes aliases
- **homebrew** -- Homebrew shortcuts
- **ls** / **general** -- Common listing and utility aliases
- **npm** / **yarn** / **node** -- JavaScript tooling

Use `gaudi-bash show plugins`, `gaudi-bash show completions` or `gaudi-bash show aliases` to see the full list of available components and their descriptions.

## Help Screens

```bash
gaudi-bash show                # shows all currently enabled components
gaudi-bash show aliases        # shows installed and available aliases
gaudi-bash show completions    # shows installed and available completions
gaudi-bash show plugins        # shows installed and available plugins
gaudi-bash help aliases        # shows help for installed aliases
gaudi-bash help completions    # shows help for installed completions
gaudi-bash help plugins        # shows help for installed plugins
gaudi-bash enable plugin <name>    # enables a plugin
gaudi-bash disable plugin <name>   # disables a plugin
gaudi-bash doctor [errors|warnings|all]  # diagnose loading issues
gaudi-bash version             # shows current gaudi-bash version and git SHA
gaudi-bash reload              # reloads your bash profile
gaudi-bash restart             # re-executes bash (stronger than reload)
gaudi-bash backup              # backs up list of enabled components
gaudi-bash restore             # restores components from a backup
gaudi-bash profile save <name> # save enabled components as a named profile
gaudi-bash profile load <name> # load a saved profile
gaudi-bash profile list        # list saved profiles
gaudi-bash profile rm <name>   # remove a saved profile
gaudi-bash update [all]        # updates gaudi-bash core (or core + components)
gaudi-bash search <terms>      # searches for components by keyword
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
$ gaudi-bash search ruby rake gem bundle irb rails
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
$ gaudi-bash search ruby rake gem bundle irb rails -chruby
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
$ NO_COLOR=1 gaudi-bash search ruby rake gem bundle irb rails -chruby
      aliases  =>   bundler rails
      plugins  =>   ruby
  completions  =>   bundler gem rake
```

## Command Duration

gaudi-bash can track and display how long each command takes to run. To enable this feature, set the following in your `.bash_profile` (or `.bashrc`) before gaudi-bash is sourced:

```bash
export GAUDI_BASH_COMMAND_DURATION=true
```

### Configuration

| Variable | Default | Description |
|---|---|---|
| `COMMAND_DURATION_MIN_SECONDS` | `1` | Minimum duration (in seconds) before the elapsed time is shown |
| `COMMAND_DURATION_PRECISION` | `1` | Number of decimal digits for sub-second display |
| `COMMAND_DURATION_COLOR` | (none) | ANSI color code to apply to the output |

The command duration output is available for use in your prompt theme via the `_command_duration` function.

## Profiles

Profiles let you save, switch between and share complete component configurations. This is an upgrade over the basic backup/restore — you can maintain multiple named profiles for different workflows.

```bash
gaudi-bash profile save <name>     # save current enabled components as a named profile
gaudi-bash profile load <name>     # disable everything, then enable components from profile
gaudi-bash profile list            # list all saved profiles
gaudi-bash profile rm <name>       # delete a saved profile
```

Profiles are stored as plain text files in `$GAUDI_BASH/profiles/` with a simple `<type> <name>` format (one component per line). The `load` command validates the profile before applying any changes.

## Backup and Restore

For quick one-off backups (e.g., before experimenting), you can use the simpler backup/restore commands:

```bash
gaudi-bash backup    # writes enabled components to $GAUDI_BASH/tmp/enabled.gaudi-bash.backup
gaudi-bash restore   # re-enables components from the backup file
```

For named, reusable configurations, use profiles instead.
