#!/usr/bin/env bash
#
# .NET
#
# .NET Framework is a software framework developed by Microsoft.
# It includes a large class library and provides language interoperability
# across several programming languages.
# Link: https://www.microsoft.com/net

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_DOTNET_SHOW="${GAUDI_DOTNET_SHOW=true}"
GAUDI_DOTNET_PREFIX="${GAUDI_DOTNET_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_DOTNET_SUFFIX="${GAUDI_DOTNET_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_DOTNET_SYMBOL="${GAUDI_DOTNET_SYMBOL=".NET"}"
GAUDI_DOTNET_COLOR="${GAUDI_DOTNET_COLOR="$MAGENTA"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current version of .NET SDK
gaudi_dotnet() {
  [[ $GAUDI_DOTNET_SHOW == false ]] && return

  # Show DOTNET status only for folders containing project.json, global.json, .csproj, .xproj or .sln files
  [[ -f project.json || -f global.json || 
     -n $(find . -not -path '*/\.*' -maxdepth 1 -name "*.csproj") || 
     -n $(find . -not -path '*/\.*' -maxdepth 1 -name "*.xproj")  || 
     -n $(find . -maxdepth 1 -name "*.sln") 
  ]] || return

  gaudi::exists dotnet || return

  # dotnet-cli automatically handles SDK pinning (specified in a global.json file)
  # therefore, this already returns the expected version for the current directory
  local dotnet_version=$(dotnet --version 2>/dev/null)

  gaudi::section \
    "$GAUDI_DOTNET_COLOR" \
    "$GAUDI_DOTNET_PREFIX" \
    "$GAUDI_DOTNET_SYMBOL" \
    "$dotnet_version" \
    "$GAUDI_DOTNET_SUFFIX"
}
