# Terminal cheat sheet

`bat ~/.config/cheatsheet.md` to read it.

## tmux (prefix: Ctrl-b, release, then the key)

| Keys | What it does |
| --- | --- |
| `\|` / `-` | split side by side / stacked, in the current folder |
| `h` `j` `k` `l` | move to the pane left / down / up / right (repeatable) |
| `z` | zoom the current pane; again to restore |
| `c` | new window; `1`–`9` jumps to one, `n` / `p` next / previous |
| `s` | pick a session from a tree (`w` shows windows too) |
| `(` / `)` | previous / next session |
| `L` | last session: flip between two repos |
| `[` | scroll/copy mode (vi keys; Space starts a selection, Enter copies, `q` quits) |
| `x` / `&` | close pane / window (asks first) |
| `d` | detach; everything keeps running (`ta` to return) |
| `r` | reload `~/.config/tmux/tmux.conf` |
| `?` | list every key |

Mouse is on: click to focus, drag a border to resize, wheel to scroll.
`tmux ls` lists sessions; `tmux kill-session -t <name>` closes one.

## Ghostty

- Every window opens the tmux session `main`; Cmd+N opens another view of it.
- Cmd+\` toggles the drop-down terminal. Cmd+Shift+, reloads the config.

## ghost and lab

| Command | What it does |
| --- | --- |
| `ghost <branch>` | worktree + tmux session for a task, then attach |
| `GHOST_AGENT_CMD=claude ghost <branch>` | same, with an agent in the left pane |
| `ghost ls` / `ghost rm <branch>` | list / remove (keeps the branch) |
| `lab` / `lab stop` / `lab down` | local Backstage + kind + Argo CD |

## Shell

| Command | What it does |
| --- | --- |
| Ctrl-R / Ctrl-T / Alt-C | fuzzy history / file path / cd into folder |
| `cd <part of name>` | zoxide jump to a folder you've used |
| `ll`, `la` | list with git status |
| `whereami` | kube context + AWS identity |
| `assume <profile>` | AWS credentials for this shell only |
| `kctx` / `kns` | kube context / namespace for this shell only (kubie) |
| `k`, `kgp`, `klogs` | kubectl, get pods, stern |
| `tfp` / `tfa` | terraform plan to `tfplan` / apply that plan |
| `withsecrets <cmd>` | run with `op://` secrets from `.env.op` |
| `mise use terraform@<ver>` | pin a tool version for this repo |
| `dots` | cd to this repo |

## k9s

`?` help, `:<resource>` jump (`:dp`, `:sts`, `:sec`, `:app` for Argo CD), `/` filter,
Esc back. `k9s --readonly` to just look. The skin follows macOS light/dark mode.
