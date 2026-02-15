#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck disable=SC1091
source "${REPO_ROOT}/custom/lib/common.sh"

log "Ensuring tmux is installed."
ensure_package tmux

if [[ ! -d "${HOME}/.local/bin" ]]; then
  mkdir -p "${HOME}/.local/bin"
fi
