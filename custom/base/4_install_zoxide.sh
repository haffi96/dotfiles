#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck disable=SC1091
source "${REPO_ROOT}/custom/lib/common.sh"

if command_exists zoxide; then
  log "zoxide already installed."
  exit 0
fi

log "Installing zoxide."
if [[ "${PLATFORM_OS:-}" == "" ]]; then
  detect_platform
fi

case "${PLATFORM_OS}" in
  macos)
    ensure_package zoxide
    ;;
  linux)
    if [[ "${PLATFORM_DISTRO}" == "ubuntu" || "${PLATFORM_DISTRO}" == "debian" ]]; then
      curl -fsSL https://raw.githubusercontent.com/ajeetdsouza/zoxide/main/install.sh | bash
    else
      warn "Skipping zoxide install on unsupported distro: ${PLATFORM_DISTRO}"
    fi
    ;;
esac
