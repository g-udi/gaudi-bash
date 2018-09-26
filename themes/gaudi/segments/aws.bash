#!/usr/bin/env bash
#
# Amazon Web Services (AWS)
#
# The AWS Command Line Interface (CLI) is a unified tool to manage AWS services.
# Link: https://aws.amazon.com/cli/

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_AWS_SHOW="${GAUDI_AWS_SHOW=true}"
GAUDI_AWS_PREFIX="${GAUDI_AWS_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_AWS_SUFFIX="${GAUDI_AWS_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_AWS_SYMBOL="${GAUDI_AWS_SYMBOL="\\ue7ad"}"
GAUDI_AWS_COLOR="${GAUDI_AWS_COLOR="$YELLOW"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Shows selected AWS-cli profile.
gaudi_aws() {
  [[ $GAUDI_AWS_SHOW == false ]] && return

  # Check if the AWS-cli is installed
  gaudi::exists aws || return

  # Backwards compatibility with old awscli versions
  [[ -z $CURRENT_AWS_PROFILE ]] &&
    CURRENT_AWS_PROFILE=$AWS_DEFAULT_PROFILE

  # Is the current profile not the default profile
  [[ -z $CURRENT_AWS_PROFILE ]] || [[ "$CURRENT_AWS_PROFILE" == "default" ]] &&
    return

  # Show prompt section
  gaudi::section \
    "$GAUDI_AWS_COLOR" \
    "$GAUDI_AWS_PREFIX" \
    "$GAUDI_AWS_SYMBOL" \
    "$CURRENT_AWS_PROFILE" \
    "$GAUDI_AWS_SUFFIX"
}