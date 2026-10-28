# `artcraft.sh` — spec

Bootstrap or update an **ArtCraft** app (`github.com/storytold/*`): clone the
repo, check out the newest release tag, rebuild the desktop app and the CLI in
release mode, and install both into `~/.local/bin` keeping the previous
binaries as `.bak` files.

Supersedes `pdfcraft_refresh.sh`, which handled only PdfCraft. The product is
now the first argument.

## Location & `$PATH`

|                     |                                              |
| ------------------- | -------------------------------------------- |
| Script              | `~/dotfiles/install/artcraft.sh`             |
| Spec                | `~/dotfiles/install/artcraft.md` (this file) |
| Default checkout    | `$HOME/<product>`                            |
| Default install dir | `$HOME/.local/bin`                           |

Runnable from any directory; symlinks are resolved so a link on `$PATH` still
finds the real script.

## Synopsis

```
artcraft.sh <product> [-e] [-j JOB...] [-s DIR] [-r REF] [-n] [--no-models]
```

No arguments, or `-h`/`--help`, prints usage and exits `0`.

## Products

| Product     | What it is     | Checkout      | OCR models |
| ----------- | -------------- | ------------- | ---------- |
| `pdfcraft`  | PDF editor     | `~/pdfcraft`  | yes        |
| `gridcraft` | spreadsheet    | `~/gridcraft` | no         |
| `wordcraft` | word processor | `~/wordcraft` | no         |

All three share one workspace layout: `apps/<product>` (egui desktop),
`apps/<product>-cli`, `apps/<product>-web`. The script builds and installs the
first two as `<product>` and `<product>-cli`.

`<product>-web` is **never built or installed**. It is a WASM target — its
native binary only prints a hint to run `trunk build --release` — so putting it
on `$PATH` would be a trap.

Only pdfcraft has a `models` xtask. For the other two the `models` job is
dropped from the default job list, and naming it explicitly records a WARN
rather than failing.

**The product must come first.** `-j` greedily consumes the non-flag tokens
after it, so a trailing product name would be swallowed as a job name. A
leading flag is rejected with a usage error.

## Arguments

| Argument            | Meaning                                                            |
| ------------------- | ------------------------------------------------------------------ |
| `<product>`         | required first positional: `pdfcraft`, `gridcraft`, or `wordcraft` |
| `-e, --execute`     | actually run; **default is a dry run**                             |
| `-j, --jobs JOB...` | run only these jobs (always reordered to canonical order)          |
| `-s, --src DIR`     | checkout to create or update                                       |
| `-r, --ref REF`     | tag or branch to build (default: newest `vN.N.N` tag)              |
| `--main`            | shorthand for `-r origin/main`                                     |
| `--url URL`         | upstream repository                                                |
| `-n, --no-install`  | build only; leave the install dir untouched                        |
| `--no-models`       | skip `cargo xtask models` (pdfcraft only)                          |
| `-h, --help`        | usage, exit `0`                                                    |

## Environment

Per-product variables win over the shared `ARTCRAFT_*` form, so one
`ARTCRAFT_DEST` can redirect all three while a single product still overrides
it.

| Variable          | Default                                                            |
| ----------------- | ------------------------------------------------------------------ |
| `$<PRODUCT>_SRC`  | see "Source resolution"                                            |
| `$<PRODUCT>_DEST` | `$ARTCRAFT_DEST`, else `$HOME/.local/bin`                          |
| `$<PRODUCT>_URL`  | `$ARTCRAFT_URL`, else `https://github.com/storytold/<product>.git` |
| `$ARTCRAFT_DEST`  | `$HOME/.local/bin`                                                 |
| `$ARTCRAFT_URL`   | per-product GitHub URL                                             |

`<PRODUCT>` is the product name uppercased: `PDFCRAFT_SRC`, `GRIDCRAFT_DEST`,
`WORDCRAFT_URL`.

## Source resolution

In precedence order:

1. `-s DIR`
2. `$<PRODUCT>_SRC`
3. the script's own directory — but **only** when that is sensible: either a
   git checkout whose `origin` URL mentions the product, or a bare directory
   holding nothing but this script and its spec
4. `$HOME/<product>`

Rule 3 is what makes the from-scratch flow work while keeping the script safe
to live in `~/dotfiles/install`. Because the dotfiles repo's origin does not
mention any product, a normal run falls through to rule 4.

## Jobs

Run in this order regardless of the order listed; a FAIL stops the run.

| Job        | Action                                                                                     |
| ---------- | ------------------------------------------------------------------------------------------ |
| `check`    | ask the remote what tags/branches exist — read-only, runs even in dry mode, needs no clone |
| `clone`    | create the checkout if absent (`git init` + `git remote add`)                              |
| `fetch`    | `git fetch --all --prune --tags`                                                           |
| `checkout` | detach at the target ref; refuses on a dirty tree                                          |
| `models`   | `cargo xtask models` → `assets/models/` (pdfcraft only)                                    |
| `build`    | `cargo build --release -p <product> -p <product>-cli`                                      |
| `install`  | back up each `$DEST/<bin>` as `<bin>-<oldver>.bak`, copy the new ones in                   |
| `verify`   | run the installed `<product>-cli --version`                                                |

Each is independently runnable: `install` uses whatever is already in
`target/release`, `verify` only reads the installed binary.

`clone` uses `git init` + `git remote add` rather than `git clone` because the
target directory often already holds this script, and `git clone` refuses to
write into a non-empty directory.

## Dry run / execute

Dry run is the default and prints the exact `cd DIR && argv` of every command.
Both modes route through one `step` choke point, so the preview cannot drift
from what executes. `-e` opts in to running.

Two things deliberately still happen in dry run: the `check` job (read-only)
and the running-GUI detection, which downgrades to a WARN so a preview still
shows every remaining command.

## Failure policy

Fail-soft with three states. Each job records OK / WARN / FAIL and the run ends
with an aligned summary and an `N OK, M WARN, K FAIL` footer. WARN is surfaced
but never affects the exit code.

| Exit | Meaning                         |
| ---- | ------------------------------- |
| `0`  | success, or `-h` / no arguments |
| `1`  | a job FAILed                    |
| `2`  | usage or validation error       |

WARN cases include: the remote unreachable, a newer upstream tag than the one
installed, a ref not yet in the local clone, model fetch failure, `models` on a
product that has none, `-n` skipping the install, and the GUI running during a
preview.

Guards before anything destructive: a dirty working tree blocks `checkout`; a
non-empty non-checkout directory blocks `clone`; a glibc requirement higher
than the host provides blocks `install`; a running GUI blocks a real `install`.

## Forensics

On `-e`, logs go to `/tmp/artcraft.<product>.<timestamp>.forensics/`
with per-job log names, plus `invocation.txt` (the full original argv) and
`summary.txt`. The product name is in the directory so concurrent refreshes of
two apps cannot collide.

## Examples

```bash
artcraft.sh gridcraft              # preview a refresh to the newest release tag
artcraft.sh gridcraft -e           # do it
artcraft.sh wordcraft -j check     # just ask the remote what is available
artcraft.sh pdfcraft -e -j install verify   # install an already-built target/release
artcraft.sh wordcraft -e -j build  # rebuild in place, install nothing
artcraft.sh gridcraft -e --main    # build the development tip
artcraft.sh pdfcraft -e -r v0.8.0  # pin to a tag
artcraft.sh wordcraft -e -n        # rebuild but don't touch ~/.local/bin

# all three to a scratch dir
ARTCRAFT_DEST=/tmp/bin artcraft.sh gridcraft -e

# from scratch
mkdir -p ~/gc && cp artcraft.sh ~/gc/ && ~/gc/artcraft.sh gridcraft -e
```
