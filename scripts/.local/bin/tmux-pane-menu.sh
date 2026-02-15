#!/usr/bin/env bash

set -euo pipefail

tmux list-panes -aF "#{pane_index} | #{pane_title}" \
  | awk 'BEGIN {ORS=" "} {print $2 $3, NR, "\"select-pane -t", $1 "; resize-pane -Z\""}' \
  | xargs tmux display-menu -T "Switch-panes"
