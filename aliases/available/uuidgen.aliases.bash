cite 'uuid-alias'
about-alias 'uuidgen aliases'

# Linux
if _command_exists uuid; then
  alias uuidu="uuid | tr '[:lower:]' '[:upper:]'"
  alias uuidl=uuid
# macOS/BSD
elif _command_exists uuidgen; then
  alias uuidu="uuidgen"
  alias uuid="uuidgen | tr '[:upper:]' '[:lower:]'"
  alias uuidl=uuid
fi
