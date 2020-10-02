# shellcheck disable=SC1090

cite about-plugin
about-plugin 'Autojump configuration [ref: https://github.com/wting/autojump'

# Only supports the Homebrew variant, Debian and Arch at the moment.
# Feel free to provide a PR to support other install locations
if command -v brew &>/dev/null && [[ -s $(brew --prefix)/etc/profile.d/autojump.sh ]]; then
  source "$(brew --prefix)"/etc/profile.d/autojump.sh
elif command -v dpkg &>/dev/null && dpkg -s autojump &>/dev/null ; then
  source "$(dpkg-query -S autojump.sh | cut -d' ' -f2)"
elif command -v pacman &>/dev/null && pacman -Q autojump &>/dev/null ; then
  source "$(pacman -Ql autojump | grep autojump.sh | cut -d' ' -f2)"
fi
