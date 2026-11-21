# Prompt last; syntax-highlighting must be the very last plugin sourced.
command -v starship >/dev/null && eval "$(starship init zsh)"

if [[ -n ${HOMEBREW_PREFIX:-} ]]; then
  [[ -r $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
    source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
