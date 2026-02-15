#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck disable=SC1091
source "${REPO_ROOT}/custom/lib/common.sh"

ensure_plugin() {
  local name="$1"
  local url="$2"
  local target="${HOME}/.oh-my-zsh/custom/plugins/${name}"
  if [[ -d "$target/.git" ]]; then
    log "Updating ${name}."
    git -C "$target" pull --ff-only
  else
    log "Installing ${name}."
    git clone "$url" "$target"
  fi
}

ensure_plugin "zsh-autosuggestions" "https://github.com/zsh-users/zsh-autosuggestions"
ensure_plugin "zsh-syntax-highlighting" "https://github.com/zsh-users/zsh-syntax-highlighting"
