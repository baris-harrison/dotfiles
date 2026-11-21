# dotfiles

My Mac setup for platform/DevOps work. It covers:
- **Shell and terminal:** zsh + starship, Ghostty (opens straight into tmux), tmux, vim
- **git:** SSH signing through 1Password
- **Cloud and Kubernetes:** AWS SSO via granted, kubie and k9s
- **Toolchains:** mise for every pinned tool (terraform, terragrunt, kubectl, helm, python, node)
- **Two helper commands:** `ghost` (parallel worktree sessions for agentic work) and `lab` (local Backstage + Kubernetes + Argo CD)

One script; no dotfile manager.

## New device

1. **1Password**: install it, sign in, then go to *Settings → Developer* and enable **Use the SSH agent**.
2. **Clone and run**:
   ```sh
   xcode-select --install          # provides git; wait for it to finish
   git clone https://github.com/<github-user>/dotfiles ~/dotfiles
   ~/dotfiles/install.sh -n        # optional: preview, changes nothing
   ~/dotfiles/install.sh
   ```
   The script:
   - installs Homebrew and everything in the `Brewfile`
   - symlinks everything in `home/` into your home folder, backing up existing files to `~/.dotfiles-backup/`
   - asks for your git name, email and signing key, unless your global git config (e.g. `~/.gitconfig`) already has an email
   - installs the mise toolchains
   - applies the macOS defaults
   - turns on the gitleaks hook

   It's safe to re-run.
3. **AWS profiles** (generated from your SSO access, so nothing about your employer goes in this repo):
   ```sh
   granted sso generate --sso-region <region> https://<org>.awsapps.com/start >> ~/.aws/config
   ```
4. **For Backstage**: `corepack enable` (provides yarn).

## How it's laid out

`home/` mirrors your home folder: `home/.config/tmux/tmux.conf` becomes `~/.config/tmux/tmux.conf`. To add a config file, put it at the matching path in `home/` and re-run `./install.sh`.

Because the files are symlinks, editing `~/.zshrc` edits the repo. Commit and push as usual (`dots` jumps to the repo). To push over SSH, run this once: `git remote set-url origin git@github.com:<github-user>/dotfiles.git`.

```
install.sh          setup (-n = dry run)
Brewfile            CLI tools and apps
macos-defaults.sh   keyboard, Finder, Dock settings
home/               symlinked into ~
  .zshenv .zshrc  .config/zsh/   shell
  .config/git/  .config/ghostty/  .config/starship.toml  .config/mise/
  .config/tmux/tmux.conf        tmux (prefix Ctrl+Space)
  .config/k9s/                  aliases (incl. :app for Argo CD) + Catppuccin skins
  .config/cheatsheet.md         tmux, Ghostty, shell and k9s keys
  .vimrc                        2-space indent for YAML/JSON/HCL/shell/Markdown, 4 for Python
  .kube/kubie.yaml              kubie reads ~/.kube/config + ~/.kube/configs/*
  .ssh/config                   1Password SSH agent
  .local/bin/ghost  .local/bin/lab
```

## Moving from an older dotfiles layout

`install.sh` moves aside symlinks an earlier layout left behind (`~/.tmux.conf`,
`~/.zprofile`, `~/bin/ghost`, k9s files under `~/Library/Application Support/k9s`)
when they point outside this repo, and copies k9s's own `config.yaml`/`clusters`
to `~/.config/k9s` once. Everything moved goes to `~/.dotfiles-backup/`.

If another version manager (tenv, tfenv) is installed, remove it so its
`terraform` doesn't compete with mise's: `brew uninstall tenv`.

## ghost: parallel tasks and agents

Each task gets its own git worktree (a separate folder on its own branch) and its own tmux session, so agents never edit the same files.

```sh
cd ~/src/myrepo
ghost fix-login                          # worktree + session, then attach
GHOST_AGENT_CMD=claude ghost add-tests   # same, and start an agent in the left pane
ghost ls                                 # list sessions and worktrees
ghost rm fix-login                       # remove session + worktree (keeps the branch)
```

- Worktrees go next to the repo, in `../myrepo.worktrees/<branch>`.
- Each session has two panes: an agent or editor on the left and a shell on the right.
- Run `assume <profile>` before `ghost`, and the panes get those AWS (and `KUBECONFIG`) credentials.
- Switch between sessions with `Ctrl+Space s`.

## lab: local Backstage + Kubernetes + Argo CD

```sh
lab          # start or reattach
lab stop     # close the session; the cluster keeps running
lab down     # close the session and delete the cluster
```

`lab` starts colima and a kind cluster called `lab` if needed, then opens one tmux session with four panes:
- the Backstage dev server
- an Argo CD port-forward that reconnects automatically (https://localhost:8080)
- k9s
- Argo CD logs

Every pane is pinned to the `kind-lab` context, so it can never touch a real cluster. Installing Argo CD and creating the Backstage app are up to you; until then, those panes say what's missing. Settings are at the top of `home/.local/bin/lab`.

## Keep it public-safe

A gitleaks pre-commit hook blocks commits that contain secrets, AWS account IDs or real SSO URLs. For a false positive, add `gitleaks:allow` to the line.

Never committed:
- `~/.config/git/config.local` for git identity and signing (written by the script when no identity exists yet; an existing `~/.gitconfig` is left alone)
- `~/.zshrc.local` for shell settings
- `~/.ssh/config.d/*` for SSH hosts
- `~/.kube/` kubeconfigs and `~/.aws/`

## Handy commands

| | |
|---|---|
| `assume <profile>` | AWS credentials for this shell only |
| `kctx` / `kns` | switch kube context/namespace in an isolated subshell |
| `whereami` | show current kube context and AWS identity |
| `ta` | reattach to tmux after closing Ghostty |
| `withsecrets <cmd>` | run with secrets from 1Password (`op://` refs in `.env.op`) |
| `mise use terraform@1.9.8` | pin a tool version for the current repo |
