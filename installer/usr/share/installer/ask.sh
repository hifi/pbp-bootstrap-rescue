# we avoid spawning a sub-shell but have re-include guard
[ "$(type -t ask)" == "function" ] && return

# include default value overrides
[ -f /tmp/installer-answers ] && . /tmp/installer-answers
touch /tmp/installer-answers

# ask <question> <out> [default]
ask() {
    [ $# -lt 2 ] && err "ask() requires two arguments"

    answer=''
    while [ "0" ]; do
        if [ $# -gt 2 ]; then
            echo -n "$1 [$3] "
        else
            echo -n "$1 "
        fi
        read answer
        [ "$answer" == "" ] && [ $# -eq 2 ] && continue
        [ "$answer" != "!" ] && break
        /bin/bash -i
    done

    [ "$answer" == "" ] && [ $# -gt 2 ] && answer=$3

    eval "$2='$answer'"
}

# ask_q <question> <Q_out_and_default> [options]
ask_q() {
    [ $# -lt 2 ] && err "ask_q() requires two arguments"
    [[ $2 == Q_* ]] || err "ask_q() requires that the second argument starts with Q_"

    question="$1"
    qvar="$2"

    shift
    shift

    while [ "0" ]; do
        ask "$question" $qvar "${!qvar}"

        ok=y
        if [ $# -gt 0 ]; then
            ok=
            for i in "$@"; do
                [ "$i" == "${!qvar}" ] && ok="y"
            done
        fi

        [ -z "$ok" ] || break
        echo "Needs to be one of: $@"
    done

    # save answer
    [ -f /tmp/installer-answers ] && echo "$qvar='$answer'" >> /tmp/installer-answers
}

err() {
    echo $1
    exit 1
}
