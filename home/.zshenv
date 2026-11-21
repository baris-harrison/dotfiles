# Read by every zsh (including scripts). Keep it tiny: env vars only.
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

export EDITOR="${EDITOR:-vim}"
export PAGER="less"
export LESS="-R -F -X"

# Use 1Password's SSH agent everywhere (git, ssh, scp, ansible…)
export SSH_AUTH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# AWS: never fall back to a long-lived default profile by accident
export AWS_SDK_LOAD_CONFIG=1
export AWS_PAGER=""

typeset -U path
path=("$HOME/.local/bin" $path)
