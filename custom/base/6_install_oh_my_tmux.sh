#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck disable=SC1091
source "${REPO_ROOT}/custom/lib/common.sh"

TARGET_DIR="${HOME}/.tmux"
if [[ -d "${TARGET_DIR}/.git" ]]; then
  log "Updating oh-my-tmux."
  git -C "${TARGET_DIR}" pull --ff-only
  exit 0
fi

log "Installing oh-my-tmux."
git clone --depth 1 https://github.com/gpakosz/.tmux.git "${TARGET_DIR}"
