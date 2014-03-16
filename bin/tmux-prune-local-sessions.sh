#!/bin/bash

#TODO: replace with bash env-vars setup script when broken out from .bashrc
if [ "$(uname -s)" = "Darwin" ]; then 
    if [[ -x /usr/libexec/path_helper ]]; then
        eval `/usr/libexec/path_helper -s`
    fi
    export TMPDIR="$(getconf DARWIN_USER_TEMP_DIR)"
fi

if which tmux &> /dev/null; then
    tmux start \; ls | grep local | grep -v attached | cut -d : -f 1 | xargs -L 1 tmux kill-session -t
fi
