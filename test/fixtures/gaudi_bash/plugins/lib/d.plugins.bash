#!/usr/bin/env bash

_finalize_hook_test() {
	export GAUDI_FINALIZE_HOOK_RAN="true"
}

GAUDI_BASH_LIBRARY_FINALIZE_HOOK+=("_finalize_hook_test")
alias test_finalize_hook="registered"
