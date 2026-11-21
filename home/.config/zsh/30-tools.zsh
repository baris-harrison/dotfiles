# Tool activation. Each block is guarded so missing tools never break the shell.

# mise: per-directory toolchains (.mise.toml / .tool-versions)
command -v mise >/dev/null && eval "$(mise activate zsh)"

# fzf: Ctrl-R history, Ctrl-T files, Alt-C dirs
if command -v fzf >/dev/null; then
  source <(fzf --zsh)
  command -v fd >/dev/null && export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
fi

command -v zoxide >/dev/null && eval "$(zoxide init zsh --cmd cd)"

# 1Password shell plugins (gh, etc.): created by `op plugin init <tool>`
[[ -r "$XDG_CONFIG_HOME/op/plugins.sh" ]] && source "$XDG_CONFIG_HOME/op/plugins.sh"

# granted: `assume` must be sourced to export creds into *this* shell
command -v assume >/dev/null && alias assume="source assume"

if [[ -n ${HOMEBREW_PREFIX:-} ]]; then
  [[ -r $HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]] &&
    source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi
