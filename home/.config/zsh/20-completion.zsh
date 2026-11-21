# Completion with caching. Slow `<tool> completion zsh` calls are
# generated once into a cache dir and refreshed only when the tool binary
# changes, instead of on every shell start.

_zcomp_dir="$XDG_CACHE_HOME/zsh/completions"
[[ -d $_zcomp_dir ]] || mkdir -p "$_zcomp_dir"
fpath=("$_zcomp_dir" $fpath)
[[ -n ${HOMEBREW_PREFIX:-} ]] && fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)

# _cache_completion <name> <command...>
_cache_completion() {
  local name=$1; shift
  local bin; bin=$(command -v "$1") || return 0
  local out="$_zcomp_dir/_$name"
  if [[ ! -s $out || $bin -nt $out ]]; then
    "$@" >| "$out" 2>/dev/null
  fi
}
_cache_completion kubectl kubectl completion zsh
_cache_completion helm    helm completion zsh
_cache_completion mise    mise completion zsh
_cache_completion gh      gh completion -s zsh
_cache_completion k9s     k9s completion zsh
_cache_completion stern   stern --completion zsh
_cache_completion kind    kind completion zsh
_cache_completion argocd  argocd completion zsh

# Rebuild the dump at most once a day
autoload -Uz compinit
_zcompdump="$XDG_CACHE_HOME/zsh/zcompdump"
if [[ -n $_zcompdump(#qN.mh+24) || ! -s $_zcompdump ]]; then
  compinit -d "$_zcompdump"
else
  compinit -C -d "$_zcompdump"
fi

# AWS CLI uses bash-style completion
autoload -Uz bashcompinit && bashcompinit
command -v aws_completer >/dev/null && complete -C aws_completer aws

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

unset _zcomp_dir _zcompdump
