# dotfiles bootstrap

Cross-machine bootstrap for macOS + Linux with a single shared `.zshrc`.

## Quick install

Run locally from a clone:

```bash
./install
```

Or bootstrap directly from GitHub:

```bash
curl -LsSf https://haffi.dev/dotfiles.sh | sh
```

or

```bash
curl -LsSf https://raw.githubusercontent.com/haffi96/dotfiles/master/install | sh
```

## What the installer does

- Detects platform (`macOS` or `Linux`).
- Runs ordered scripts in `custom/base/`.
- Runs OS-specific setup in `custom/macos/` or `custom/linux/`.
- Applies stow packages into `$HOME`.
- Attempts to set default shell to `zsh`.
- Base install ensures `zsh`, `fzf`, and `stow` are installed.

## Script order

The base installer always runs these scripts in order:

1. `custom/base/1_install_zsh.sh`
2. `custom/base/2_install_oh_my_zsh.sh`
3. `custom/base/3_install_zsh_enhancements.sh`
4. `custom/base/4_install_zoxide.sh`
5. `custom/base/5_install_tmux.sh`
6. `custom/base/6_install_oh_my_tmux.sh`

## Stow packages

- `home` -> `~/.zshrc`, `~/.tmux.conf`, `~/.profile`, and `~/.config/aerospace/aerospace.toml` (macOS)
- macOS compatibility: `~/.aerospace.toml` -> `~/.config/aerospace/aerospace.toml`
- `git` -> `~/.gitconfig`
- `scripts` -> `~/.local/bin/*`
- `fonts` -> `~/.fonts/*`

Conflicting existing files are backed up to:

```text
~/.dotfiles-backups/<timestamp>/
```

## Ubuntu Jammy test container

Use the clean-room Docker test flow:

```bash
bash testing/docker/ubuntu-jammy/run-test.sh
```

This builds `ubuntu:22.04`, creates a non-root user, runs the installer, and validates core tooling + symlinks.
