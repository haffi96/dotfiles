#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
# shellcheck disable=SC1091
source "${REPO_ROOT}/custom/lib/common.sh"

TARGET_DIR="${HOME}/.tmux"
TMUX_CONF_LINK="${HOME}/.tmux.conf"
TMUX_CONF_SOURCE="${TARGET_DIR}/.tmux.conf"
TMUX_CONF_LOCAL="${HOME}/.tmux.conf.local"
TMUX_CONF_LOCAL_TEMPLATE="${TARGET_DIR}/.tmux.conf.local"
MANAGED_BLOCK_START="# >>> dotfiles managed tmux binds >>>"
MANAGED_BLOCK_END="# <<< dotfiles managed tmux binds <<<"
backup_root="${HOME}/.dotfiles-backups/$(date +%Y%m%d-%H%M%S)"

mkdir -p "${backup_root}"

install_or_update_oh_my_tmux() {
  if [[ -d "${TARGET_DIR}/.git" ]]; then
    if ! git -C "${TARGET_DIR}" diff --quiet || ! git -C "${TARGET_DIR}" diff --cached --quiet; then
      warn "Skipping oh-my-tmux update: local changes detected in ${TARGET_DIR}."
      warn "To update manually, clean/stash changes and run: git -C ${TARGET_DIR} pull --ff-only"
      return 0
    fi

    log "Updating oh-my-tmux."
    if ! git -C "${TARGET_DIR}" pull --ff-only; then
      warn "oh-my-tmux update failed; continuing installer."
    fi
    return 0
  fi

  log "Installing oh-my-tmux."
  git clone --depth 1 https://github.com/gpakosz/.tmux.git "${TARGET_DIR}"
}

ensure_tmux_conf_symlink() {
  backup_conflict "${TMUX_CONF_LINK}" "${backup_root}" "${TMUX_CONF_SOURCE}"
  ln -sfn "${TMUX_CONF_SOURCE}" "${TMUX_CONF_LINK}"
}

ensure_tmux_conf_local_exists() {
  if [[ -f "${TMUX_CONF_LOCAL}" ]]; then
    return 0
  fi

  if [[ -f "${TMUX_CONF_LOCAL_TEMPLATE}" ]]; then
    cp "${TMUX_CONF_LOCAL_TEMPLATE}" "${TMUX_CONF_LOCAL}"
  else
    : > "${TMUX_CONF_LOCAL}"
  fi
}

upsert_managed_tmux_block() {
  local tmp_file
  tmp_file="$(mktemp)"

  awk -v start="${MANAGED_BLOCK_START}" -v end="${MANAGED_BLOCK_END}" '
    $0 == start { skip = 1; next }
    $0 == end { skip = 0; next }
    skip != 1 { print }
  ' "${TMUX_CONF_LOCAL}" > "${tmp_file}"

  {
    cat "${tmp_file}"
    printf '\n%s\n' "${MANAGED_BLOCK_START}"
    printf '%s\n' "# These scripts are stowed to ~/.local/bin."
    printf '%s\n' "bind -r l run-shell ~/.local/bin/tmux-pane-menu.sh"
    printf '%s\n' "bind C-s run-shell ~/.local/bin/tmux-session-menu.sh"
    printf '%s\n' "${MANAGED_BLOCK_END}"
  } > "${TMUX_CONF_LOCAL}"

  rm -f "${tmp_file}"
}

install_or_update_oh_my_tmux
ensure_tmux_conf_symlink
ensure_tmux_conf_local_exists
upsert_managed_tmux_block
