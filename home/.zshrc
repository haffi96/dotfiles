# Shared cross-platform zsh config managed by dotfiles.

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="bira"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting history kubectl)

if [[ -d "$ZSH" ]]; then
  source "$ZSH/oh-my-zsh.sh"
fi

alias vi=nvim
alias t=tms
alias tf=terraform

if command -v bat >/dev/null 2>&1; then
  alias cat=bat
fi

if command -v fzf >/dev/null 2>&1; then
  # fzf >= 0.48 supports native zsh integration.
  source <(fzf --zsh)
elif [[ -f "$HOME/.fzf.zsh" ]]; then
  # Fallback for git-based fzf installer layouts.
  source "$HOME/.fzf.zsh"
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

if [[ -d "$HOME/.local/bin" ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi

if [[ -d "$HOME/.cargo/bin" ]]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

if [[ -d "$HOME/.bun/bin" ]]; then
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

if [[ -d "/opt/homebrew/bin" ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi

if [[ -s "$HOME/.nvm/nvm.sh" ]]; then
  export NVM_DIR="$HOME/.nvm"
  # shellcheck disable=SC1091
  . "$NVM_DIR/nvm.sh"
  if [[ -s "$NVM_DIR/bash_completion" ]]; then
    # shellcheck disable=SC1091
    . "$NVM_DIR/bash_completion"
  fi
fi

# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/haffi.mazhar/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/haffi.mazhar/google-cloud-sdk/path.zsh.inc'; fi

# pnpm
export PNPM_HOME="/Users/haffi.mazhar/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# opencode
export PATH=/Users/haffi.mazhar/.opencode/bin:$PATH
export VERTEX_LOCATION=global
export GOOGLE_CLOUD_PROJECT="oxa-dev-ra-pl"

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"