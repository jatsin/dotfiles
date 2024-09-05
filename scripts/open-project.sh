#!/bin/zsh
selected_project=$(ls ~/work | fzf)

if [ ! -z "$selected_project" ]; then
    wname=$(echo $selected_project | cut -d'-' -f1)
    if [ -n "$TMUX" ]; then
        tmux new-window -c ~/work/$selected_project -n $wname "nvim ."
    else
        if ! tmux has-session -t $wname 2>/dev/null; then
            tmux new-session -s $wname -c ~/work/$selected_project -n $wname "nvim ."
        else
            tmux attach-session -t $wname
        fi
    fi
fi
