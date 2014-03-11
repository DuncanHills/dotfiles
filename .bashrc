# prevent duplicate paths in OS X
if [[ -x /usr/libexec/path_helper ]]; then
    eval `/usr/libexec/path_helper -s`
fi

# OS X-specific
if [[ $(uname -s) == 'Darwin' ]]; then
    alias ls='ls -G'
fi

# Linux-specific
if [[ $(uname -s) == 'Linux' ]]; then
    : # pass
fi

# terminal prompt
if [[ -f "$HOME/.bash_ps1" ]]; then
    source "$HOME/.bash_ps1"
else
    export PS1="\u@\h: \w$ "
fi

# aliases
alias ll='ls -lh'
alias la='ls -lha'
alias cd='pushd 1>/dev/null'

# enable color support for ls
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# reset prompt command in subshells
if [[ $SHLVL > 1 ]]; then
    unset PROMPT_COMMAND
fi

# unified bash history
shopt -s histappend

history(){
  __sync_history
  builtin history "$@"
}

__sync_history() {
  builtin history -a
  HISTFILESIZE=$HISTFILESIZE
  builtin history -c
  builtin history -r
}

if [[ $PROMPT_COMMAND =~ ^.*\;[[:space:]$'\n'$'\r']*$ ]]; then
    export PROMPT_COMMAND="${PROMPT_COMMAND%;*}"
fi
export PROMPT_COMMAND="$([[ $PROMPT_COMMAND ]] && echo "${PROMPT_COMMAND}; ")__sync_history"

# homebrew installation prefix if present
prefix=$(brew --prefix 2>/dev/null || true) # won't break -e
    
# bash completion
bash_completion="${prefix}/etc/bash_completion"
if [[ -f $bash_completion ]]; then
    source "$bash_completion"
fi

# z
z="${prefix}/etc/profile.d/z.sh"
if [[ -f $z ]]; then
    source "$z"
fi

# virtualenvwrapper
export WORKON_HOME=~/.virtualenvs
export PROJECT_HOME=~/devel

# pyenv
if which pyenv > /dev/null; then
    eval "$(pyenv init -)"
    pyenvroot=$(pyenv root)
    if [[ -d ${pyenvroot}/plugins/pyenv-autoenv ]]; then
        source ${pyenvroot}/plugins/pyenv-autoenv/bin/pyenv-autoenv
    fi
    if [[ -d ${pyenvroot}/plugins/pyenv-virtualenvwrapper ]]; then
        pyenv virtualenvwrapper_lazy
    fi
fi
