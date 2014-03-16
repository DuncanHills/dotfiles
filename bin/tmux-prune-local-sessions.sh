#!/bin/bash
# script to kill detached local sessions (from closed tabs, etc)

#TODO: replace with bash env-vars setup script when broken out from .bashrc
if [[ $(uname -s) = "Darwin" ]]; then 
    if [[ -x /usr/libexec/path_helper ]]; then
        eval $(/usr/libexec/path_helper -s)
    fi
    export TMPDIR="$(getconf DARWIN_USER_TEMP_DIR)"
fi

if which tmux &> /dev/null; then
    for orphaned_local_session in $(tmux start \; ls | grep local | \
        grep -v attached | cut -d : -f 1)
    do
        tmux kill-session -t $orphaned_local_session
    done
fi
