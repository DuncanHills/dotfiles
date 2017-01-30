# prevent duplicate paths in OS X
if [[ -x /usr/libexec/path_helper ]]; then
    eval `/usr/libexec/path_helper -s`
fi

# any private directives go here
[[ -r ~/.bash_privates ]] && source ~/.bash_privates

# site-specific config goes here
[[ -r ~/.bash_site ]] && source ~/.bash_site

#export PATH="$PATH:/usr/local/opt/ruby/bin"
export PATH="$PATH:~/bin"

# reset prompt command in subshells
if [[ $SHLVL > 1 ]]; then
    unset PROMPT_COMMAND
fi

# OS X-specific
if [[ $(uname -s) == 'Darwin' ]]; then
    alias ls='ls -G'
    function showhiddenfiles() {
        defaults write com.apple.finder AppleShowAllFiles YES
        killall Finder /System/Library/CoreServices/Finder.app
    }
    function hidehiddenfiles() {
        defaults write com.apple.finder AppleShowAllFiles NO
        killall Finder /System/Library/CoreServices/Finder.app
    }
    if which brew &>/dev/null && which powerline-config &>/dev/null; then
        export POWERLINE_CONFIG_COMMAND=~/bin/powerline-config.sh
        export POWERLINE_COMMAND=~/bin/powerline.sh
    fi
fi

# Linux-specific
if [[ $(uname -s) == 'Linux' ]]; then
    : # pass
fi

export PYTHON_REALPATH="$(pyenv shell system &>/dev/null && pyenv which python || which python)"
export PYTHON_MODULEPATH="$("$PYTHON_REALPATH" -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")"

# powerline
export powerline="${PYTHON_MODULEPATH}/powerline"
export powerline_bash="${powerline}/bindings/bash/powerline.sh"
export powerline_tmux="${powerline}/bindings/tmux/powerline.conf"
export powerline_vim="${powerline}/bindings/vim"

# terminal prompt
if [[ -r $powerline_bash ]]; then
    ~/bin/powerline-daemon.sh
    source "$powerline_bash"
elif [[ -x $powerline_shell ]]; then
    function _update_ps1() {
       export PS1="$("$powerline_shell" --cwd-max-depth 4 --colorize-hostname --mode flat $? 2> /dev/null)"
    }
    export PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
elif [[ -f "$HOME/.bash_ps1" ]]; then
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

# bash options
shopt -s checkwinsize
shopt -s cmdhist
shopt -s extglob

# unified bash history
set +o histexpand
shopt -s histappend
HISTSIZE=99999
HISTFILESIZE=99999

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

export PROMPT_COMMAND=$(echo "$PROMPT_COMMAND" | sed -e 's/[;[[:blank:]]]*$//')
#export PROMPT_COMMAND="$([[ $PROMPT_COMMAND ]] && echo "${PROMPT_COMMAND}; ")__sync_history"
export PROMPT_COMMAND="$PROMPT_COMMAND"$'\n__sync_history'

# install cronjobs
(crontab -l | sed -e '/^# begin dotfile jobs$/,/^# end dotfile jobs$/d'; cat $HOME/.cron) | crontab -

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

# pyenv
if which pyenv &> /dev/null; then
    eval "$(pyenv init -)"
    if which pyenv-virtualenv-init &> /dev/null; then
        eval "$(pyenv virtualenv-init -)"
    fi
fi

# rbenv
if which rbenv > /dev/null; then 
    export RBENV_ROOT="$HOME/.rbenv"
    eval "$(rbenv init -)"
fi
