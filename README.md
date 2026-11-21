# dotfiles

My Mac setup for platform/DevOps work. It covers:
- **Shell and terminal:** zsh + starship, Ghostty (opens straight into tmux), tmux with a cheat sheet pop-up (`Ctrl+Space H`), vim
- **git:** delta diffs, optional SSH commit signing through 1Password, GitHub auth through `gh`
- **Cloud and Kubernetes:** AWS SSO via granted, kubie and k9s
- **Toolchains:** mise for every pinned tool (terraform, terragrunt, kubectl, helm, python, node)
- **Two helper commands:** `ghost` (parallel worktree sessions for agentic work) and `lab` (local Backstage + Kubernetes + Argo CD)

One script; no dotfile manager.

## Install

Works on a new Mac and on one that's already set up (including one with an
older dotfiles layout). Clone over HTTPS: the repo is public, so no GitHub
login is needed to install or pull.

1. **1Password** (optional, for SSH commit signing): install it, sign in, then go to
   *Settings → Developer* and enable **Use the SSH agent**. On a managed Mac it may
   already be installed by MDM; the Brewfile skips it then.
2. **Clone and preview** (changes nothing):
   ```sh
   xcode-select --install          # provides git; skip if git already works
   git clone https://github.com/<github-user>/dotfiles ~/Projects/dotfiles
   ~/Projects/dotfiles/install.sh -n
   ```
   Any path works, but don't move the repo after installing: everything is
   symlinked to it. In the preview, check:
   - **Git identity** says `keeping existing identity` if the Mac already has one
     in `~/.gitconfig`. Otherwise it will ask for name, email and an optional signing key.
   - **would back up** / **would move old link** only lists files you expect to be replaced.
   - The `Brewfile` installs what you want on this Mac (e.g. comment out the lab
     tools — colima, docker, kind, argocd — if you won't use `lab`).
3. **Install**:
   ```sh
   brew uninstall tenv               # only if installed: mise manages terraform now
   ~/Projects/dotfiles/install.sh
   ```
   The script:
   - installs Homebrew and everything in the `Brewfile`
   - symlinks everything in `home/` into your home folder, backing up existing files to `~/.dotfiles-backup/`
   - moves aside symlinks left by an older layout (see below)
   - asks for your git name, email and signing key, unless your global git config (e.g. `~/.gitconfig`) already has an email
   - installs the mise toolchains and the tmux plugins (tpm)
   - applies the macOS defaults (`macos-defaults.sh`)
   - turns on the gitleaks hook for this repo

   It's safe to re-run.
4. **Reload**: open a new Ghostty window, or `exec zsh`. If tmux was already
   running, run `tmux source-file ~/.config/tmux/tmux.conf` in it (or restart the
   tmux server when nothing important is running). `Ctrl+Space H` should then
   show the cheat sheet.
5. **GitHub auth for git**, so git never asks for a password:
   ```sh
   gh auth login                                   # github.com
   gh auth setup-git
   # GitHub Enterprise: add --hostname <GHE host> to both commands
   ```
   Check: `GIT_TERMINAL_PROMPT=0 git ls-remote <repo URL>` works without a prompt.
6. **AWS profiles** (generated from your SSO access, so nothing about your employer goes in this repo):
   ```sh
   granted sso generate --sso-region <region> https://<org>.awsapps.com/start >> ~/.aws/config
   whereami                          # check kube context and AWS identity
   ```
7. **For Backstage**: `corepack enable` (provides yarn).

**Updating later:** `git -C ~/Projects/dotfiles pull`, then re-run `install.sh`
if files were added under `home/` or to the `Brewfile`.

**Not managed here:**
- `~/.claude` (Claude Code config). If it's symlinked into an older dotfiles
  checkout, keep that checkout where it is.
- Per-machine Homebrew extras. A `Brewfile.local` from an older layout is no
  longer loaded; install it yourself with `brew bundle --file <path>/Brewfile.local`.

## How it's laid out

`home/` mirrors your home folder: `home/.config/tmux/tmux.conf` becomes `~/.config/tmux/tmux.conf`. To add a config file, put it at the matching path in `home/` and re-run `./install.sh`.

Because the files are symlinks, editing `~/.zshrc` edits the repo. Commit and push as usual (`dots` jumps to the repo). To push over SSH, run this once: `git remote set-url origin git@github.com:<github-user>/dotfiles.git`.

```
install.sh          setup (-n = dry run)
Brewfile            CLI tools and apps
macos-defaults.sh   keyboard, Finder, Dock and screenshot settings
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
`terraform` doesn't compete with mise's: `brew uninstall tenv` (or `tfenv`).

## ghost: parallel tasks and agents

Each task gets its own git worktree (a separate folder on its own branch) and its own tmux session, so agents never edit the same files.

```sh
cd ~/Projects/myrepo
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
