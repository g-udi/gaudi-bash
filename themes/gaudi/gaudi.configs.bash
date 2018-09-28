
GAUDI_SPLIT_PROMPT="${GAUDI_SPLIT_PROMPT=true}"
GAUDI_SPLIT_PROMPT_TWO_LINES="${GAUDI_SPLIT_PROMPT_TWO_LINES=true}"
GAUDI_ENABLE_HUSHLOGIN="${GAUDI_ENABLE_HUSHLOGIN=true}"
GAUDI_ENABLE_SYMBOLS="${GAUDI_ENABLE_SYMBOLS=true}"
GAUDI_PROMPT_DEFAULT_PREFIX=" "
GAUDI_PROMPT_DEFAULT_SUFFIX=" "

GAUDI_PROMPT_ASYNC=(
  dockercompose # Docker Compose segment
  aws           # Amazon WebServices (AWS) segment
  kubecontext   # Kubectl context segment
  docker        # Docker segment
  vagrant       # Vagrant segment
  node          # Node.js segment
  ruby          # Ruby segment
  elixir        # Elixir segment
  xcode         # Xcode segment
  swift         # Swift segment
  golang        # Go segment
  angular       # Angular segment
  react         # React segment
  php           # PHP segment
  rust          # Rust segment
  haskell       # Haskell Stack segment
  julia         # Julia segment
  conda         # conda virtualenv segment
  pyenv         # Pyenv segment
  elm           # Elm segment
  dotnet        # .NET segment
  ember         # Ember.js segment
  java          # Java segment
  maven         # Maven segment
  gradle        # Gradle segment
  package       # Javascript package managers
  multiplexer   # Multiplexers segment
)

GAUDI_PROMPT_LEFT=(
  jobs          # Background jobs indicator
  vpn           # VPN section
  scm           # code management segment (git, mercurial, perforce, etc.)
  cwd           # Current working directory
  elapsed
)

GAUDI_PROMPT_RIGHT=(
  system        # System stats segment
  battery       # Battery level and status
  time          # Time stampts segment
  user          # Username segment
  host          # Hostname segment
)