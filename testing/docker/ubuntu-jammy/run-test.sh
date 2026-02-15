#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../../.." && pwd)"
IMAGE_NAME="haffi-dotfiles-jammy-test"

docker build -t "${IMAGE_NAME}" -f "${SCRIPT_DIR}/Dockerfile" "${REPO_ROOT}"

docker run \
  -t \
  -v "${REPO_ROOT}:/work/dotfiles" \
  -w /work/dotfiles \
  "${IMAGE_NAME}" \
  bash -lc '
    set -euo pipefail
    bash ./install
    test -L "${HOME}/.zshrc"
    test -L "${HOME}/.tmux.conf"
    test -x "${HOME}/.local/bin/tms"
    zsh --version
    stow --version
    tmux -V
    echo "Jammy install test passed."
  '
