#!/usr/bin/env bash
#
#  Kubernetes (kubectl)
#
# Kubernetes is an open-source system for deployment, scaling,
# and management of containerized applications.
# Link: https://kubernetes.io/

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_KUBECONTEXT_SHOW="${GAUDI_KUBECONTEXT_SHOW=true}"
GAUDI_KUBECONTEXT_PREFIX="${GAUDI_KUBECONTEXT_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_KUBECONTEXT_SUFFIX="${GAUDI_KUBECONTEXT_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_KUBECONTEXT_SYMBOL="${GAUDI_KUBECONTEXT_SYMBOL="\\ue773"}"
GAUDI_KUBECONTEXT_COLOR="${GAUDI_KUBECONTEXT_COLOR="$MAGENTA"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

# Show current context in kubectl
gaudi_kubecontext () {
  [[ $GAUDI_KUBECONTEXT_SHOW == false ]] && return

  gaudi::exists kubectl || return

  local kube_context="$(kubectl config current-context 2>/dev/null)"

  local kube_namespace=$(kubectl config view -o jsonpath="{.contexts[?(@.name == \"${kube_context}\")].context.namespace}")

  if [[ -z $kube_namespace ]]; then
    kube_namespace="default"
  fi

  [[ -z $kube_context ]] && return

  gaudi::section \
    "$GAUDI_KUBECONTEXT_COLOR" \
    "$GAUDI_KUBECONTEXT_PREFIX" \
    "$GAUDI_KUBECONTEXT_SYMBOL" \
    "$kube_context | $kube_namespace" \
    "$GAUDI_KUBECONTEXT_SUFFIX"
}
