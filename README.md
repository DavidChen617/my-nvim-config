# nvim config

Personal Neovim config focused on C#/.NET, with C, SQL, and general scripting
support. Managed with [lazy.nvim](https://github.com/folke/lazy.nvim).

## Structure

```
init.lua                        entry point: options, keymaps, lazy.nvim bootstrap, colorscheme tweaks
lua/options.lua                 vim.opt settings
lua/keymaps.lua                 keymaps not tied to a specific plugin
lua/platform.lua                OS detection (is_mac / is_linux), computed once via require() caching
lua/plugins.lua                 lazy.nvim plugin spec (everything else lives here)
after/queries/c_sharp/folds.scm custom treesitter fold query for C#
```

## Requirements

- Neovim >= 0.12 (nvim-treesitter's `main` branch requires it)
- `git`, a C compiler (for building some parsers/tools)
- [`tree-sitter` CLI](https://github.com/tree-sitter/tree-sitter) —
  `brew install tree-sitter-cli` on macOS. nvim-treesitter's `main` branch
  shells out to this to compile parsers; without it, `:TSUpdate`/parser
  install fails with `ENOENT: no such file or directory (cmd): 'tree-sitter'`.
- .NET SDK + `csharpier` installed as a **global** dotnet tool
  (`dotnet tool install -g csharpier`) for C# formatting on save.
- `dotnet-vscode-css` not needed; C# LSP is via `roslyn.nvim` (Mason-managed,
  pulled from a community registry — see comment in `plugins.lua`).

### C# debugging (netcoredbg) — manual step on macOS

Mason's `netcoredbg` package has no native macOS arm64 build (x86_64 only,
which fails to attach to native arm64 .NET processes under Rosetta with
`Failed command 'configurationDone': 0x80070005`). On Linux, Mason's build
works fine and is installed automatically.

On macOS, download the official arm64 build manually:

```bash
curl -fL -o netcoredbg.zip \
  https://github.com/Samsung/netcoredbg/releases/latest/download/netcoredbg-osx-arm64.zip
unzip netcoredbg.zip -d ~/.local/share/nvim/netcoredbg-osx-arm64
```

`lua/plugins.lua` (the `nvim-dap` block) picks the right path automatically
via `lua/platform.lua`.

## Key bindings

Leader is `<Space>`. Highlights (see `lua/keymaps.lua` and `lua/plugins.lua`
for the full list):

| Key | Action |
|---|---|
| `<leader>e` | Toggle file explorer (neo-tree) |
| `<leader>sf` / `sg` / `sb` / `sd` | Telescope: find files / grep / buffers / diagnostics |
| `gd` / `gr` / `gi` / `K` | LSP: definition / references / implementation / hover |
| `<leader>rn` / `<leader>ca` | LSP: rename / code action |
| `<leader>f` | Format buffer (conform.nvim) |
| `<F5>` / `<F9>` / `<F6>`/`<F7>`/`<F8>` / `<S-F5>` | Debug: continue / toggle breakpoint / step over/into/out / terminate |
| `<leader>du` | Toggle debug UI (dapui) |

## TODO

- Enable LSP inlay hints (`vim.lsp.inlay_hint.enable()`) — shows inferred
  types/param names inline, works well with roslyn.nvim for C#.
- Consider `trouble.nvim` for a nicer diagnostics/quickfix/references list
  UI instead of the default quickfix window.
- Consider `snacks.nvim` (folke) — bundles dashboard, zen mode, a floating
  lazygit terminal, picker, notify, etc.; community is consolidating a lot
  of single-purpose plugins into it.
- Watch `vim.pack` (native package manager, Nvim 0.12+) as a possible
  replacement for lazy.nvim — not urgent, just worth tracking.

## Known limitations

- `netcoredbg` has no Source Link / symbol server support — stepping into
  BCL/framework code (e.g. `String.Concat`) isn't possible, only user code.
- Windows isn't handled in `lua/platform.lua` yet (only macOS/Linux) since
  it isn't currently needed.
