# `fmt.sh` — CLI mirror of Neovim `<leader>cf`

Format source files from the command line using the **exact same tools and
flags** as the editor's `conform.nvim` setup, so a file formatted in the shell
is byte-identical to one formatted with `<leader>cf` in Neovim.

## Location & `$PATH` wiring

- Script: `~/dotfiles/utils/fmt.sh` (spec: this file).
- It's sourced/managed like the rest of `~/dotfiles/utils/`. To call it as
  `fmt` from anywhere, either add a symlink on your `PATH`:
  ```bash
  ln -s ~/dotfiles/utils/fmt.sh ~/.local/bin/fmt
  ```
  or an alias in `~/dotfiles/bash_aliases.sh`:
  ```bash
  alias fmt='~/dotfiles/utils/fmt.sh'
  ```

## What it is

`conform.nvim` (see `~/dotfiles/nvim.pack/lua/plugins/formatting.lua` and the
`nvim.easy` twin) dispatches per **filetype**, so `fmt.sh` does the same in two
stages — exactly like vim:

1. **`extension | filename → filetype`** — from nvim builtins plus your custom
   rules in `~/dotfiles/nvim.pack/after/ftdetect/filetype.lua`
   (arrays `EXT2FT` / `FILE2FT`). Whole-filename matches (e.g. `bashrc`) win over
   extension, so extensionless files are handled too.
2. **`filetype → formatter`** — conform's `formatters_by_ft` (array `FT2FMT`).

A filetype with no formatter (`csh`, `markdown`, `tdf`, `f`, `scat`, `trace32`,
`map`, `jira`) is skipped just like in the editor. Run `fmt.sh -l` to print the
full `ext|filename → filetype → formatter` chain. Keep the arrays in sync with
Neovim if either side changes.

## Synopsis

```
fmt.sh [options] <path> [path ...]
```

Positional `path`s may be files or directories. Directories are recursed
(`.git` pruned) and only files with a known extension are picked up.

## Arguments

| Option          | Meaning                                                                 |
| --------------- | ----------------------------------------------------------------------- |
| `-e, --execute` | Actually format. **Default is dry-run** (print the exact per-file cmd).  |
| `-l, --list`    | Print the `extension -> formatter` table and exit.                      |
| `-h, --help`    | Show help (also shown with no args).                                    |
| `--`            | End of options; treat the rest as paths.                                |

## Formatter map (`ext|filename → filetype → formatter`)

| Extensions / filenames              | Filetype   | Formatter                | Invocation (execute)                                            |
| ----------------------------------- | ---------- | ------------------------ | -------------------------------------------------------------- |
| `.sv .svh .svp .v .vh .vp`          | `sv`       | `verible-verilog-format` | house indent/align flags + `--inplace`                        |
| `.c .h`                             | `c`        | `clang-format`           | `--style=file:~/dotfiles/formatters/clang-format -i`          |
| `.cc .cpp .cxx .hpp .hh`            | `cpp`      | `clang-format`           | `--style=file:~/dotfiles/formatters/clang-format -i`          |
| `.py`                               | `python`   | `black`                  | `--config ~/dotfiles/formatters/py-format.toml --quiet <file>`|
| `.lua`                              | `lua`      | `stylua`                 | `stylua <file>`                                               |
| `.json`                             | `json`     | `prettier`               | `prettier --write <file>`                                    |
| `.sh`, `bashrc`, `bash_profile`     | `sh`       | `shfmt`                  | `shfmt -i 3 -ci -bn -sr -w <file>`                            |
| `.bash`                             | `bash`     | `shfmt`                  | `shfmt -i 3 -ci -bn -sr -w <file>`                            |
| `.zsh`                              | `zsh`      | `shfmt`                  | `shfmt -ln zsh -i 3 -ci -bn -sr -w <file>`                    |
| `.tcl .qel .fs`                     | `tcl`      | `tclfmt`                 | `tclfmt - < file > tmp && mv` (stdin→stdout filter)          |
| `.csr`                              | `semifore` | `semifore.py`            | `semifore.py < file > tmp && mv` (stdin→stdout filter)       |

Filetypes with **no formatter** (skipped, WARN): `csh` (`cshrc`, `shellrc`,
`.shellrc`), `markdown` (`.mdc`), `tdf`, `f`, `scat`, `trace32` (`.cmm`),
`map`, `jira`.

The verible flags are NOT hardcoded here: both `fmt.sh` and nvim `conform.nvim`
pass `--flagfile=~/dotfiles/formatters/verible-format.flagfile`, the single
source of truth (3-space indent, aligned port decls + named ports, 120-column
limit to match AscentLint `LINE_LENGTH`). Edit that flagfile to change either.

## Dry-run vs execute

- **Dry-run (default):** prints, per file, the *exact* shell-quoted command that
  would run (routed through the `step`/`stepf` choke points, so print == exec).
  Nothing is modified.
- **`-e/--execute`:** runs each command, edits files in place, and writes
  per-file logs + a `summary.txt` under
  `/tmp/fmt.sh.<timestamp>.forensics/`.

## Failure policy (fail-soft, three-state)

One file never aborts the run. Each file is recorded as:

- **OK** — formatted (or would be, in dry-run).
- **WARN** — skipped for an *environmental* reason: unknown extension, or the
  formatter tool isn't installed / on `PATH`. Non-fatal (excluded from exit).
- **FAIL** — the formatter ran and returned non-zero.

Exit codes: `0` all-good (WARNs allowed), `2` usage/validation error (`die`),
`1` nothing to format, non-zero if any file **FAILed**.

## Direct one-liners (no wrapper)

Handy equivalents if you just want one file:

```bash
# SystemVerilog (same as <leader>cf on a .sv buffer)
verible-verilog-format --flagfile=~/dotfiles/formatters/verible-format.flagfile \
  --inplace file.sv

# C / C++
clang-format --style=file:~/dotfiles/formatters/clang-format -i file.c

# Python
black --config ~/dotfiles/formatters/py-format.toml --quiet file.py

# Shell
shfmt -i 3 -ci -bn -sr -w file.sh
```

## Examples

```bash
fmt.sh src/                 # dry-run: everything formattable under src/
fmt.sh -e src/ tb/x.sv      # execute across a dir + a file
fmt.sh -l                   # print the extension -> formatter table
fmt.sh -e .                 # format the whole tree from cwd
```

## Keep in sync

If you change `formatters` / `formatters_by_ft` in the Neovim conform config, or
add rules in `after/ftdetect/filetype.lua`, update the matching arrays in
`fmt.sh` (`EXT2FT` / `FILE2FT` for stage 1, `FT2FMT` / `FMT2BIN` for stage 2)
and the tables above so `fmt.sh` stays a faithful mirror of `<leader>cf`.
