# tmux pane label: on each cd, store the repo name (or the folder name outside a repo) in
# the pane option @label, which pane-border-format in tmux.conf shows. Event-driven, so
# tmux runs no per-pane polling; pure zsh (walks up to the nearest .git, file or dir, so
# worktrees count), so the only process is one `tmux set` per cd.
if [[ -n ${TMUX:-} && -n ${TMUX_PANE:-} ]]; then
  _tmux_pane_label() {
    local d=$PWD
    while [[ $d != / && ! -e $d/.git ]]; do d=${d:h}; done
    [[ -e $d/.git ]] || d=$PWD
    tmux set -p -t "$TMUX_PANE" @label "${d:t}" 2>/dev/null
  }
  autoload -Uz add-zsh-hook
  add-zsh-hook chpwd _tmux_pane_label
  _tmux_pane_label
fi
