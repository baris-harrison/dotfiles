# Interactive shell. Modules live in ~/.config/zsh/*.zsh (-> zsh/conf.d/) and load in
# lexical order. Target: <100ms startup (measure: `zsh-bench` or
# `time zsh -i -c exit`). Every tool is guarded so a half-bootstrapped
# machine still gets a working shell.

# Homebrew first so everything below can find its tools
if [[ -x /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

for _f in "$XDG_CONFIG_HOME"/zsh/*.zsh(N); do
  source "$_f"
done
unset _f

# Machine-local, uncommitted overrides (client hostnames, experiments…)
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"
