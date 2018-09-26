#!/usr/bin/env bash
#
# Rust
#
# Rust is a systems programming language sponsored by Mozilla Research.
# Link: https://www.rust-lang.org

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_RUST_SHOW="${GAUDI_RUST_SHOW=true}"
GAUDI_RUST_SHOW_VERSION="${GAUDI_RUST_SHOW_VERSION=true}"
GAUDI_RUST_SHOW_TOOLCHAIN="${GAUDI_RUST_SHOW_TOOLCHAIN=false}"
GAUDI_RUST_PREFIX="${GAUDI_RUST_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_RUST_SUFFIX="${GAUDI_RUST_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_RUST_SYMBOL="${GAUDI_RUST_SYMBOL="𝗥"}"
GAUDI_RUST_COLOR="${GAUDI_RUST_COLOR=$(tput setaf 075)}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current version of Rust
gaudi_rust() {
  [[ $GAUDI_RUST_SHOW == false ]] && return

  # If there are Rust-specific files in current directory
  [[ -f Cargo.toml || -n $(find . -not -path '*/\.*' -maxdepth 1 -name "*.rs") ]] || return

  gaudi::exists rustc || return

    local -a rust_version
  [[ $GAUDI_RUST_SHOW_VERSION == false ]] || rust_version+="v$(rustc --version | grep --color=never -oE '[[:digit:]]+\.[[:digit:]]+\.[[:digit:]]')"
  [[ $GAUDI_RUST_SHOW_TOOLCHAIN == false ]] || rust_version+=$(rustc --version | grep --colour=never -oE '(stable|beta|nightly)' || echo ' stable')

  gaudi::section \
    "$GAUDI_RUST_COLOR" \
    "$GAUDI_RUST_PREFIX" \
    "$GAUDI_RUST_SYMBOL" \
    "$rust_version" \
    "$GAUDI_RUST_SUFFIX"
}
