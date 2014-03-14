#!/bin/bash

session_name="local-$(date +%s)"
tmux new-session -s $session_name \; source-file $HOME/.tmux-local.conf
