# dotfiles

Personal cross-machine environment: bash, two Neovim flavors, terminal
(kitty) + multiplexer (zellij), git, and a set of non-root tool installers.
One `dotfiles.sh` symlinks everything into place; nothing needs root.

## Layout

| Path                                   | What lives here                                                             |
| -------------------------------------- | --------------------------------------------------------------------------- |
| `dotfiles.sh`                          | Bootstrap: symlinks config into `$HOME` and drives the tool installers.     |
| `bash_functions.sh`, `bash_aliases.sh` | Sourced by `~/.bashrc`; `bash_functions.sh` auto-sources every              |
|                                        | `utils/bash_*.sh`.                                                          |
| `initrc/`                              | Config files, symlinked to `~/.<name>` (bashrc, gitconfig, inputrc, kitty/, |
|                                        | zellij/, atuin.toml, …).                                                    |
| `utils/`                               | Shell libraries (`bash_*.sh`, auto-sourced) + standalone helper scripts on  |
|                                        | `PATH`.                                                                     |
| `install/`                             | Non-root, per-tool installers into `~/.local`; `install_all.sh`             |
|                                        | orchestrates them.                                                          |
| `nvim.pack/`                           | Neovim config using the built-in `vim.pack` manager — the **default** `vi`. |
| `nvim.easy/`                           | Neovim config using `lazy.nvim` — reached via `vi -p` ("previous").         |
| `snippets/`                            | VS Code-format snippet JSON shared by both Neovim flavors (see              |
|                                        | `snippets/README.md`).                                                      |
| `formatters/`                          | Shared formatter configs (`clang-format`, `verible-rules`,                  |
|                                        | `py-format.toml`, `semifore.py`).                                           |
| `docs/`                                | Reference notes (e.g. `aarch32-cp15-registers.md`).                         |
| `.githooks/`                           | `post-checkout` / `post-merge` re-apply sensitive perms via `fix-perms`.    |

## Install

```sh
git clone git@github.sm:mallicksm/dotfiles.git ~/dotfiles
export corp=<your-site>          # required; gates the corp overlay below
bash ~/dotfiles/dotfiles.sh      # runs the default `all` action
```

`dotfiles.sh` dispatches on its first argument (`"${1:-all}"`), so you can run
individual actions instead of the full setup:

```sh
bash ~/dotfiles/dotfiles.sh linkrc          # only (re)link the dotfiles
bash ~/dotfiles/dotfiles.sh getfonts Hack   # install a Nerd Font
bash ~/dotfiles/dotfiles.sh --dry-run       # -n: print every change, do nothing
```

Bulk tool installs live under `install/` (run `install/install_all.sh`), each
fetching a modern build into `~/.local/bin` without root.

## How linking works

`linkrc` walks `initrc/*` and symlinks each entry to `~/.<name>` by default
(e.g. `initrc/bashrc → ~/.bashrc`). Exceptions are mapped explicitly in
`dotfiles.sh`'s `link_map` — notably:

- `kitty/`, `git/` → `~/.config/{kitty,git}`
- `atuin.toml` → `~/.config/atuin/config.toml`
- `config.ssh` → `~/.ssh/config`
- `z.sh`, `zellij` → `/dev/null` (skipped)

Kitty gets a per-OS include: `link_kitty_os` points `kitty.os.conf` at
`kitty.darwin.conf` or `kitty.linux.conf` based on `uname` (gitignored, so the
repo stays OS-agnostic).

## Neovim

Two independent configs, selected by the `vi` wrapper in `utils/bash_nvim.sh`:

- **`vi`** → `nvim.pack` (built-in `vim.pack` package manager) — the default.
- **`vi -p`** → `nvim.easy` (`lazy.nvim`) — the "previous" setup.

Both load via `NVIM_APPNAME` with `XDG_CONFIG_HOME=~/dotfiles`.

## SSH

`initrc/config.ssh` is linked to `~/.ssh/config`; see its header for host
disambiguation. The git hooks force it back to mode `600` after any
checkout/pull (ssh refuses a group/world-readable config).

## Corp overlay (optional)

Site-specific bits stay out of this repo. If present, `dotfiles.sh` sources
`~/corp/dotfiles.sh` and links `~/corp/corp_settings.sh → ~/corp_settings.sh`;
`bash_cd_func.sh` picks up `$CORP_CDPATH` if the overlay exports it. On a
non-corp box these are simply no-ops.
