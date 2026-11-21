# Run a command with secrets injected from 1Password, never written to disk.
#   withsecrets ./deploy.sh
# Reads op:// references from ./.env.op (commit that file; it holds no secrets):
#   GITHUB_TOKEN=op://Work/GitHub PAT/credential
withsecrets() {
  local envfile="${OP_ENV_FILE:-.env.op}"
  [[ -r $envfile ]] || { echo "withsecrets: $envfile not found" >&2; return 1; }
  op run --env-file="$envfile" -- "$@"
}

# Show who/where you are before doing something risky
whereami() {
  print -P "%F{cyan}kube:%f $(command kubectl config current-context 2>/dev/null || echo none)"
  print -P "%F{yellow}aws:%f  ${AWS_PROFILE:-none}"
  command -v aws >/dev/null && aws sts get-caller-identity --query Arn --output text 2>/dev/null
}

# Decode a JWT payload
jwt() { cut -d. -f2 <<<"$1" | base64 -d 2>/dev/null | jq .; }

# k9s with a Catppuccin skin that follows macOS light/dark mode.
# Skins: ~/.config/k9s/skins; k9s.ui.skin lives in k9s's own (untracked) config.yaml.
k9s() {
  local cfg="$XDG_CONFIG_HOME/k9s/config.yaml" skin=catppuccin-latte-transparent
  defaults read -g AppleInterfaceStyle >/dev/null 2>&1 && skin=catppuccin-mocha-transparent
  if [[ -f $cfg ]] && command -v yq >/dev/null; then
    yq -i ".k9s.ui.skin = \"$skin\"" "$cfg"
  fi
  command k9s "$@"
}
