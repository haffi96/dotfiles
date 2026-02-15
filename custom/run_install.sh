#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

# shellcheck disable=SC1091
source "${REPO_ROOT}/custom/lib/common.sh"

run_ordered_base_scripts() {
  local script
  for script in "${REPO_ROOT}"/custom/base/[0-9]*_*.sh; do
    [[ -f "$script" ]] || continue
    log "Running $(basename "$script")"
    bash "$script"
  done
}

run_os_script() {
  case "${PLATFORM_OS}" in
    macos)
      bash "${REPO_ROOT}/custom/macos/install.sh"
      ;;
    linux)
      bash "${REPO_ROOT}/custom/linux/install.sh"
      ;;
  esac
}

main() {
  log "Starting dotfiles installer from ${REPO_ROOT}"
  detect_platform
  export REPO_ROOT
  run_ordered_base_scripts
  run_os_script
  bash "${REPO_ROOT}/custom/stow_apply.sh"
  ensure_default_shell_zsh
  if [[ "${SHELL_CHANGE_SKIPPED:-0}" == "1" ]]; then
    warn "Automatic shell switch to zsh was skipped."
    if [[ -n "${SHELL_CHANGE_MANUAL_CMD:-}" ]]; then
      warn "Run this after install to switch your login shell:"
      warn "  ${SHELL_CHANGE_MANUAL_CMD}"
    fi
  fi
  log "Installation complete. Restart your shell or run: exec zsh"
}

main "$@"
