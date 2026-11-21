# System-level tools. Versioned toolchains (kubectl, helm, terraform…)
# live in ~/.config/mise/config.toml instead so they can be pinned per repo.
# Applied by install.sh (safe to re-run: brew bundle --file Brewfile).

# --- Core shell -------------------------------------------------------------
brew "git"
brew "git-delta"            # better diffs
brew "mise"                 # toolchain version manager
brew "starship"             # prompt
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "fzf"
brew "tmux"                 # persistent sessions (ghost, lab)
brew "zoxide"               # smarter cd
brew "ripgrep"
brew "fd"
brew "bat"
brew "eza"
brew "jq"
brew "yq"
brew "coreutils"
brew "gnu-sed"
brew "watch"
brew "tldr"

# --- Cloud / AWS ------------------------------------------------------------
brew "awscli"
brew "granted"              # `assume` for AWS SSO, per-shell credentials
brew "session-manager-plugin"  # SSM: ssh-less access to EC2

# --- Kubernetes ---------------------------------------------------------------
brew "kubie"                # per-shell kube context/namespace isolation
brew "k9s"
brew "stern"                # multi-pod log tailing
brew "kubectx"

# --- Local platform lab (Backstage + kind + Argo CD) -------------------------
brew "colima"               # container runtime (free; Docker Desktop needs a paid licence at larger companies)
brew "docker"               # docker CLI, talks to colima
brew "kind"                 # Kubernetes in Docker
brew "argocd"               # Argo CD CLI

# --- Dev tooling -------------------------------------------------------
brew "gh"
brew "gitleaks"           # secret scanning (also guards this repo)
brew "shellcheck"
brew "shfmt"

# --- Apps -------------------------------------------------------------------
cask "ghostty"
cask "font-jetbrains-mono-nerd-font"
# 1Password is often pushed by MDM on work laptops; don't fight it.
cask "1password" unless File.directory?("/Applications/1Password.app")
cask "1password-cli"
