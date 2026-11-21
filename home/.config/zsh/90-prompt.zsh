# Prompt last; syntax-highlighting must be the very last plugin sourced.

if command -v starship >/dev/null; then
  # Cached `starship init zsh`, regenerated when the binary is newer (reset: rm the file).
  # No right_format is configured, so RPROMPT is always empty: drop that call and the
  # PROMPT2 one (~5ms per prompt). Remove the RPROMPT edit if a right_format is added.
  _starship_init=${XDG_CACHE_HOME:-$HOME/.cache}/zsh/starship.zsh
  if [[ ! -s $_starship_init || ${commands[starship]} -nt $_starship_init ]]; then
    mkdir -p ${_starship_init:h}
    starship init zsh | sed -e "s/^RPROMPT=.*/RPROMPT=''/" -e '/^PROMPT2=/d' >| $_starship_init
  fi
  [[ $_starship_init.zwc -nt $_starship_init ]] || zcompile $_starship_init
  source $_starship_init
  unset _starship_init
  PROMPT2='%F{8}∙%f '   # starship's default continuation prompt, without the subprocess

  # Transient prompt: once a command is entered, its prompt collapses to the character.
  zle-line-init() {
    emulate -L zsh
    [[ $CONTEXT == start ]] || return 0
    while true; do
      zle .recursive-edit
      local -i ret=$?
      [[ $ret == 0 && $KEYS == $'\4' ]] || break
      [[ -o ignore_eof ]] || exit 0
    done
    local saved_prompt=$PROMPT saved_rprompt=$RPROMPT
    PROMPT='$(starship module character --status=$ret)'
    RPROMPT=''
    zle .reset-prompt
    PROMPT=$saved_prompt RPROMPT=$saved_rprompt
    if (( ret )); then zle .send-break; else zle .accept-line; fi
    return ret
  }
  zle -N zle-line-init
fi

if [[ -n ${HOMEBREW_PREFIX:-} ]]; then
  [[ -r $HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]] &&
    source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
