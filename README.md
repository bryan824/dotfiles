# Dotfiles

Personal dotfiles managed with [mise](https://mise.jdx.dev/dotfiles.html).

One repo configures shell, editor, terminal, Git and developer tools across
four machine classes, and push-bootstraps a VPS fleet over SSH.

## Machine classes

Everything is selected by `MISE_ENV`, which is **always** set — there is no
"unset means default" case.

| `MISE_ENV` | Machine |
|---|---|
| `bryan` | Bryan's personal mac |
| `work` | Bryan's work mac |
| `irene` | Irene's personal mac |
| `server` | VPS / VM |

What each class gets:

| | `bryan` | `work` | `irene` | `server` |
|---|:--:|:--:|:--:|:--:|
| zsh, git, starship, nvim, ripgrep, direnv, core CLI | ✅ | ✅ | ✅ | ✅ |
| terminals (kitty, ghostty, wezterm) | ✅ | ✅ | ✅ | — |
| window managers (aerospace, nehir) | ✅ | ✅ | ✅ | — |
| television, herdr, LazyVim, Claude settings | ✅ | ✅ | ✅ | — |
| k9s, zellij, kubectl, helm, kustomize, duckdb | ✅ | ✅ | — | — |
| talosctl, cilium, supabase, kopia, agent tooling | ✅ | — | — | — |
| gemini-cli, kopia, rclone | — | — | ✅ | — |

File-level selection lives in `[dotfiles]` `variants` in
`.config/mise/config.toml`. Tool-level selection lives in
`.config/mise/config.<class>.toml`.

## Bootstrap a new machine

```sh
git clone https://github.com/bryan824/dotfiles.git ~/.dotfiles
```

**Write both machine-local files before applying anything.** Neither is
committed; each machine sets its own.

```sh
mkdir -p ~/.config/mise

# 1. Machine class. Without this, only the 12 base tools load and every
#    desktop dotfile is skipped.
cat > ~/.config/mise/miserc.toml <<'EOF'
env = ["bryan"]        # bryan | work | irene | server
EOF

# 2. Git identity. Without this, ~/.config/git/config renders with no
#    [user] section and commits lose their author.
cat > ~/.config/mise/config.local.toml <<'EOF'
[vars]
git_name  = "Your Name"
git_email = "you@example.com"
EOF
```

Then link mise's own config into place once, to break the chicken-and-egg
(mise must load the config that manages its config), and bootstrap:

```sh
ln -sf ~/.dotfiles/.config/mise/config.toml ~/.config/mise/config.toml
mise bootstrap dotfiles diff     # always preview first
mise bootstrap dotfiles apply -f
```

`-f` is needed on a machine that already has real files at those paths.

## Bootstrap the fleet

Servers are pushed to, never pulled from. Nothing persistent lands on the box —
`--github-relay-read-only` borrows GitHub access for the invocation only.

```sh
mise bootstrap remote --tag vps \
  --remote-env server \
  --only dotfiles,tools \
  --github-relay-read-only \
  --install-mise
```

Hosts live in `[bootstrap.remote.hosts]`. Preview any run with `--dry-run`.

Servers set `history.enabled = false` so a box never publishes its local drift
back to this repo.

## Daily use

```sh
mise bootstrap dotfiles status    # what is managed, and its state
mise bootstrap dotfiles diff      # preview pending changes
mise bootstrap dotfiles apply     # apply
mise bootstrap dotfiles add --changed   # pull copy-mode edits back into the repo
```

Most files are symlinked, so editing the live path edits this repo directly —
no capture step. The exceptions are listed below.

## Layout

Source paths mirror their target exactly. `~/.config/nvim` comes from
`.config/nvim`. No filename prefixes or suffixes, except `.tera` on templates.

```
.config/mise/config.toml          # settings + [dotfiles] table + base tools
.config/mise/config.bryan.toml    # per-class tools
.config/mise/config.work.toml
.config/mise/config.irene.toml
.config/mise/config.server.toml
.config/zsh/                      # numbered startup fragments + Zim
.config/nvim/  .config/lazyvim/
.config/kitty/  .config/ghostty/  .config/wezterm/
.config/git/  .config/television/  .config/k9s/  ...
```

### Templates (`.tera`)

Rendered, not linked. Editing the live file does **not** reach this repo.

| Target | Why |
|---|---|
| `.config/git/config` | `vars.git_name` / `vars.git_email` |
| `.config/starship.toml` | gcloud module on `bryan` + `work` |
| `.config/zsh/80_host.zsh` | `TALOSCONFIG` on `bryan` |
| `.claude/settings.json` | strict JSON, needs absolute `$HOME` |
| `.config/kitty/launch.conf` | kitty does not expand `~` in `launch` |
| `.config/k9s/config.yaml` | k9s does not expand `~` in `screenDumpDir` |

### Copy-mode files

Their own tool rewrites them at runtime, so they are copied rather than
symlinked — otherwise every plugin update or app exit dirties this repo. Use
`mise bootstrap dotfiles add --changed` to pull real changes back.

- `.config/nvim/nvim-pack-lock.json` — plugin revs, written by `vim.pack`
- `.config/lazyvim/lazyvim.json` — extras + news state, written by LazyVim
- `.config/kitty/current-theme.conf` — written by the `themes` kitten

## Notes

- Shell startup uses `ZDOTDIR=~/.config/zsh` from `.zshenv`.
- `ipinfo` reads `$IPINFO_TOKEN`, supplied age-encrypted from
  `config.bryan.toml`. Add a secret with
  `mise set -g --age-encrypt --prompt NAME`, then move the line into the class
  config that needs it — see AGENTS.md.
- Agent harness deployment stays separate: `bunx github:bryan824/kirin-pi apply`.
- Secrets never live in this repo. Machine identity goes in
  `~/.config/mise/config.local.toml`; anything else reads from the environment.
