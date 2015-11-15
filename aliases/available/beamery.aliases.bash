_arSavePwd() {
    _ARPWD=`pwd`
}

_arRollBackPwd() {
    cd $_ARPWD;
}

_arAnyAction() {
    echo "Folder" `pwd` "..."
    echo "  ^ " $@
    $@
}

_arGitAction() {
    echo "Folder" `pwd` "..."
    if [ -f ".git/config" ]; then
        echo "  ^ " $@
        $@
    else
        echo "  ^ ignoring"
    fi
}

_arNodeAction() {
    echo "Folder" `pwd` "..."
    if [ -f "package.json" ]; then
        echo "  ^ " $@
        $@
    else
        echo "  ^ ignoring"
    fi
}

_arBowerAction() {
    echo "Folder" `pwd` "..."
    if [ -f "bower.json" ]; then
        echo "  ^ " $@
        $@
    else
        echo "  ^ ignoring"
    fi
}

_arNi() {
    _arSavePwd
    find . -maxdepth 1 -type d | while read -r line; do cd "$_ARPWD/$line" && _arNodeAction npm install; done;
    _arRollBackPwd
}

_arNu() {
    _arSavePwd
    find . -maxdepth 1 -type d | while read -r line; do cd "$_ARPWD/$line" && _arNodeAction npm update; done;
    _arRollBackPwd
}

_arGp() {
    _arSavePwd
    find . -maxdepth 1 -type d | while read -r line; do cd "$_ARPWD/$line" && _arGitAction git pull; done;
    _arRollBackPwd
}

_arGco() {
    _arSavePwd
    find . -maxdepth 1 -type d | while read -r line; do cd "$_ARPWD/$line" && _arGitAction git checkout $@; done;
    _arRollBackPwd
}

_arA() {
    _arSavePwd
    find . -maxdepth 1 -type d | while read -r line; do cd "$_ARPWD/$line" && _arAnyAction $@; done;
    _arRollBackPwd
}

_arN() {
    _arSavePwd
    find . -maxdepth 1 -type d | while read -r line; do cd "$_ARPWD/$line" && _arNodeAction $@; done;
    _arRollBackPwd
}

_arB() {
    _arSavePwd
    find . -maxdepth 1 -type d | while read -r line; do cd "$_ARPWD/$line" && _arBowerAction $@; done;
    _arRollBackPwd
}

_arG() {
    _arSavePwd
    find . -maxdepth 1 -type d | while read -r line; do cd "$_ARPWD/$line" && _arGitAction $@; done;
    _arRollBackPwd
}

_arnl() {

    echo "Folder" `pwd` "..."

    if [ -f "package.json" ]; then
        echo "  ^ npm link packages files matching " $@
        _armatchingPackages=($(cat package.json | grep "$@" | cut -d \" -f2))
        for i in "${_armatchingPackages[@]}"
        do
            :
           npm link $i
        done
    else
        echo "  ^ ignoring"
    fi
}

_arnla() {
    _arSavePwd
    find . -maxdepth 1 -type d | while read -r line; do cd "$_ARPWD/$line" && _arnl $@; done;
    _arRollBackPwd
}

alias arni=_arNi
alias arnu=_arNu
alias argp=_arGp
alias argco=_arGco
alias arnl=_arnl
alias arnla=_arnla

alias ara=_arA
alias arn=_arN
alias arb=_arB
alias arg=_arG