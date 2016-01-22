#!/bin/bash
if which pyenv &>/dev/null; then
    export PYTHON_REALPATH="$(pyenv shell system && pyenv which python)"
else
    export PYTHON_REALPATH="$(which python)"
fi

"$PYTHON_REALPATH" "$(which powerline-config)" "$@"
