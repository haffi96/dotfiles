#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck disable=SC1091
source "${REPO_ROOT}/custom/lib/common.sh"

detect_platform
if [[ "${PLATFORM_OS}" != "linux" ]]; then
  exit 0
fi

if [[ "${PLATFORM_DISTRO}" != "ubuntu" && "${PLATFORM_DISTRO}" != "debian" ]]; then
  die "Unsupported Linux distro for auto-install: ${PLATFORM_DISTRO}. Debian/Ubuntu only for now."
fi

log "Running Debian/Ubuntu package setup."
run_sudo apt-get update -y
run_sudo apt-get install -y \
  ca-certificates \
  curl \
  fzf \
  git \
  stow \
  sudo \
  zsh \
  openssh-server
