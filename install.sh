#!/bin/bash
# Set up a Mac from this repo. Safe to re-run.
#
#   ./install.sh       full setup
#   ./install.sh -n    dry run: show what would change, change nothing
#
# Every file under home/ is symlinked to the same path under $HOME
# (home/.config/tmux/tmux.conf -> ~/.config/tmux/tmux.conf). To add a config
# file, put it in home/ and re-run. Don't move the repo after installing.
set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
DRY=0

usage() { echo "usage: $0 [-n]"; exit 1; }
while getopts n opt; do
  case $opt in
    n) DRY=1 ;;
    *) usage ;;
  esac
done

step() { printf '\n\033[1;34m==> %s\033[0m\n' "$*"; }
run()  { if ((DRY)); then echo "  would run: $*"; else "$@"; fi; }

[[ "$(uname -s)" == "Darwin" ]] || { echo "macOS only"; exit 1; }
((DRY)) && echo "DRY RUN: nothing will be changed"

# --- 1. Homebrew + packages -------------------------------------------------
step "Homebrew packages"
if ! command -v brew >/dev/null 2>&1 && [[ ! -x /opt/homebrew/bin/brew ]]; then
  if ((DRY)); then
    echo "  would install Homebrew, then everything in Brewfile"
  else
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
  if ((DRY)); then
    brew bundle check --file="$DOTFILES/Brewfile" --verbose || true
  else
    brew bundle --file="$DOTFILES/Brewfile"
  fi
fi

# --- 2. Symlinks ----------------------------------------------------------------
step "Linking home/ into \$HOME"
while IFS= read -r -d '' src; do
  rel="${src#"$DOTFILES/home/"}"
  dst="$HOME/$rel"
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    continue
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    if ((DRY)); then
      echo "  would back up $dst"
    else
      mkdir -p "$(dirname "$BACKUP/$rel")"
      mv "$dst" "$BACKUP/$rel"
      echo "  backed up $dst -> $BACKUP/$rel"
    fi
  fi
  if ((DRY)); then
    echo "  would link $dst"
  else
    mkdir -p "$(dirname "$dst")"
    ln -s "$src" "$dst"
    echo "  linked $dst"
  fi
done < <(find "$DOTFILES/home" \( -type f -o -type l \) -print0 | sort -z)
run chmod 700 "$HOME/.ssh"
run mkdir -p "$HOME/.kube/configs"

# --- 2b. Old layout clean-up ---------------------------------------------------
# Symlinks left by an earlier dotfiles layout that would shadow the files above
# (tmux reads ~/.tmux.conf before ~/.config/tmux/tmux.conf). Only symlinks that
# point outside this repo, or at nothing, are moved to the backup folder; real
# files are left alone.
step "Old layout clean-up"
K9S_OLD="$HOME/Library/Application Support/k9s"
for old in "$HOME/.tmux.conf" "$HOME/.zprofile" "$HOME/bin/ghost" \
           "$HOME/bin/completions/_ghost" "$K9S_OLD/aliases.yaml" "$K9S_OLD/skins"; do
  [[ -L "$old" ]] || continue
  # Keep links into this repo, unless they dangle (repo moved or file removed)
  if [[ -e "$old" ]]; then
    case "$(readlink "$old")" in "$DOTFILES"/*) continue ;; esac
  fi
  rel="${old#"$HOME/"}"
  if ((DRY)); then
    echo "  would move old link $old to $BACKUP/$rel"
  else
    mkdir -p "$(dirname "$BACKUP/$rel")"
    mv "$old" "$BACKUP/$rel"
    echo "  moved old link $old -> $BACKUP/$rel"
  fi
done
# k9s now reads ~/.config/k9s (XDG_CONFIG_HOME); carry over its own state once.
for f in config.yaml clusters; do
  if [[ -e "$K9S_OLD/$f" && ! -e "$HOME/.config/k9s/$f" ]]; then
    run cp -R "$K9S_OLD/$f" "$HOME/.config/k9s/$f"
  fi
done

# --- 3. Git identity (local only, never committed) -----------------------------
step "Git identity"
LOCAL_GIT="$HOME/.config/git/config.local"
if git config --file "$LOCAL_GIT" user.email >/dev/null 2>&1; then
  echo "  already set in $LOCAL_GIT"
elif ((DRY)); then
  echo "  would ask for name, email and signing key, and write $LOCAL_GIT"
else
  read -rp "  Full name: " name
  read -rp "  Git email for this machine: " email
  read -rp "  SSH public key for commit signing (from 1Password; blank to skip): " key
  git config --file "$LOCAL_GIT" user.name "$name"
  git config --file "$LOCAL_GIT" user.email "$email"
  if [[ -n "$key" ]]; then
    git config --file "$LOCAL_GIT" user.signingkey "$key"
    git config --file "$LOCAL_GIT" gpg.format ssh
    git config --file "$LOCAL_GIT" gpg.ssh.program "/Applications/1Password.app/Contents/MacOS/op-ssh-sign"
    git config --file "$LOCAL_GIT" gpg.ssh.allowedSignersFile "$HOME/.config/git/allowed_signers"
    git config --file "$LOCAL_GIT" commit.gpgsign true
    git config --file "$LOCAL_GIT" tag.gpgsign true
    echo "$email $key" > "$HOME/.config/git/allowed_signers"
  fi
  echo "  wrote $LOCAL_GIT"
fi

# --- 4. Toolchains, macOS defaults, repo hook ---------------------------------
step "mise toolchains"
if command -v mise >/dev/null 2>&1; then
  run mise install --yes
else
  echo "  mise not installed yet (installed by Brewfile)"
fi

step "tmux plugins (tpm)"
TPM="$HOME/.tmux/plugins/tpm"
if [[ -d "$TPM" ]]; then
  echo "  tpm already installed"
else
  run git clone --depth 1 https://github.com/tmux-plugins/tpm "$TPM"
fi
# Installs the plugins listed in tmux.conf (same as prefix + I inside tmux)
run "$TPM/bin/install_plugins"

step "macOS defaults"
run "$DOTFILES/macos-defaults.sh"

step "gitleaks pre-commit hook for this repo"
run git -C "$DOTFILES" config core.hooksPath .githooks

((DRY)) && { step "Dry run complete. Run without -n to apply."; exit 0; }

step "Done. Next:"
cat <<'EOF'
  1. Open Ghostty (or run: exec zsh)
  2. AWS profiles from your SSO access:
       granted sso generate --sso-region <region> https://<org>.awsapps.com/start >> ~/.aws/config
  3. For Backstage: corepack enable   (provides yarn)
  4. Optional: op plugin init gh
EOF
