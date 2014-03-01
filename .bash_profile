if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# terminal prompt
export PS1="\u@\h: \w$ "

# OSX-specific
if [[ $(uname -s) == 'Darwin' ]]
then
    alias ls='ls -G'
fi

# Linux-specific
if [[ $(uname -s) == 'Linux' ]]
then
    : # pass
fi

# aliases
alias ll='ls -lh'
alias la='ls -lha'
alias cd='pushd 1>/dev/null'

# unified bash history
shopt -s histappend
if [[ $PROMPT_COMMAND =~ ^.*\;[[:space:]$'\n'$'\r']*$ ]]; then
    export PROMPT_COMMAND="${PROMPT_COMMAND%;*}"
fi
export PROMPT_COMMAND="$([[ $PROMPT_COMMAND ]] && echo "${PROMPT_COMMAND}; ")history -a; history -n"


if [ -f "$(brew --prefix 2>/dev/null || true)/etc/bash_completion" ]; then
    source "$(brew --prefix 2>/dev/null || true)/etc/bash_completion"
fi

# virtualenvwrapper
export WORKON_HOME=~/devel/envs
export PROJECT_HOME=~/devel/git

# pyenv
if which pyenv > /dev/null; then
    eval "$(pyenv init -)"
    pyenvroot=$(pyenv root)
    if [[ -d ${pyenvroot}/plugins/pyenv-autoenv ]]; then
        source $(pyenv root)/plugins/pyenv-autoenv/bin/pyenv-autoenv
    fi
    if [[ -d ${pyenvroot}/plugins/virtualenvwrapper ]]; then
        pyenv virtualenvwrapper_lazy
    fi
fi
