#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck disable=SC1091
source "${REPO_ROOT}/custom/lib/common.sh"

main() {
  detect_platform

  if ! command_exists stow; then
    die "GNU stow is required but not installed."
  fi

  local backup_root
  backup_root="${HOME}/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
  mkdir -p "${backup_root}"

  local packages=(git zsh tmux scripts fonts)
  if [[ "${PLATFORM_OS}" == "macos" ]]; then
    packages+=(aerospace)
  fi

  local pkg
  for pkg in "${packages[@]}"; do
    log "Stowing package: ${pkg}"
    stow_package "${REPO_ROOT}" "${pkg}" "${backup_root}"
  done

  log "Stow apply complete."
}

main "$@"
