#!/bin/bash

################################################################################
# TMUX CONFIG
# tmux gui formatting
tmux set -g mouse on
tmux set -g pane-border-status top
tmux set -g pane-border-format "[#[fg=white]#{?pane_active,#[bold],} #P - #T #[fg=default,nobold]]"

# tmux helpers
# define path to tmux helpers
main_script_dir=$(dirname "$0")
tmux_scripts_path="../tmux-scripts"
abs_path=$(readlink -f "$main_script_dir/$tmux_scripts_path")
# Configure keybinds
## Don't exit tmux when 'tmux kill-ses ...' is run
# tmux set -g detach-on-destroy off

## display menu to switch and maximize panes
tmux bind -r C-l run-shell $abs_path/tmux-pane-menu.sh
################################################################################
