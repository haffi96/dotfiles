#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck disable=SC1091
source "${REPO_ROOT}/custom/lib/common.sh"

if [[ -d "${HOME}/.oh-my-zsh" ]]; then
  log "oh-my-zsh already installed."
  exit 0
fi

log "Installing oh-my-zsh."
RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c \
  "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
