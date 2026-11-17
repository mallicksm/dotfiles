# `recipe.sh` — spec for the `~/dotfiles/install` tool installers

Every tool in `~/dotfiles/install` installs the same way: a thin
`<tool>_local_install.sh` that declares what the tool is and supplies only the
steps unique to it, on top of a shared engine, `recipe.sh`, that provides the
command-line, the dry run, the version resolution and the summary.

Each installer is standalone — runnable on its own with its own `-h` — and is
also what `dotfiles.sh` and `install_all.sh` call.

## Layout

|                   |                                                     |
| ----------------- | --------------------------------------------------- |
| Engine            | `~/dotfiles/install/recipe.sh` (sourced, not run)   |
| Spec              | `~/dotfiles/install/recipe.md` (this file)          |
| Primitives        | `~/dotfiles/install/lib.sh`                         |
| One tool          | `~/dotfiles/install/<tool>_local_install.sh`        |
| Whole set         | `~/dotfiles/install/install_all.sh`                 |
| Install root      | `$LOCAL_PREFIX`, default `~/.local`                 |
| Binaries          | `$BIN` = `$PREFIX/bin`                              |
| Unpacked trees    | `$TOOLSDIR` = `$PREFIX/tools`                       |
| Scratch           | `$WORKROOT` = `${TMPDIR:-/tmp}/$USER/dotfiles-install` |

`lib.sh` is the older primitive layer and still owns the install layout and the
GitHub "latest release" lookup. `recipe.sh` sources it. Its mutating `sm_*`
helpers (`sm_install_bin`, `sm_workdir`, …) run immediately and so are **not**
used from job bodies; the `rc_*` wrappers are the dry-run-aware equivalents.

## Synopsis

```
<tool>_local_install.sh [-e] [-j JOB...] [-f] [-r VERSION] [-n] [-h] [ARG...]
```

No arguments prints the dry run. `-h` prints usage and exits `0`.

| Argument            | Meaning                                                       |
| ------------------- | ------------------------------------------------------------- |
| `-e, --execute`     | actually do it; **the default is a dry run**                  |
| `-j, --jobs JOB...` | run only these jobs (always reordered to canonical order)     |
| `-f, --force`       | reinstall even when the target version is already present     |
| `-r, --version VER` | install this version instead of the default                   |
| `-n, --no-install`  | fetch/build only; leave `$BIN` untouched                      |
| `-h, --help`        | usage, exit `0`                                               |
| `--`                | end of options; the rest are positionals (only `fonts` takes any) |

## Jobs

Jobs always run in this order no matter what order `-j` lists them, and a FAIL
stops the run. A tool declares the subset that applies to it; each job is
independently runnable.

| Job       | Action                                                                   |
| --------- | ------------------------------------------------------------------------ |
| `check`   | compare installed against upstream — read-only, runs even in dry mode   |
| `fetch`   | download and unpack the release into a scratch dir under `$WORKROOT`     |
| `build`   | compile from source                                                      |
| `install` | place binaries in `$BIN`, or an unpacked tree in `$TOOLSDIR`/`$PREFIX`    |
| `link`    | symlink an unpacked tree's `bin/*` into `$BIN`                           |
| `verify`  | run the installed binary and report its version                          |

`check` is the one worth knowing: `install_all.sh -j check` reports, for every
tool at once, what is installed versus what upstream has.

## Dry run / execute

Dry run is the default and prints the exact `cd DIR && argv` of every command.
Both modes route through one `step` choke point, so the preview cannot drift
from what executes. `-e` opts in to running.

Two deliberate exceptions, both read-only: the `check` job, and the
`rc_export` lines, which print the build environment once per job rather than
repeating an expanded `$PATH` on every command.

Anything a job body does outside `step` must be read-only **and** guarded with
`rc_real`, because in a dry run the earlier jobs did not actually run and the
files it would inspect do not exist.

## Versions

Resolved in this order:

1. `-r VERSION`
2. the tool's pin variable, e.g. `$STARSHIP_VERSION`, `$NVIM_VERSION`
3. the newest GitHub release of `$TOOL_REPO` — **unless** the tool sets
   `TOOL_PIN_IS_POLICY=1`
4. `TOOL_PIN_DEFAULT`

`TOOL_PIN_IS_POLICY=1` marks a pin that is a decision, not staleness, and the
default therefore wins over "newest". Four tools use it, each for a reason
`check` will still tell you about:

| Tool        | Why pinned                                                            |
| ----------- | --------------------------------------------------------------------- |
| `clang`     | the asset name encodes version *and* distro, so "newest" is not a URL |
| `git`       | one of four libraries that have to agree with each other              |
| `verilator` | tracks the `stable` branch, not a tag                                 |
| `riscvgcc`  | tracks `master`, not a tag                                            |

Several tools have no GitHub releases at all and resolve differently: `node`
reads `nodejs.org/dist/index.json` for the newest LTS, `gettext` scrapes the
GNU ftp listing, `z` uses a git ref, and the RPM/AppImage tools
(`xclip`, `w3m`, `x11apps`, `magick`) have a fixed URL and no version to chase.

## Skip behaviour

Before running anything, the engine decides whether the mutating jobs have
work to do. It skips them when the installed version equals the target, and
reports `skipped -- already at <version> (-f to reinstall)`.

A binary that is present but will **not** report a version is treated as a
broken install and reinstalled, not skipped — that is the case that most needs
fixing. Tools with genuinely no version to read (`z`, which is a sourced shell
script) opt into presence-only skipping with `TOOL_SKIP_IF_PRESENT=1`.
`TOOL_ALWAYS=1` opts out of skipping entirely, for `pip` (whose whole job is
`--upgrade`), `fonts` (which decides per family) and `magick` (a rolling URL
where re-fetching *is* the upgrade).

## Failure policy

Fail-soft with three states. Each job records OK / WARN / FAIL and the run ends
with an aligned summary and an `N OK, M WARN, K FAIL` footer. WARN is surfaced
but never affects the exit code.

| Exit | Meaning                    |
| ---- | -------------------------- |
| `0`  | success, or `-h`           |
| `1`  | a job FAILed               |
| `2`  | usage or validation error  |

Prerequisites (`TOOL_NEEDS`) are only enforced for jobs that do work, so
`-j check` stays runnable on a box missing the compilers.

## Forensics

On `-e`, logs go to `/tmp/dotfiles-install.<tool>.<timestamp>.forensics/` with
one log per job, plus `invocation.txt` and `summary.txt`. `install_all.sh`
keeps its own `/tmp/dotfiles-install_all.<timestamp>.forensics/` with one log
per tool.

## Writing a new recipe

Declare, then define the jobs that are not stock:

```bash
#!/usr/bin/env bash
set -uo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/recipe.sh"

TOOL=starship
TOOL_DESC="cross-shell prompt"
TOOL_REPO=starship/starship
TOOL_PIN_VAR=STARSHIP_VERSION
TOOL_PIN_DEFAULT=v1.23.0
TOOL_BINS=(starship)
TOOL_NEEDS=(curl tar)
TOOL_JOBS=(check fetch install verify)

job_fetch()   { rc_workdir; rc_fetch_extract "https://.../$VER/...tar.gz"; }
job_install() { rc_install_bin ./starship; }

recipe_main "$@"
```

### Declarations

| Variable               | Meaning                                                   |
| ---------------------- | --------------------------------------------------------- |
| `TOOL`                 | short name; must match the `<tool>` in the filename       |
| `TOOL_DESC`            | one line, shown in `--help`                               |
| `TOOL_REPO`            | `owner/repo` for the release lookup, `""` if not GitHub   |
| `TOOL_PIN_VAR`         | env var that pins the version                             |
| `TOOL_PIN_DEFAULT`     | fallback when there is no repo or the lookup fails        |
| `TOOL_PIN_IS_POLICY`   | `1` = the default pin beats "newest"                      |
| `TOOL_BINS`            | binaries landing in `$BIN`; first one is the version probe |
| `TOOL_VERSION_FLAG`    | default `--version` (`xclip` wants `-version`)            |
| `TOOL_NEEDS`           | prerequisite commands                                     |
| `TOOL_JOBS`            | the subset of jobs this tool has                          |
| `TOOL_ALWAYS`          | `1` = never skip as already-installed                     |
| `TOOL_SKIP_IF_PRESENT` | `1` = presence alone is enough to skip                    |
| `TOOL_SLOW`            | `1` = warn in `--help` that this is a long build          |
| `TOOL_ARGS_NAME`       | non-empty = this tool takes positionals                   |
| `TOOL_USAGE_EXTRA`     | extra prose for `--help`                                  |
| `TOOL_ENV_EXTRA`       | extra env vars for `--help`                               |
| `RECIPE_JOB_DESC[job]` | override a job's one-line description                     |

### Helpers for job bodies

| Helper                       | Does                                                    |
| ---------------------------- | ------------------------------------------------------- |
| `rc_workdir [name]`          | fresh scratch dir, `cd` into it, set `$W`               |
| `rc_dir DIR`                 | where the following commands run                        |
| `run CMD...`                 | run argv in `$RC_DIR` through `step`                    |
| `run_sh 'TEXT'`              | for genuine shell syntax (pipes, heredocs, `curl \| sh`) |
| `rc_fetch URL [OUT]`         | download into `$RC_DIR`                                 |
| `rc_extract FILE`            | unpack a `tar.*`/`zip`                                  |
| `rc_fetch_extract URL`       | both                                                    |
| `rc_install_bin SRC [NAME]`  | copy an executable into `$BIN`, mode 0755               |
| `rc_link_bin TARGET NAME`    | `ln -sfn` into `$BIN`                                   |
| `rc_link_tree_bins DIR`      | symlink every `DIR/bin/*` into `$BIN`                   |
| `rc_mkdir` / `rc_rmrf`       | `mkdir -p` / `rm -rf` through `step`                    |
| `rc_export NAME=VALUE...`    | build environment for later commands, printed once      |
| `rc_nov TAG`                 | strip a leading `v`                                     |
| `rc_real`                    | true only when really executing — guard all inspection  |
| `record KEY STATUS DETAIL`   | add a summary row (`OK` / `WARN` / `FAIL`)              |
| `rc_check_fixed_url`         | stock `check` for fixed-URL tools; set `RC_FIXED_URL`   |

Overriding `rc_present`, `rc_installed_version`, `rc_resolve_version`,
`recipe_skip_check`, `job_check` or `job_verify` is normal — several tools do.
`$VER` holds the resolved target version by the time any job runs.

## The tools

`install_all.sh --list` is the live list. Groups run in this order:

| Group      | Tools                                                                       |
| ---------- | --------------------------------------------------------------------------- |
| `modern`   | ripgrep fd bat delta eza procs lazygit                                       |
| `prebuilt` | starship zellij patchelf pandoc verible nvim fzf node z clang_format fonts   |
| `rpm`      | xclip w3m x11apps                                                            |
| `app`      | kitty ollama magick clang                                                    |
| `source`   | git gettext verilator riscvgcc                                               |
| `pip`      | pip                                                                          |

`app` and `source` are skipped in a default run — hours of compiling and
multi-hundred-megabyte trees — and are opted into with `-g` or `-a`.

Four tools do not put a binary in `$BIN` and so look slightly different:

| Tool    | Where it goes                 | Why                                              |
| ------- | ----------------------------- | ------------------------------------------------ |
| `z`     | `~/dotfiles/initrc/z.sh`      | a sourced shell function, not a binary           |
| `fzf`   | `~/.fzf` checkout             | `utils/bash_fzf.sh` sources its `shell/*.bash`   |
| `node`  | `~/.local/node`               | `utils/bash_node.sh` puts its `bin` on PATH      |
| `fonts` | `~/.local/share/fonts/<Family>` | font files, and a `fc-cache` refresh            |

Two tools both write `$BIN/clang-format`: `clang` (the full LLVM drop, which
also gives clangd and clang-tidy) and `clang_format` (one static binary, no
glibc requirement). Whichever ran last wins.

## Orchestrators

```
install_all.sh [-e] [-g GROUP...] [-j JOB...] [-f] [-a] [-l] [-h] [TOOL...]
```

Dry run by default like everything else; `-e`, `-f` and `-j` are forwarded
unchanged to each installer. Named tools run in group order, not the order
typed.

The old `modern_linux_tools.sh` is gone: its seven tools each have their own
recipe now, and `install_all.sh -g modern` is the group.

`dotfiles.sh` owns linking and calls these for installing:

| `dotfiles.sh` action | Runs                                        |
| -------------------- | ------------------------------------------- |
| `all` (default)      | `linkrc`, the core tools, then `install_zvim` |
| `install [TOOL...]`  | those installers, or the core set            |
| `check`              | `install_all.sh -a -j check`                 |
| `tools`              | `install_all.sh --list`                      |

`dotfiles.sh -n` is the same switch: it simply does not pass `-e` down, so
there is only one notion of "pretend" across all three layers.

## Examples

```bash
# What is stale, across everything?
install/install_all.sh -j check

# Update the three you actually notice
dotfiles.sh install starship zellij fzf

# One tool, pinned, previewed first
install/nvim_local_install.sh -r v0.11.3
install/nvim_local_install.sh -e -r v0.11.3

# Re-link dotfiles, install nothing
dotfiles.sh linkrc

# Two more font families
dotfiles.sh getfonts JetBrainsMono Meslo

# The whole set including the slow from-source builds
install/install_all.sh -e -a

# Rebuild just the link step after hand-editing a tools tree
install/verible_local_install.sh -e -j link
```
