projects="plan-service license-service configuration-service oboroten"
selected_project=$(echo $projects | tr ' ' '\n' | fzf)

if [ ! -z "$selected_project" ]; then
    wname=$(echo $selected_project | cut -d'-' -f1)
    tmux new-window -c ~/work/$selected_project -n $wname "nvim ."
fi
