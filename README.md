# gaudi-bash

**gaudi-bash** is a fork of the popular [bash-it](https://github.com/Bash-it/bash-it) framework, rebuilt with opinionated changes to the codebase for consistency, maintainability and adherence to [bash best practices](http://mywiki.wooledge.org/BashPitfalls).

Inspired by [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh), gaudi-bash provides autocompletion, themes, aliases, plugins and custom functions. It gives you a solid framework for using, developing and maintaining shell scripts and custom commands for your daily work.
If you're using the _Bourne Again Shell_ (Bash) on a regular basis and have been looking for an easy way to keep all of these nice little scripts and aliases under control, then gaudi-bash is for you.
Stop polluting your `~/bin` directory and your `.bashrc` file, fork/clone gaudi-bash and start hacking away.

> **Using zsh as well?** [gaudi-shell](https://github.com/g-udi/gaudi-shell) evolved from gaudi-bash and supersedes it: the same component model for both bash and zsh, driven by the `gshell` command.

## Contributing

The unit tests live in `test/`; [test/README.md](test/README.md) explains how to run them before you send a change.

The [Architecture](#architecture) section below has more information on some of the internal workings of gaudi-bash,
please feel free to read through it if you're interested in how gaudi-bash loads its components.

## Requirements

- **Bash 4.3 or newer.** macOS ships Bash 3.2 as `/bin/bash`: install a current one (`brew install bash`) and use it as your shell. An older Bash is told that gaudi-bash was not loaded and is otherwise left alone; `setup.sh` refuses to run on it.
- **git**, to install and update gaudi-bash and its components.

## Installation

gaudi-bash is installed by running one of the following commands in your terminal. You can install this via the command-line with either `curl` or `wget`, whichever is installed on your machine.

```shell
bash -c "$(curl -fsSL https://raw.githubusercontent.com/g-udi/gaudi-bash/main/install.sh)"
bash -c "$(wget -qO- https://raw.githubusercontent.com/g-udi/gaudi-bash/main/install.sh)"
```

The install script clones the latest release of gaudi-bash (the highest version tag, or the `main` branch when nothing was released yet) into `~/.gaudi_bash` and then runs `setup.sh`, which fetches the git submodules gaudi-bash runs on (the components, composure and bash-preexec). The submodules that only the unit tests need (bats) are not fetched.

> **Manual inspection**:
  It's a good idea to inspect the install script from projects you don't yet know. You can do that by downloading the install script first, looking through it so everything looks normal, then running it.


If you wish to do a standalone installation then you proceed with the following steps:

1. Check out a clone of this repo: `git clone https://github.com/g-udi/gaudi-bash.git ~/.gaudi_bash`
2. Run `~/.gaudi_bash/setup.sh` (it fetches the git submodules gaudi-bash runs on if they are missing and automatically backs up your `~/.bash_profile` on macOS, or `~/.bashrc` elsewhere, to a `.bak` file; an existing `.bak` is never overwritten unattended, a later profile goes to a timestamped `.bak.<date>` file instead)
3. Edit your `~/.bash_profile` (or `~/.bashrc`) file in order to customize gaudi-bash.

`setup.sh` can take the following options:

* `--silent` (`-s`): Ask nothing and install using default settings. Your config file is **replaced** by the gaudi-bash template (the original is kept in the `.bak` backup); run without `--silent` to be asked whether to append the template instead.
* `--basic` (`-b`): Do not enable the default gaudi-bash components.
* `--no-modify-config` (`-n`): Do not modify the existing config file (`~/.bash_profile` or `~/.bashrc`).
* `--help` (`-h`): Display the usage message.

Unless you pass `--basic`, gaudi-bash only enables a sane default set of functionality (the `gaudi-bash` and `system` completions, the `base` plugin and the `general` and `gaudi-bash` aliases) to keep your shell clean and to avoid issues with missing dependencies. Feel free to enable the tools you want to use after the installation.

When you run without the `--no-modify-config` switch, the gaudi-bash installer automatically modifies/replaces your existing config file.
Use the `--no-modify-config` switch to avoid unwanted modifications, e.g. if your Bash config file already contains the code that loads gaudi-bash.

`setup.sh` always sets up the installation it is part of (the folder the script is in), whatever `GAUDI_BASH` says in the shell it is started from. Without a terminal to ask on (a build, a script) it stops and tells you to pass `--silent` or `--no-modify-config`.

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

To update gaudi-bash to the latest stable release (the most recent git tag), simply run:

```bash
gbash update
```

To follow the development branch instead (`main` on the `origin` remote, configurable with `GAUDI_BASH_DEVELOPMENT_BRANCH` and `GAUDI_BASH_REMOTE`), run:

```bash
gbash update dev
```

The command shows the incoming commits, asks for confirmation (pass `--silent` to skip the question), checks out the target, updates the git submodules and restarts Bash. It refuses to run while tracked files in the gaudi-bash directory have local changes, and fails when the remote can not be fetched or when there is no release to update to. The only accepted modes are `stable` and `dev`.

The installer makes a shallow clone; the first update completes its history, so that an update can be told from a step back. When your version is ahead of the latest release (you followed `main`), `gbash update` says so and offers to go back to the release, while `gbash update dev` never goes back.

gaudi-bash separates the core engine from the components (plugins, aliases, completions, themes), which live in git submodules. `gbash update` checks out the core code and then brings the components to the versions pinned by that core (the submodules that only the unit tests need are updated only where they were fetched before). Should that last step fail (e.g., no network), run it by hand:

```bash
git -C "$GAUDI_BASH" submodule update --init --recursive
```

### Uninstalling

To uninstall gaudi-bash, run the `uninstall.sh` script found in the `$GAUDI_BASH` directory:

```
cd $GAUDI_BASH
./uninstall.sh
```

This removes the gaudi-bash block from your Bash profile (`~/.bash_profile` on macOS, `~/.bashrc` elsewhere, or `$GAUDI_BASH_PROFILE` when set), keeps the profile as it was in a `.uninstall` file, and removes the gaudi-bash directory (`$GAUDI_BASH`) from your machine. Everything else in your profile is left alone.

If `setup.sh` took a `.bak` backup of your profile, the script asks whether to put it back instead (this discards whatever was added to the profile since); `./uninstall.sh --restore-backup` does so without asking. When the profile can not be determined nothing is removed.

The cached component descriptions (`~/.cache/gaudi-bash`) go with the installation. Your command history stays: when gaudi-bash kept it in `~/.local/state/bash/history` (see [History](#history)), the script tells you where it is, since Bash goes back to `~/.bash_history`.
After the uninstall script finishes, start a new shell.

## Releasing

Merging to `main` does not create a release. A release is cut by hand:

1. Open **Actions > CI > Run workflow** on GitHub and pick the `main` branch.
2. Choose which part of the version to raise: `patch`, `minor` or `major`.
3. Once the tests and lint pass, the run tags `main` and publishes a GitHub release.

`gbash update` moves an installation to the latest release tag, and `gbash update dev` to the tip of `main`, so the two only differ once `main` has moved past the last release.

## Architecture

gaudi-bash is structured around a clear separation between the core engine and user-facing components:

```
gaudi-bash/
  gaudi_bash.sh          # Entry point, sourced from your .bash_profile/.bashrc
  lib/
    gaudi-bash.bash      # Main command dispatcher (gbash show, enable, disable, ...)
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
      doctor.bash        # Diagnostics (gbash doctor)
      generic.bash       # Shared helper functions
      help.bash          # Help display for components
      profile.bash       # Profile save/load/list/rm (gbash profile)
      updater.bash       # Update logic (gbash update)
      utils.bash         # General utilities
  components/
    aliases/lib/         # Alias definitions
    completions/lib/     # Completion definitions
    plugins/lib/         # Plugin definitions
    themes/              # Prompt themes
    enabled/             # Symlinks (relative) to enabled components
    custom/              # Untracked local scripts loaded after enabled components
  scripts/
    loader.bash          # Loads all enabled components at startup
  template/              # Bash profile template written by setup.sh
  test/                  # Unit tests (bats)
  bin/                   # Vendored dependencies (bats, composure, preexec)
```

The core engine loads libraries from `lib/`, then the loader walks `components/enabled/` to source every enabled alias, completion and plugin. Components are enabled and disabled by creating or removing symlinks in the `enabled/` directory, managed through the `gbash enable` and `gbash disable` commands.

The symlinks are relative (`../plugins/lib/git.plugins.bash`), so they keep working when the installation is moved or renamed. Earlier versions made absolute links: they still load, and `gbash migrate` rewrites them (`setup.sh` and `gbash update` do it for you). A link whose file is gone is reported when an interactive shell starts (and by `gbash doctor`) instead of being skipped silently; `gbash migrate` or enabling the component again repairs it.

Key design principles:

- Core engine is separated from components so each can be updated independently.
- Code is split into small, focused files rather than monolithic scripts.
- Consistent coding style: function definitions, comments and variable naming follow a single convention.
- Compliance with [shellcheck](http://shellcheck.net) wherever possible.
- Comprehensive unit tests (via [bats](https://github.com/bats-core/bats-core)) for all core functions.

## Local Untracked Customizations

Use `components/custom/` for machine-local aliases, functions, exports, and plugin-like behavior that should not be committed.

```bash
mkdir -p "$GAUDI_BASH/components/custom"
cat > "$GAUDI_BASH/components/custom/100-local.aliases.bash" <<'EOF'
# shellcheck shell=bash
alias work='cd ~/Projects'
alias kctx='kubectl config current-context'
EOF
```

Files under `components/custom/` are sourced after enabled components. The folder lives inside the components git submodule, whose own ignore rules decide whether git lists your files as untracked there; they never get in the way of `gbash update`. Keep them outside the repository (see below) if you prefer a clean `git status`. Prefix filenames with numbers if you need deterministic ordering, for example `100-env.bash`, `200-aliases.bash`, and `900-overrides.bash`.

You can also keep local scripts outside the repository:

```bash
export GAUDI_BASH_CUSTOM="$HOME/.config/gaudi-bash/custom"
```

Or load several custom directories:

```bash
export GAUDI_BASH_CUSTOM_PATHS="$GAUDI_BASH/components/custom:$HOME/.config/gaudi-bash/private"
```

Set `GAUDI_BASH_CUSTOM` or `GAUDI_BASH_CUSTOM_PATHS` in `.bash_profile` before sourcing `gaudi_bash.sh`.

## Components

gaudi-bash ships with a large collection of community-contributed components organized into three categories. The [components README](https://github.com/g-udi/gaudi-bash-components#readme) lists all of them.

### Plugins

Plugins add new shell functions, behaviors and integrations. Some highlights:

- **sudo** -- press Escape twice to toggle `sudo` at the beginning of the current or the previous command
- **fzf** -- fuzzy finder integration
- **history** -- history manipulation
- **cmd-returned-notify** -- terminal bell (BEL) when a long-running command finishes
- **python** -- `shttp` alias for a quick HTTP server and `pyedit` to open a Python module in your editor
- **url** -- `slugify` to turn text into a URL slug (plain, HTML, Markdown or RST output)
- **fasd** / **zoxide** / **autojump** -- fast directory jumping
- **extract** -- extract any archive format with a single command
- **git** / **gitstatus** -- Git helpers and status information
- **node** / **nvm** -- Node.js helpers and version management
- **docker** / **docker-compose** -- Docker workflow helpers
- **ssh** / **sshagent** -- SSH agent management
- **tmux** / **tmuxinator** -- Tmux session management
- **direnv** -- per-directory environment variables

### Completions

Tab-completion definitions for common tools:

- **git** / **git_flow** / **github-cli** -- Git ecosystem
- **docker** / **docker-compose** -- Docker
- **cargo** / **rustup** -- Rust toolchain
- **dotnet** -- .NET CLI
- **yarn** / **npm** / **nvm** -- JavaScript package managers
- **kubectl** / **helm** / **kind** / **minikube** -- Kubernetes
- **terraform** / **vault** / **consul** -- HashiCorp tools
- **system** -- loads the system's Bash completion modules
- **ssh** / **brew** / **pip** / **gem** / **rake** -- Common CLI tools
- **gcloud** / **awscli** -- Cloud provider CLIs

### Aliases

Shortcut aliases for frequently used commands:

- **git** -- extensive set of short Git aliases
- **docker** / **docker-compose** -- Docker shortcuts
- **terraform** / **vault** -- Infrastructure as code
- **tmux** -- Tmux session shortcuts
- **composer** -- PHP Composer aliases
- **directory** -- quick directory navigation (`..`, `...`, `md`, `rd`, etc.)
- **kubectl** -- Kubernetes aliases
- **homebrew** -- Homebrew shortcuts
- **ls** / **general** -- Common listing and utility aliases
- **npm** / **yarn** / **node** -- JavaScript tooling

Use `gbash show plugins`, `gbash show completions` or `gbash show aliases` to see the full list of available components and their descriptions.

## Help Screens

```bash
gbash show                # shows all currently enabled components
gbash show aliases        # shows installed and available aliases
gbash show completions    # shows installed and available completions
gbash show plugins        # shows installed and available plugins
gbash show plugins enabled  # shows the enabled plugins only (same for aliases and completions)
gbash help aliases        # shows the aliases of every enabled alias group
gbash help aliases <name> # shows the aliases of one group, enabled or not
gbash help completions    # shows the table of completions
gbash help plugins        # shows the functions of the enabled plugins
gbash help plugins <name> # shows the functions of one plugin ("all" adds the gaudi-bash functions)
gbash enable plugin <name>... # enables one or more plugins ("all" for every plugin)
gbash disable plugin <name>...  # disables one or more plugins ("all" for every enabled plugin)
gbash migrate             # rewrites absolute or broken links of enabled components as relative ones
gbash doctor [errors|warnings|all]  # reloads with the logs of that level shown, to diagnose loading issues
gbash version             # shows current gaudi-bash version and git SHA
gbash reload              # reloads your bash profile
gbash restart             # re-executes bash (stronger than reload)
gbash backup              # backs up list of enabled components
gbash restore             # restores components from a backup
gbash profile save <name> # save enabled components as a named profile
gbash profile load <name> # load a saved profile
gbash profile list        # list saved profiles
gbash profile rm <name>   # remove a saved profile
gbash update [stable|dev] # updates gaudi-bash core to the latest release (or the development branch)
gbash search <terms>      # searches for components by keyword
```

A command fails (non-zero status) when it could not do what was asked: an unknown command or component type, a component that could not be enabled or disabled (also when it is one of several), a search without a match.

### Settings

Set these in your `.bash_profile` (or `.bashrc`) before the line that loads gaudi-bash:

| Variable | Default | Description |
|---|---|---|
| `GAUDI_BASH_THEME` | `gaudi` | The prompt theme to load; empty for none |
| `GAUDI_BASH_AUTOMATIC_RELOAD_AFTER_CONFIG_CHANGE` | `1` (in the template) | Reload the profile after enabling or disabling components; unset to reload by hand |
| `GAUDI_BASH_LOG_LEVEL` | (none) | `1` shows errors, `2` warnings too, `3` everything (what `gbash doctor` sets for one reload) |
| `GAUDI_LOG_DISABLE_COLOR` | (none) | Set to anything to print the logs without colors |
| `GAUDI_BASH_NO_COLOR` | (none) | `true` leaves the color variables (`RED`, `GREEN`, `NC`, ...) empty |
| `GAUDI_BASH_HISTORY` | `true` | `false` keeps Bash's own history settings, see [History](#history) |
| `GAUDI_BASH_COMMAND_DURATION` | (none) | `true` times every command, see [Command Duration](#command-duration) |
| `GAUDI_BASH_CUSTOM`, `GAUDI_BASH_CUSTOM_PATHS` | `$GAUDI_BASH/components/custom` | Where local scripts are loaded from, see [Local Untracked Customizations](#local-untracked-customizations) |
| `GAUDI_BASH_REMOTE`, `GAUDI_BASH_DEVELOPMENT_BRANCH` | `origin`, `main` | What `gbash update` fetches from |
| `GAUDI_BASH_RESTART_SHELL` | the running Bash | The Bash that `gbash restart` starts |

## Search

If you need to quickly find out which of the plugins, aliases or completions are available for a specific framework, programming language, or an environment, you can _search_ for multiple terms related to the commands you use frequently.
Search will find and print out modules with the name or description matching the terms provided.

### Syntax

```bash
  gbash search term1 [[-|@]term2] [[-|@]term3]....
```

A term prefixed with `-` excludes matches; a term prefixed with `@` only matches a component with exactly that name.

`--alias` (`-a`), `--plugin` (`-p`) or `--completion` (`-c`) searches one component type only, and `--refresh` (`-r`) rebuilds the cached descriptions first. `gbash search --help` shows all of it.

As an example, a ruby developer might want to enable everything related to the commands such as `ruby`, `rake`, `gem`, `bundler`, and `rails`.
Search command helps you find related modules so that you can decide which of them you'd like to use:

```bash
$ gbash search ruby rake gem bundle irb rails
aliases:      bundler  rails
plugins:      chruby  goenv  pyenv  rails  rbenv  ruby  rvm
completions:  bundler  gem  rake
```

Currently enabled modules will be shown in green.

### Searching with Negations

You can prefix a search term with a "-" to exclude it from the results.
In the above example, if we wanted to hide `chruby`,
we could change the command as follows:

```bash
$ gbash search ruby rake gem bundle irb rails -chruby
aliases:      bundler  rails
plugins:      goenv  pyenv  rails  rbenv  ruby  rvm
completions:  bundler  gem  rake
```

### Using Search to Enable or Disable Components

By adding a `--enable` or `--disable` to the search command, you can automatically enable all modules that come up as a result of a search query.
This could be quite handy if you like to enable a bunch of components related to the same topic.

### Disabling ASCII Color

To remove the non-printing characters responsible for the coloring of the search output, pass the `--no-color` (`-x`) flag.
Enabled components are marked with a checkmark (`✓`) after their name:

```bash
$ gbash search ruby rake gem bundle irb rails -chruby --no-color
aliases:      bundler  rails
plugins:      goenv  pyenv  rails  rbenv  ruby  rvm
completions:  bundler  gem  rake
```

## Gaudi Theme

gaudi-bash ships with the **gaudi** prompt theme — a modular, segment-based prompt with async rendering and Nerd Font icon support.

### Prompt Layout

The prompt is divided into three zones, each defined as an array of segment names in `gaudi.configs.bash`:

```
 RIGHT_PROMPT                                    LEFT_PROMPT   ASYNC_PROMPT
 [battery] [time] [user] [host]    \r            [cwd]         [scm] [node] [docker] [k8s] ...
                                                  >> _
```

| Zone | Config Array | Rendering | Purpose |
|------|-------------|-----------|---------|
| **Left** | `GAUDI_PROMPT_LEFT` | Synchronous | Core context: multiplexer, command duration, cwd |
| **Right** | `GAUDI_PROMPT_RIGHT` | Synchronous | System info: battery, time, user, host |
| **Async** | `GAUDI_PROMPT_ASYNC` | Background | Expensive checks: git status, language versions, cloud/k8s context |

Async segments render in the background after the prompt is drawn, then overwrite the prompt line with the result. A cache ensures the prompt always shows the last known async state while fresh data is computed — no blank flashes between renders.

### Display Modes

| Variable | Default | Description |
|---|---|---|
| `GAUDI_SPLIT_PROMPT` | `true` | `true`: right-aligned RIGHT + left-aligned LEFT on one line. `false`: RIGHT, LEFT and ASYNC rendered inline, one after the other |
| `GAUDI_SPLIT_PROMPT_TWO_LINES` | `false` | When split is enabled, use a newline instead of carriage return between sides |
| `GAUDI_ENABLE_SYMBOLS` | `true` | Show Nerd Font icons. Set to `false` for plain text fallback |
| `GAUDI_PROMPT_DEFAULT_PREFIX` | `" "` | Default prefix for all segments |
| `GAUDI_PROMPT_DEFAULT_SUFFIX` | `" "` | Default suffix for all segments |

### Available Segments

Each segment is a standalone file in `components/themes/gaudi/segments/` and can be placed in any of the three prompt arrays. The tables below cover the most commonly used ones; the [theme README](https://github.com/g-udi/gaudi-theme#readme) describes every segment.

**Environment and tooling:**

| Segment | Shows | Key Variables |
|---------|-------|---------------|
| `scm` | Git/Hg/SVN/Perforce branch, dirty/clean/staged state | `GAUDI_SCM_SHOW`, `GAUDI_SCM_FETCH` |
| `node` | Node.js version (from nvm/nodenv/system) | `GAUDI_NODE_SHOW`, `GAUDI_NODE_DEFAULT_VERSION`, `GAUDI_NODE_COLOR` |
| `pyenv` | Python version via pyenv | `GAUDI_PYENV_SHOW`, `GAUDI_PYENV_COLOR` |
| `ruby` | Ruby version (from `ruby -v`) | `GAUDI_RUBY_SHOW`, `GAUDI_RUBY_COLOR` |
| `golang` | Go version | `GAUDI_GOLANG_SHOW`, `GAUDI_GOLANG_COLOR` |
| `rust` | Rust version | `GAUDI_RUST_SHOW`, `GAUDI_RUST_COLOR` |
| `java` | Java version | `GAUDI_JAVA_SHOW`, `GAUDI_JAVA_COLOR` |
| `elixir` | Elixir version | `GAUDI_ELIXIR_SHOW`, `GAUDI_ELIXIR_COLOR` |
| `php` | PHP version | `GAUDI_PHP_SHOW`, `GAUDI_PHP_COLOR` |
| `haskell` | Haskell Stack version | `GAUDI_HASKELL_SHOW`, `GAUDI_HASKELL_COLOR` |
| `julia` | Julia version | `GAUDI_JULIA_SHOW`, `GAUDI_JULIA_COLOR` |
| `elm` | Elm version | `GAUDI_ELM_SHOW`, `GAUDI_ELM_COLOR` |
| `angular` | Angular version from `node_modules/angular` | `GAUDI_ANGULAR_SHOW`, `GAUDI_ANGULAR_COLOR` |
| `react` | React version from `node_modules/react` | `GAUDI_REACT_SHOW`, `GAUDI_REACT_COLOR` |
| `package` | Package version from `package.json` | `GAUDI_PACKAGE_SHOW`, `GAUDI_PACKAGE_COLOR` |

**Infrastructure:**

| Segment | Shows | Key Variables |
|---------|-------|---------------|
| `docker` | Docker server version | `GAUDI_DOCKER_SHOW`, `GAUDI_DOCKER_COLOR` |
| `kubecontext` | kubectl context and namespace | `GAUDI_KUBECONTEXT_SHOW`, `GAUDI_KUBECONTEXT_COLOR` |

**Shell context:**

| Segment | Shows | Key Variables |
|---------|-------|---------------|
| `cwd` | Current working directory (shortened) | `GAUDI_CWD_SHOW`, `GAUDI_CWD_SHORTEN`, `GAUDI_CWD_COLOR` |
| `duration` | Last command execution time | `GAUDI_DURATION_SHOW`, `GAUDI_DURATION_MIN_SECONDS`, `GAUDI_DURATION_COLOR` |
| `battery` | Battery level and charging state | `GAUDI_BATTERY_SHOW`, `GAUDI_BATTERY_THRESHOLD` |
| `time` | Current timestamp | `GAUDI_TIME_SHOW`, `GAUDI_TIME_COLOR` |
| `user` | Current username | `GAUDI_USER_SHOW`, `GAUDI_USER_COLOR` |
| `host` | Hostname | `GAUDI_HOST_SHOW`, `GAUDI_HOST_COLOR` |
| `multiplexer` | Detached tmux and screen session counts | `GAUDI_MULTIPLEXER_SHOW` |

### Configuring Segments

Segments follow the same pattern and most of them support these variables (replace `SEGMENT` with the segment name in uppercase):

- `GAUDI_SEGMENT_SHOW` — set to `false` to hide without removing from the array
- `GAUDI_SEGMENT_COLOR` — foreground/background color
- `GAUDI_SEGMENT_SYMBOL` — Nerd Font icon (Unicode escape)
- `GAUDI_SEGMENT_PREFIX` / `GAUDI_SEGMENT_SUFFIX` — padding around the content

Set these in your `.bash_profile` before gaudi-bash is sourced, and `export` them: segments in `GAUDI_PROMPT_ASYNC` are rendered by a background Bash process that only sees exported variables.

### Customizing the Prompt

To change which segments appear and where, override the arrays in your `.bash_profile` **after** the line that sources `gaudi_bash.sh` (the theme assigns its default arrays when it loads):

```bash
# Minimal prompt: just cwd and git
GAUDI_PROMPT_LEFT=(cwd)
GAUDI_PROMPT_RIGHT=(time user)
GAUDI_PROMPT_ASYNC=(scm)

# Or add kubecontext to async
GAUDI_PROMPT_ASYNC=(scm kubecontext docker node)
```

### Creating a Custom Segment

Create a file `components/themes/gaudi/segments/mysegment.bash`:

```bash
# shellcheck shell=bash

GAUDI_MYSEGMENT_SHOW="${GAUDI_MYSEGMENT_SHOW=true}"
GAUDI_MYSEGMENT_COLOR="${GAUDI_MYSEGMENT_COLOR="$GAUDI_GREEN"}"
GAUDI_MYSEGMENT_SYMBOL="\uf005"

gaudi_mysegment() {
  [[ $GAUDI_MYSEGMENT_SHOW == false ]] && return

  local content="my info here"
  [[ -z "$content" ]] && return

  gaudi::section \
    "$GAUDI_MYSEGMENT_COLOR" \
    "" \
    "$GAUDI_MYSEGMENT_SYMBOL" \
    "$content" \
    "$GAUDI_PROMPT_DEFAULT_SUFFIX"
}
```

Then add `mysegment` to one of the prompt arrays in your config.

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

The gaudi theme shows it in its `duration` segment, which has a threshold of its own: there, set `GAUDI_DURATION_MIN_SECONDS` (default `1`) instead of `COMMAND_DURATION_MIN_SECONDS`.

## History

gaudi-bash gives Bash an unlimited history that every shell appends to and that is kept in a file of its own, so that a shell started without gaudi-bash can not cut it short:

| Setting | Bash starts with | gaudi-bash sets |
|---|---|---|
| `HISTSIZE` | `500` | `-1` (no limit) |
| `HISTFILESIZE` | `500` | `unlimited` |
| `HISTFILE` | `~/.bash_history` | `${XDG_STATE_HOME:-~/.local/state}/bash/history` |

Only the values Bash starts with are replaced: a `HISTSIZE`, `HISTFILESIZE` or `HISTFILE` that you set yourself before gaudi-bash is loaded is kept. To keep all of Bash's own history settings, set this before gaudi-bash is loaded:

```bash
export GAUDI_BASH_HISTORY=false
```

Your existing `~/.bash_history` is not copied to the new file; copy it yourself if you want the old commands in the new history. The `hr` command lists your ten most used commands.

## Profiles

Profiles let you save, switch between and share complete component configurations. This is an upgrade over the basic backup/restore — you can maintain multiple named profiles for different workflows.

```bash
gbash profile save <name>     # save current enabled components as a named profile
gbash profile load <name>     # disable everything, then enable components from profile
gbash profile list            # list all saved profiles
gbash profile rm <name>       # delete a saved profile
```

Profiles are stored as plain text files in `$GAUDI_BASH/profiles/` with a simple `<type> <name>` format (one component per line). A profile name can only hold letters, digits, `_` and `-`. The `load` command validates the profile before applying any changes: every line has to be well formed and name a component that exists, otherwise nothing is disabled or enabled and the command fails.

## Backup and Restore

For quick one-off backups (e.g., before experimenting), you can use the simpler backup/restore commands:

```bash
gbash backup    # saves the enabled components as the profile named "backup"
gbash restore   # enables every component listed in that backup
```

The backup is a profile like any other (`$GAUDI_BASH/profiles/backup.gaudi-bash`), so it shows up in `gbash profile list`. The name `backup` is reserved for it: `gbash backup` overwrites that profile without asking.

`gbash restore` only enables what the backup lists, components enabled since then stay enabled; use `gbash profile load backup` to go back to exactly the saved set. When there is no `backup` profile, `gbash restore` reads the backup file written by older versions (`$GAUDI_BASH/tmp/enabled.gaudi-bash.backup`, a list of `gbash enable <type> <name>` or `gaudi-bash enable ...` lines). Lines that do not match either format are skipped.

For named, reusable configurations, use profiles instead.
