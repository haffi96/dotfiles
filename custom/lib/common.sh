#!/usr/bin/env bash

set -euo pipefail

log() {
  printf '[dotfiles] %s\n' "$*"
}

warn() {
  printf '[dotfiles][warn] %s\n' "$*" >&2
}

die() {
  printf '[dotfiles][error] %s\n' "$*" >&2
  exit 1
}

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

run_sudo() {
  if [[ "${EUID}" -eq 0 ]]; then
    "$@"
  else
    sudo "$@"
  fi
}

ensure_homebrew() {
  if command_exists brew; then
    return
  fi
  warn "Homebrew not found. Installing Homebrew."
  NONINTERACTIVE=1 /bin/bash -c \
    "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

ensure_apt_package() {
  local package_name="$1"
  if dpkg -s "$package_name" >/dev/null 2>&1; then
    return
  fi
  if [[ "${APT_UPDATED:-0}" != "1" ]]; then
    run_sudo apt-get update -y
    APT_UPDATED=1
    export APT_UPDATED
  fi
  run_sudo apt-get install -y "$package_name"
}

ensure_package() {
  local package_name="$1"
  detect_platform
  case "${PLATFORM_OS}" in
    macos)
      ensure_homebrew
      brew list "$package_name" >/dev/null 2>&1 || brew install "$package_name"
      ;;
    linux)
      if [[ "${PLATFORM_DISTRO}" == "ubuntu" || "${PLATFORM_DISTRO}" == "debian" ]]; then
        ensure_apt_package "$package_name"
      else
        warn "Package install for distro '${PLATFORM_DISTRO}' not yet implemented."
      fi
      ;;
  esac
}

detect_platform() {
  local kernel
  kernel="$(uname -s)"
  case "$kernel" in
    Darwin)
      PLATFORM_OS="macos"
      PLATFORM_DISTRO="darwin"
      ;;
    Linux)
      PLATFORM_OS="linux"
      PLATFORM_DISTRO="linux"
      if [[ -f /etc/os-release ]]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        PLATFORM_DISTRO="${ID:-linux}"
      fi
      ;;
    *)
      die "Unsupported OS: $kernel"
      ;;
  esac
  export PLATFORM_OS PLATFORM_DISTRO
}

ensure_default_shell_zsh() {
  SHELL_CHANGE_SKIPPED=0
  SHELL_CHANGE_MANUAL_CMD=""
  export SHELL_CHANGE_SKIPPED SHELL_CHANGE_MANUAL_CMD

  if ! command_exists zsh; then
    warn "zsh is not installed; skipping login shell change."
    SHELL_CHANGE_SKIPPED=1
    export SHELL_CHANGE_SKIPPED
    return
  fi

  local zsh_path
  zsh_path="$(command -v zsh)"

  if [[ "${SHELL:-}" == "$zsh_path" ]]; then
    log "Login shell already set to zsh."
    return
  fi

  if ! command_exists chsh; then
    warn "chsh is unavailable; cannot set default shell automatically."
    SHELL_CHANGE_SKIPPED=1
    SHELL_CHANGE_MANUAL_CMD="chsh -s ${zsh_path} \"\$(id -un)\""
    export SHELL_CHANGE_SKIPPED SHELL_CHANGE_MANUAL_CMD
    return
  fi

  # Avoid blocking CI/container/non-interactive runs on chsh password prompt.
  if [[ ! -t 0 || -f "/.dockerenv" ]]; then
    warn "Non-interactive/container session detected; skipping automatic shell change."
    SHELL_CHANGE_SKIPPED=1
    SHELL_CHANGE_MANUAL_CMD="chsh -s ${zsh_path} \"\$(id -un)\""
    export SHELL_CHANGE_SKIPPED SHELL_CHANGE_MANUAL_CMD
    return
  fi

  if [[ -f /etc/shells ]] && ! grep -q "^${zsh_path}$" /etc/shells; then
    warn "zsh path not present in /etc/shells: ${zsh_path}"
    SHELL_CHANGE_SKIPPED=1
    export SHELL_CHANGE_SKIPPED
    return
  fi

  log "Changing login shell to ${zsh_path}."
  local login_user="${USER:-}"
  if [[ -z "$login_user" ]]; then
    login_user="$(id -un 2>/dev/null || true)"
  fi

  if [[ -z "$login_user" ]]; then
    warn "Unable to determine login user; skipping automatic shell change."
    SHELL_CHANGE_SKIPPED=1
    SHELL_CHANGE_MANUAL_CMD="chsh -s ${zsh_path} \"\$(id -un)\""
    export SHELL_CHANGE_SKIPPED SHELL_CHANGE_MANUAL_CMD
    return
  fi

  if ! chsh -s "$zsh_path" "$login_user"; then
    warn "Failed to change login shell automatically. Run manually: chsh -s ${zsh_path} ${login_user}"
    SHELL_CHANGE_SKIPPED=1
    SHELL_CHANGE_MANUAL_CMD="chsh -s ${zsh_path} ${login_user}"
    export SHELL_CHANGE_SKIPPED SHELL_CHANGE_MANUAL_CMD
  fi
}

backup_conflict() {
  local target="$1"
  local backup_root="$2"
  local expected_source="${3:-}"

  if [[ -L "$target" && -n "$expected_source" ]]; then
    local resolved_target=""
    if command_exists realpath; then
      resolved_target="$(realpath "$target" 2>/dev/null || true)"
    fi
    if [[ -z "$resolved_target" ]]; then
      local link_value
      link_value="$(readlink "$target" 2>/dev/null || true)"
      if [[ -n "$link_value" ]]; then
        if [[ "$link_value" = /* ]]; then
          resolved_target="$link_value"
        else
          resolved_target="$(cd "$(dirname "$target")" && cd "$(dirname "$link_value")" && pwd)/$(basename "$link_value")"
        fi
      fi
    fi

    if [[ "$resolved_target" == "$expected_source" ]]; then
      return
    fi
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    local rel
    rel="${target#${HOME}/}"
    mkdir -p "${backup_root}/$(dirname "$rel")"
    mv "$target" "${backup_root}/${rel}"
    log "Backed up existing ${target} -> ${backup_root}/${rel}"
  fi
}

stow_package() {
  local repo_root="$1"
  local package_name="$2"
  local backup_root="$3"
  local stow_ignore_regex="${4:-}"
  local package_path="${repo_root}/${package_name}"

  [[ -d "$package_path" ]] || return 0

  while IFS= read -r source_path; do
    local rel
    rel="${source_path#${package_path}/}"
    if [[ -n "$stow_ignore_regex" ]] && [[ "$rel" =~ $stow_ignore_regex ]]; then
      continue
    fi
    backup_conflict "${HOME}/${rel}" "$backup_root" "$source_path"
  done < <(find "$package_path" -mindepth 1 -type f)

  if [[ -n "$stow_ignore_regex" ]]; then
    stow -R -v --no-folding --ignore="$stow_ignore_regex" -t "${HOME}" -d "${repo_root}" "${package_name}"
  else
    stow -R -v --no-folding -t "${HOME}" -d "${repo_root}" "${package_name}"
  fi
}

link_tree_files() {
  local source_root="$1"
  local target_root="$2"
  local backup_root="$3"

  [[ -d "$source_root" ]] || return 0

  while IFS= read -r source_path; do
    local rel
    local target_path
    rel="${source_path#${source_root}/}"
    target_path="${target_root}/${rel}"
    mkdir -p "$(dirname "${target_path}")"
    backup_conflict "${target_path}" "${backup_root}" "${source_path}"
    ln -sfn "${source_path}" "${target_path}"
  done < <(find "$source_root" -mindepth 1 -type f)
}
