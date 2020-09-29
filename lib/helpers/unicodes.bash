#!/usr/bin/env bash
# shellcheck disable=SC2034

# Print out the set of supported Unicode characters for the terminal

__fast_chr () {
    local __octal
    local __char

    printf -v __octal '%03o' $1
    printf -v __char \\$__octal
    REPLY=$__char
}

__unichr () {
    # Ordinal of char
    local c=$1
    # Byte ctr
    local l=0
    # Ceiling
    local o=63
    # Accum. bits
    local p=128
    # Output string
    local s=''

    (( c < 0x80 )) && { __fast_chr "$c"; echo -n "$REPLY"; return; }

    while (( c > o )); do
        __fast_chr $(( t = 0x80 | c & 0x3f ))
        s="$REPLY$s"
        (( c >>= 6, l++, p += o+1, o>>=1 ))
    done

    __fast_chr $(( t = p | c ))
    echo -n "$REPLY$s"
}

_getUnicodes () {
  printf "\n%s\n\n" "Getting all unicode characters..."
  for (( i=0x2500; i<0x2600; i++ )); do
      __unichr "$i"
  done
  echo ""
}

