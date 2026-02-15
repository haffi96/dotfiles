#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck disable=SC1091
source "${REPO_ROOT}/custom/lib/common.sh"

detect_platform
if [[ "${PLATFORM_OS}" != "macos" ]]; then
  exit 0
fi

log "Running macOS package setup."
ensure_package git
ensure_package curl
ensure_package stow

if [[ -f "${REPO_ROOT}/.aerospace.toml" ]]; then
  local_backup_root="${HOME}/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
  mkdir -p "${local_backup_root}"
  backup_conflict "${HOME}/.aerospace.toml" "${local_backup_root}"
  ln -sfn "${REPO_ROOT}/.aerospace.toml" "${HOME}/.aerospace.toml"
  log "Linked AeroSpace config."
fi
