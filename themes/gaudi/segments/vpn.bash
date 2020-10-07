#!/usr/bin/env bash
#
# VPN
# Show if the connection is made through a VPN
# Currently supports VPN Unlimited

# ------------------------------------------------------------------------------
# Configuration
# ------------------------------------------------------------------------------

GAUDI_VPN_SHOW="${GAUDI_VPN_SHOW=true}"
GAUDI_VPN_SYMBOL="\\uf98c"
GAUDI_VPN_PREFIX="${GAUDI_VPN_PREFIX="$GAUDI_PROMPT_DEFAULT_PREFIX"}"
GAUDI_VPN_SUFFIX="${GAUDI_VPN_SUFFIX="$GAUDI_PROMPT_DEFAULT_SUFFIX"}"
GAUDI_VPN_COLOR="${GAUDI_VPN_COLOR="$WHITE$BACKGROUND_ORANGE"}"

# ------------------------------------------------------------------------------
# Section
# ------------------------------------------------------------------------------

gaudi_vpn () {
  [[ $GAUDI_VPN_SHOW == false ]] && return

  ifconfig ipsec0 &> /dev/null && ifconfig ipsec0 &> /dev/null && vpn_active=true

	[[ -z $vpn_active ]] && return

	gaudi::section \
			"$GAUDI_VPN_COLOR" \
			"$GAUDI_VPN_PREFIX" \
			"$GAUDI_VPN_SYMBOL" \
			"\\e[1;5DVPN" \
			"$GAUDI_VPN_SUFFIX"
}
