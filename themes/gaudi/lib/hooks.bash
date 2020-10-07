#!/usr/bin/env bash

GAUDI_HOOKS=(
    elapsed       # Last command runtime
)

if [[ -n "${GAUDI_HOOKS}" ]]; then
for hook in ${GAUDI_HOOKS[@]}; do
    source "$GAUDI_ROOT/lib/hooks/$hook.bash"
    gaudi_$hook
done
fi;
