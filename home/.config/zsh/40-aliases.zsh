# --- General -----------------------------------------------------------------
if command -v eza >/dev/null; then
  alias ls='eza --group-directories-first'
  alias ll='eza -l --git --group-directories-first'
  alias la='eza -la --git --group-directories-first'
fi
command -v bat >/dev/null && alias cat='bat --paging=never --style=plain'
alias reload='exec zsh'
alias dots='cd ${${:-$HOME/.zshrc}:A:h:h}'   # repo dir, via the ~/.zshrc symlink

# --- Kubernetes ------------------------------------------------------------
alias k='kubectl'
compdef k=kubectl 2>/dev/null
alias kctx='kubie ctx'   # new subshell with its own kubeconfig copy
alias kns='kubie ns'
alias kgp='kubectl get pods'
alias kgpa='kubectl get pods -A'
alias kdp='kubectl describe pod'
alias klogs='stern'

# --- tmux / sessions --------------------------------------------------------
alias ta='tmux attach'      # back to the last session
alias tls='tmux ls'

# --- Terraform / OpenTofu --------------------------------------------------
alias tf='terraform'
alias tfp='terraform plan -out=tfplan'
alias tfa='terraform apply tfplan'

# --- AWS -------------------------------------------------------------------
alias awho='aws sts get-caller-identity'
alias aprofiles="aws configure list-profiles"

# --- Git -------------------------------------------------------------------
alias g='git'
alias gs='git status -sb'
alias gl='git log --oneline --graph --decorate -20'
