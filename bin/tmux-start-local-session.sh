#!/bin/bash

session_name="local-$(date +%s)"
tmux new-session -d -s $session_name
tmux server-info | grep '^socket path' | cut -d ' ' -f 3- > "$HOME/.tmux-socket"
exec tmux attach-session -t $session_name \; source-file $HOME/.tmux-2panes.conf 
