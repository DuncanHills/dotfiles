path_contains() {
  case ":$PATH:" in
    *":$1:"*) true;;
    *) false;;
  esac
}

append_to_path() {
  if ! path_contains $1; then echo "$PATH:$1"; else echo "$PATH"; fi
}

prepend_to_path() {
  if ! path_contains $1; then echo "$1:$PATH"; else echo "$PATH"; fi
}

# some things behave differently in project folders, etc.
start_dir="$(PWD)"
cd "$HOME"

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
  unset PATH
  source /etc/profile
fi

# Linux-specific
if [[ $(uname -s) == 'Linux' ]]; then
  : # pass
fi

# any private directives go here
[[ -r ~/.bash_privates ]] && source ~/.bash_privates

# site-specific config goes here
[[ -r ~/.bash_site ]] && source ~/.bash_site

PATH="$(append_to_path ~/bin)"

# aliases
alias c=clear
alias ll='ls -lh'
alias la='ls -lha'
alias cd='pushd 1>/dev/null'

# environment variables
export EDITOR=vim
export GOPATH=~/go

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

# sync history before running history
history(){
  __sync_history
  builtin history "$@"
}

# actual sync function
__sync_history() {
  builtin history -a
  HISTFILESIZE=$HISTFILESIZE
  builtin history -c
  builtin history -r
}

# install cronjobs
(crontab -l | sed -e '/^# begin dotfile jobs$/,/^# end dotfile jobs$/d'; cat $HOME/.cron) | crontab -

# homebrew installation prefix if present
prefix=$(brew --prefix 2>/dev/null || true)
    
# bash completion
bash_completion="${prefix}/etc/bash_completion"
if [[ -f $bash_completion ]]; then
    source "$bash_completion"
fi

# fzf
if which fzf &> /dev/null; then
    source "${prefix}/opt/fzf/shell/completion.bash"
    source "${prefix}/opt/fzf/shell/key-bindings.bash"
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

# js and nodenv
PATH="$(prepend_to_path "~/.npm-global/bin")"
if which nodenv &> /dev/null; then
    eval "$(nodenv init -)"
fi

# rbenv
if which rbenv > /dev/null; then 
    RBENV_ROOT="$HOME/.rbenv"
    eval "$(rbenv init -)"
fi

# rustup
cargo_bin=~/.cargo/bin
if [[ -d $cargo_bin ]]; then
    PATH="$(prepend_to_path "$cargo_bin")"
fi

# go and goenv
PATH="$(prepend_to_path "$GOPATH/bin")"
if which goenv > /dev/null; then
    eval "$(goenv init -)"
fi

# these help make the default python and site_packages available
# regardless of active pyenv or virtualenv environments
export PYTHON_REALPATH="$(pyenv which python 2> /dev/null || which python)"
export PYTHON_MODULEPATH="$("$PYTHON_REALPATH" -c "from distutils.sysconfig import get_python_lib; print(get_python_lib())")"

# powerline
export powerline="$(pyenv which powerline 2> /dev/null || which powerline)"
export powerline_bindir="$(dirname "$powerline")"
export powerline_root="${PYTHON_MODULEPATH}/powerline"
export powerline_bash="${powerline_root}/bindings/bash/powerline.sh"
export powerline_tmux="${powerline_root}/bindings/tmux/powerline.conf"
export powerline_vim="${powerline_root}/bindings/vim"

# powerline_status and POWERLINE_COMMAND let powerline work when inside
# of another virtualenv, while being in their own virtualenv
powerline_status() {
  PATH="$(prepend_to_path "$powerline_bindir")" "$powerline" $@
}
export POWERLINE_COMMAND=powerline_status

# powerline-go
function powerline_go_status() {
    PS1="$(powerline-go -cwd-max-depth 3 -mode flat -newline -numeric-exit-codes -error $?)"
}

# terminal prompt
if which powerline-go > /dev/null; then
  PROMPT_COMMAND=$'powerline_go_status\n'"$PROMPT_COMMAND"
elif [[ -r $powerline_bash ]]; then
    source "$powerline_bash"
elif [[ -f "$HOME/.bash_ps1" ]]; then
    source "$HOME/.bash_ps1"
else
    PS1="\u@\h: \w$ "
fi

PROMPT_COMMAND=$(echo "$PROMPT_COMMAND" | sed -e 's/;[;[:blank:]]*/\'$'\n/g')
PROMPT_COMMAND="$PROMPT_COMMAND"$'\n__sync_history'

# back to where we started, TIME IS A FLAT CIRCLE
cd "$start_dir"
unset start_dir
