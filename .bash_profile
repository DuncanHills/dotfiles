if [ -f ~/.bashrc ]; then
    source ~/.bashrc
fi

# terminal prompt
export PS1="\u@\h: \w$ "

# aliases
alias ls='ls -G'
alias ll='ls -lh'
alias la='ls -lha'
alias cd='pushd 1>/dev/null'

# unified bash history
shopt -s histappend
PROMPT_COMMAND="${PROMPT_COMMAND%;*}; history -a; history -n"

# bash completion
for script in $(find /usr/local/etc/bash_completion.d -mindepth 1 -maxdepth 1 -type f 2>/dev/null)
do
    source $script
done

# virtualenvwrapper
export WORKON_HOME=~/Devel/envs
export PROJECT_HOME=~/Devel/git

if [ -f /usr/local/bin/virtualenvwrapper.sh ]; then
    source /usr/local/bin/virtualenvwrapper.sh
fi

# pyenv
if which pyenv > /dev/null; then
    eval "$(pyenv init -)"
    #source $(pyenv root)/plugins/pyenv-autoenv/bin/pyenv-autoenv
    pyenv virtualenvwrapper
fi
