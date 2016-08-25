cite about-plugin
about-plugin 'beamery helpers functions'

# Colors and visual Configurations
export magenta='\033[35m'
export red='\033[31m'
export yellow='\033[33m'
export NC='\033[0m'

# Some helper functions to check if a certain command exists
command_exists () {
    type "$1" &> /dev/null ;
}

# Switch the branches of .git repos into a specific branch
# The command accepts an optional argument which is the new branch to checkout
# If no argument was passed then the command will default and switch all repos to master
    # Default paramteres will be -> git checkout master

bmr_switch_branches() {
    BRANCH=${1:-master}
    printf "${red} Please note that this will stash any changes made in the repos and flip the current branch${NC}\n"
    read -p "Are you sure you want to proceed? [Y/N] " -n 1;
    echo "";
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "cd '{}' && printf '\nChecking repository:${magenta}'{}'${NC}\n' && git stash && git checkout $BRANCH" \;
    fi
}

# Switch the branches of .git repos into a specific branch and update from the latest remote origin
# The command accepts two optional argument which is the new branch to checkout
    # If no argument was passed then the command will default and switch all repos to master
    # If a second argument is passed then it will from that remote, if not it will default to origin
    # Default paramteres will be -> git checkout master && git pull origin master

bmr_switch_branches_and_update() {
    # if a second parameter is defined as a remote it will be used, if not then it will pull from origin
    BRANCH=${1:-master}
    REMOTE=${2:-origin}
    printf "${red} Please note that this will stash any changes made in the repos and flip the current branch${NC}\n"
    read -p "Are you sure you want to proceed? [Y/N] " -n 1;
    echo "";
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "cd '{}' && printf '\nChecking and updating from $REMOTE repository:${magenta}'{}'${NC}\n' && git stash && git checkout $BRANCH && git pull $REMOTE $BRANCH" \;
    fi
}

# Update .git branchesfrom the latest remote origin
# The command accepts two optional argument which is the new branch to checkout
    # If no argument was passed then the command will default and switch all repos to master
    # If a second argument is passed then it will from that remote, if not it will default to origin
    # Default paramteres will be -> git pull origin master

bmr_update_branches() {
    BRANCH=${1:-master}
    REMOTE=${2:-origin}
     find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "cd '{}' && printf '\nUpdating repository: ${magenta}'{}'${NC} on branch: ${yellow}$BRANCH${NC} from remote: ${yellow}$REMOTE${NC}\n' && git pull $REMOTE $BRANCH" \;
}

# Clean any stashed commits

bmr_clean_stash() {
    BRANCH=${1:-master}
    printf "${red} Please note that this will clear any stashes you have saved${NC}\n"
    read -p "Are you sure you want to proceed? [Y/N] " -n 1;
    echo "";
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "cd '{}' && printf '\nChecking repository:${magenta}'{}'${NC}\n' && git stash clear" \;
    fi
}

# List the current branches on the repos
# This is useful to know which branches are flipped on which repos

bmr_list_active_branches() {
    find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "cd '{}' && printf 'Repository: ${magenta}'{}'${NC} is on branch: ${yellow}' && git branch && printf '${NC}\n'" \;
}

# List all the branches of a .git repository sorted by date creation
# This is useful to identify dead branches

bmr_audit_branches() {
    find . -maxdepth 1 -type d -print0 \( ! -name . \) -exec bash -c "cd '{}' && printf 'Checking branches on repository: ${magenta}'{}'${NC}' &&  git for-each-ref --sort='-authordate:iso8601' --format=' %(authordate:relative)%09%(refname:short)' refs/remotes && printf '\n'" \;
}

# Remove all node_modules from all the repos and run zelda to link and download all
bmr_link_node_modules() {

    CWD="$(pwd)"

    printf "${red} Please note that this will remove all node_modules from all repos${NC}\n"
    read -p "Do you want to clean node_modules before linking? [Y/N] " -n 1;
    echo "";
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        find . -maxdepth 1 -type d -print0 \( ! -name . \) -exec bash -c "cd '{}' && echo ' ---> removing node_modules' && rm -rf node_modules" \;
    fi

    for app in "${apis[@]}"; do
        printf "Linking npm_modules in: ${magenta}$CWD/${app}${NC}";
        echo "";
        cd "$CWD/${app}" && zelda ../
        echo "";
    done

    apis=(
      api-core
      service-queue
      api-sherlock
      api-mail
    )
}

# Clean remote branches that have been merged into master and delete them from remotes as well

bmr_clean_remote_branches() {
    find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "cd '{}' && printf 'Checking branches on repository: ${magenta}'{}'${NC}' && git branch -r --merged master | egrep -iv '(master|development)' | sed 's/origin\///g'| xargs -n 1 git push --delete origin" \;
}

# Clean any local branches that have been deleted on remote

bmr_clean_local_branches() {
    find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "cd '{}' && printf 'Checking branches on repository: ${magenta}'{}'${NC}' && git remote prune origin" \;
}

# Total cleaning on branches by first performing deletion of remote branches that have been merged into master
# Second step will be to execute deletio of local branches that are not on remote/merged into master

bmr_clean_branches() {
    clean_remote_branches
    clean_local_branches
}

# Generate NPM report using the npm-check module to inspect the state of our npm modules
# The function will check if npm-check is installed and install it otherwise
# The report will be generated in the root directory and will be called npm-report.txt

bmr_generate_npm_report() {
    if command_exists npm-check ; then
        find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "cd '{}' && printf 'Examining NPM modules for ${magenta}'{}'${NC}' && echo '{}' >> ../npm-report.txt && npm-check >> ../npm-report.txt" \;
    else
        printf 'npm-check module was not found. Installing now:';
        npm install -g npm-check
        find . -maxdepth 1 -type d \( ! -name . \) -exec bash -c "cd '{}' && printf 'Examining NPM modules for ${magenta}'{}'${NC}' && echo '{}' >> ../npm-report.txt && npm-check >> ../npm-report.txt" \;
    fi
}

bmr_add_beamery_remotes() {

    for app in "${applications[@]}"; do
        set -- "${app}"
        IFS=":"; declare -a Array=($*)
        printf "Remote will be: ${magenta}ssh://git@deis.beamery.com:2222/${Array[1]}.git${NC}";
        echo "";
        if [ "${Array[0]}" == "app-site" ]; then
            (cd "${Array}" ; git remote add deis "ssh://git@deis.beamery.com:2222/${Array[1]}.git" ; git remote add preview "dokku@preview.beamery.com:preview.beamery.com");
        else
            (cd "${Array}" ; git remote add deis "ssh://git@deis.beamery.com:2222/${Array[1]}.git"; git remote add preview "dokku@preview.beamery.com:"${Array[1]});
        fi
        echo "";
    done

    applications=(
      app-portal:portal-app
      api-mail:mail
      api-sherlock:sherlock
      api-portal:portal
      app-admin:admin
      app-application:app
      app-site:site
      api-notifications:notify
      service-queue:queue
      api-core:api
    )
}