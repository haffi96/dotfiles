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

local_backup_root="${HOME}/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"
mkdir -p "${local_backup_root}"

xdg_aerospace_conf="${HOME}/.config/aerospace/aerospace.toml"
source_aerospace_conf="${REPO_ROOT}/home/.config/aerospace/aerospace.toml"
legacy_aerospace_conf="${HOME}/.aerospace.toml"

if [[ -f "${source_aerospace_conf}" ]]; then
  mkdir -p "$(dirname "${xdg_aerospace_conf}")"
  backup_conflict "${xdg_aerospace_conf}" "${local_backup_root}" "${source_aerospace_conf}"
  ln -sfn "${source_aerospace_conf}" "${xdg_aerospace_conf}"
  log "Linked AeroSpace config: ${xdg_aerospace_conf} -> ${source_aerospace_conf}"
fi

backup_conflict "${legacy_aerospace_conf}" "${local_backup_root}" "${xdg_aerospace_conf}"
ln -sfn "${xdg_aerospace_conf}" "${legacy_aerospace_conf}"
log "Linked compatibility AeroSpace config: ${legacy_aerospace_conf} -> ${xdg_aerospace_conf}"
