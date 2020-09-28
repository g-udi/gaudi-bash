cite about-alias
about-alias 'docker abbreviations'

alias dk='docker'
# List last Docker container
alias dklc='docker ps -l'
# List last Docker container ID
alias dklcid='docker ps -l -q'
alias dklcip='docker inspect -f "{{.NetworkSettings.IPAddress}}" $(docker ps -l -q)'  # Get IP of last Docker container
# List running Docker containers
alias dkps='docker ps'
# List all Docker containers
alias dkpsa='docker ps -a'
# List Docker images
alias dki='docker images'
# Delete all Docker containers
alias dkrmac='docker rm $(docker ps -a -q)'

# Delete all untagged Docker images
case $OSTYPE in
  darwin*|*bsd*|*BSD*)
    alias dkrmui='docker images -q -f dangling=true | xargs docker rmi'
    ;;
  *)
    alias dkrmui='docker images -q -f dangling=true | xargs -r docker rmi'
    ;;
esac

if [ ! -z "$(command ls "${BASH_IT}/enabled/"{[0-9][0-9][0-9]${BASH_IT_LOAD_PRIORITY_SEPARATOR}docker,docker}.plugin.bash 2>/dev/null | head -1)" ]; then
    # Delete most recent (i.e., last) Docker container
    alias dkrmlc='docker-remove-most-recent-container'
    # Delete all untagged images and exited containers
    alias dkrmall='docker-remove-stale-assets'
    # Delete most recent (i.e., last) Docker image
    alias dkrmli='docker-remove-most-recent-image'
    # Delete images for supplied IDs or all if no IDs are passed as arguments
    alias dkrmi='docker-remove-images'
    # Output a graph of image dependencies using Graphiz
    alias dkideps='docker-image-dependencies'
    # List environmental variables of the supplied image ID
    alias dkre='docker-runtime-environment'
fi

# Enter last container (works with Docker 1.3 and above)
alias dkelc='docker exec -it $(dklcid) bash --login'
alias dkrmflast='docker rm -f $(dklcid)'
alias dkbash='dkelc'
alias dkex='docker exec -it '
alias dkri='docker run --rm -i '
alias dkric='docker run --rm -i -v $PWD:/cwd -w /cwd '
alias dkrit='docker run --rm -it '
alias dkritc='docker run --rm -it -v $PWD:/cwd -w /cwd '

# Added more recent cleanup options from newer docker versions
alias dkip='docker image prune -a -f'
alias dkvp='docker volume prune -f'
alias dksp='docker system prune -a -f'
