# snippets

Personal code snippets, kept in **VS Code snippet JSON** format so a single
source of truth can feed both Neovim flavors (and any editor that speaks the
VS Code format).

```
snippets/
├── README.md
└── vscode_snippets/
    ├── package.json     # manifest: maps each language -> its <ft>.json
    ├── all.json         # global snippets (offered in every filetype)
    ├── c.json           # per-filetype snippet files
    ├── python.json
    ├── sv.json
    ├── ...              # one <ft>.json per language
    └── json.json        # includes a `snippet` generator to scaffold new entries
```

## How it's wired into Neovim

Both configs consume these files through **blink.cmp's built-in `snippets`
source** (a port of `garymjr/nvim-snippets`; no separate plugin is installed).
The wiring lives in the completions config of each flavor:

- `nvim.pack/lua/plugins/completions.lua`
- `nvim.easy/lua/code_plugins/completions.lua`

The relevant knobs (identical in both):

```lua
snippets = {
   opts = {
      friendly_snippets = false,                                       -- skip the giant upstream corpus
      global_snippets   = { 'all' },                                   -- all.json -> every filetype
      search_paths      = { vim.fn.expand('~/dotfiles/snippets/vscode_snippets') },
   },
}
```

- **Discovery:** for a buffer of filetype `<ft>`, the source loads `<ft>.json`
  (resolved via `package.json`'s `contributes.snippets` map) plus `all.json`.
- **Expansion:** handled by Neovim's built-in `vim.snippet` engine
  (blink.cmp `snippets = { preset = 'default' }`), so `$1`/`${1:...}` tabstops,
  `${1|a,b|}` choices, and `$TM_*` / `$CURRENT_*` variables all work.

## File format & conventions

Each `<ft>.json` is an object of `"name": { … }` entries. All files are kept in
one canonical shape (see any existing file):

```json
{
   "if": {
      "prefix": ["if"],
      "body": [
         "if (${1:condition}) {",
         "   $0",
         "}"
      ],
      "description": "if block"
   }
}
```

- `prefix` — **always an array** (even for a single trigger); list multiple
  triggers as `["if-else", "ife"]`.
- `body` — **always an array**, one line per element, indented with **3 spaces**
  (no tabs).
- `description` — a short, non-empty string.
- Field order is `prefix → body → description`; indent the JSON with 3 spaces.

Handy snippet variables: `$TM_FILENAME_BASE`, `$CURRENT_YEAR`,
`$CURRENT_MONTH`, `$CURRENT_DATE`.

## Adding snippets

- **New snippet for an existing language:** add an entry to that `<ft>.json`.
  In a `json` buffer, type `snippet<Tab>` (from `json.json`) to scaffold one in
  the canonical shape.
- **New language:** create `vscode_snippets/<ft>.json` **and** register it in
  `package.json` under `contributes.snippets` (`{ "language": "<ft>", "path":
  "./<ft>.json" }`). Use the same filetype name Neovim reports (`:set ft?`).
- `all.json` holds snippets you want available in every filetype (wired via
  `global_snippets`).
