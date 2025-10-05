#!/bin/zsh

wname="DBUI"
command="nvim -c 'DBUI'"
if [ -n "$TMUX" ]; then
  tmux new-window -c ~/work/ -n $wname $command
else
  if ! tmux has-session -t $wname 2>/dev/null; then
    tmux new-session -s $wname -c ~/work/$selected_project -n $wname $command
  else
    tmux attach-session -t $wname
  fi
fi
