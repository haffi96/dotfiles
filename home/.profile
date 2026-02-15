# Shared profile loaded by POSIX-compatible login shells.
DOTFILES_REPO="${DOTFILES_INSTALL_DIR:-$HOME/.local/share/haffi-dotfiles}"

# Resolve repo root from stowed ~/.profile symlink when possible.
if [ -L "$HOME/.profile" ]; then
  PROFILE_LINK_TARGET="$(readlink "$HOME/.profile" 2>/dev/null || true)"
  if [ -n "$PROFILE_LINK_TARGET" ]; then
    case "$PROFILE_LINK_TARGET" in
      /*) PROFILE_ABS="$PROFILE_LINK_TARGET" ;;
      *) PROFILE_ABS="$(cd "$(dirname "$HOME/.profile")" && cd "$(dirname "$PROFILE_LINK_TARGET")" 2>/dev/null && pwd)/$(basename "$PROFILE_LINK_TARGET")" ;;
    esac
    if [ -n "$PROFILE_ABS" ]; then
      DOTFILES_REPO="$(cd "$(dirname "$PROFILE_ABS")/.." && pwd)"
    fi
  fi
fi

if [ -f "$DOTFILES_REPO/custom/environment" ]; then
  . "$DOTFILES_REPO/custom/environment"
fi

if [ -f "$DOTFILES_REPO/custom/history" ]; then
  . "$DOTFILES_REPO/custom/history"
fi

if [ -f "$HOME/.zshrc" ]; then
  . "$HOME/.zshrc"
fi
