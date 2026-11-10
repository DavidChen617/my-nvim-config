-- blink.cmp keymap entries for scrolling the completion-item doc window.
-- blink.cmp doesn't expose a command for scrolling the signature help
-- (overload) window, so scroll that one directly when it's open, falling
-- back to the doc window otherwise.
local scroll_down = {
  function()
    if require('blink.cmp').is_signature_visible() then
      require('blink.cmp.signature.window').scroll_down(4)
      return true
    end
  end,
  'scroll_documentation_down',
  'fallback',
}
local scroll_up = {
  function()
    if require('blink.cmp').is_signature_visible() then
      require('blink.cmp.signature.window').scroll_up(4)
      return true
    end
  end,
  'scroll_documentation_up',
  'fallback',
}

return {
  -- Statusline
  { 'nvim-lualine/lualine.nvim', opts = {} },

  -- Always-visible buffer tabs at the top of the screen
  {
    'akinsho/bufferline.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    event = 'VeryLazy',
    opts = {
      options = {
        mode = 'buffers',
        numbers = 'none',
        close_command = 'bdelete! %d',
        path_components = 1, -- show file name only, not the full path
        modified_icon = '●',
        always_show_bufferline = true,
        diagnostics = 'nvim_lsp', -- show LSP error/warning counts on each tab
        separator_style = 'thin',
      },
      -- Colors pulled from the Rider Islands Dark palette (see init.lua's
      -- set_rider_islands_dark_syntax) so the tab bar matches the rest of
      -- the syntax colors instead of a generic default.
      highlights = {
        buffer_selected = { fg = '#BDBDBD', bold = true },
        buffer_visible = { fg = '#6C7280' },
        background = { fg = '#4B4B4B' },
        indicator_selected = { fg = '#6C95EB' },
        modified = { fg = '#ED94C0' },
        modified_selected = { fg = '#ED94C0' },
        separator = { fg = '#333333' },
        separator_selected = { fg = '#333333' },
        error_diagnostic = { fg = '#ED94C0' },
        warning_diagnostic = { fg = '#C9A26D' },
      },
    },
  },

  -- Git signs in the sign column
  {
    'lewis6991/gitsigns.nvim',
    opts = {
      current_line_blame = true, -- on by default; <leader>tb toggles
      -- Same switches as the :Gitsigns toggle_* commands, on by default.
      signcolumn = true, -- toggle_signs
      numhl = true, -- toggle_numhl
      linehl = true, -- toggle_linehl
      word_diff = true, -- toggle_word_diff
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
        end

        map('n', ']c', gs.next_hunk, 'Next hunk')
        map('n', '[c', gs.prev_hunk, 'Prev hunk')
        map('n', '<leader>hs', gs.stage_hunk, 'Stage hunk')
        map('n', '<leader>hr', gs.reset_hunk, 'Reset hunk')
        map('n', '<leader>hp', gs.preview_hunk, 'Preview hunk')
        map('n', '<leader>hb', function() gs.blame_line { full = true } end, 'Blame line')
        map('n', '<leader>tb', gs.toggle_current_line_blame, 'Toggle line blame')
      end,
    },
  },

  -- Shows pending keybinds
  { 'folke/which-key.nvim', event = 'VeryLazy', opts = {} },

  -- Auto-detect indentation (tabstop/shiftwidth) per file
  { 'tpope/vim-sleuth' },

  -- Auto-close brackets/quotes
  { 'windwp/nvim-autopairs', event = 'InsertEnter', opts = {} },

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim' },
    cmd = 'Telescope',
    opts = {
      defaults = {
        -- Stack preview on top of results/prompt instead of side by side.
        layout_strategy = 'vertical',
        -- preview_cutoff defaults to 40 lines; below that the preview is hidden.
        layout_config = { vertical = { preview_height = 0.5, preview_cutoff = 1 } },
        -- Scroll the preview pane with Shift+arrows (Ctrl+arrows
        -- are grabbed by macOS; <C-r> is needed for pasting registers).
        mappings = {
          i = {
            ['<S-Down>'] = 'preview_scrolling_down',
            ['<S-Up>'] = 'preview_scrolling_up',
            ['<S-Left>'] = 'preview_scrolling_left',
            ['<S-Right>'] = 'preview_scrolling_right',
            -- Telescope's defaults for the same job; unbind so there's one way.
            ['<C-d>'] = false,
            ['<C-u>'] = false,
            ['<C-f>'] = false,
            ['<C-k>'] = false,
          },
          n = {
            ['<S-Down>'] = 'preview_scrolling_down',
            ['<S-Up>'] = 'preview_scrolling_up',
            ['<S-Left>'] = 'preview_scrolling_left',
            ['<S-Right>'] = 'preview_scrolling_right',
            -- Telescope's defaults for the same job; unbind so there's one way.
            ['<C-d>'] = false,
            ['<C-u>'] = false,
            ['<C-f>'] = false,
            ['<C-k>'] = false,
          },
        },
      },
    },
    keys = {
      { '<leader>sf', '<cmd>Telescope find_files<CR>', desc = 'Search Files' },
      { '<leader>sg', '<cmd>Telescope live_grep<CR>', desc = 'Search by Grep' },
      { '<leader>sb', '<cmd>Telescope buffers<CR>', desc = 'Search Buffers' },
      { '<leader>sh', '<cmd>Telescope help_tags<CR>', desc = 'Search Help' },
      { '<leader>sd', '<cmd>Telescope diagnostics<CR>', desc = 'Search Diagnostics' },
      { '<leader>sk', '<cmd>Telescope keymaps<CR>', desc = 'Search Keymaps' },
      { '<leader>sm', '<cmd>Telescope man_pages<CR>', desc = 'Search Man pages' },
    },
  },

  -- File explorer
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
      's1n7ax/nvim-window-picker', -- required for neo-tree's `w` (open with window picker)
    },
    keys = {
      { '<leader>e', '<cmd>Neotree toggle<CR>', desc = 'Toggle file explorer' },
    },
    opts = {
      -- neo-tree hardcodes number/relativenumber = false on its window (no config
      -- option), so turn them back on whenever its buffer is entered.
      event_handlers = {
        {
          event = 'neo_tree_buffer_enter',
          handler = function()
            vim.opt_local.number = true
            vim.opt_local.relativenumber = true
          end,
        },
      },
      filesystem = {
        -- show dotfiles / gitignored items by default (dimmed); `H` still toggles
        filtered_items = { visible = true },
        follow_current_file = { enabled = true },
        hijack_netrw_behavior = 'open_current',
      },
    },
  },

  -- Treesitter: better syntax highlighting / indent.
  -- On the (now-archived) master branch, `master`'s query_predicates hits
  -- a nil-node crash against Neovim 0.12's changed treesitter API
  -- (attempt to call method 'range' (a nil value) — see
  -- https://github.com/nvim-treesitter/nvim-treesitter/issues/8618).
  -- master won't get a fix (announced archived), so this is on `main`,
  -- the actively maintained rewrite, which needs Neovim >= 0.12 and a
  -- different setup API (no more nvim-treesitter.configs / highlight.enable).
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main',
    lazy = false,
    build = ':TSUpdate',
    config = function()
      local parsers = {
        'c',
        'c_sharp',
        'razor',
        'html',
        'css',
        'bash',
        'yaml',
        'json',
        'javascript',
        'typescript',
        'markdown',
        'markdown_inline',
        'sql',
        'lua',
        'vim',
        'vimdoc',
        'dockerfile',
        'terraform',
        'hcl',
        'make',
        'go',
        'gomod',
        'gosum',
        'gowork',
        'nginx',
        'xml',
      }
      local filetypes = {
        'c',
        'cs',
        'razor',
        'html',
        'css',
        'sh',
        'bash',
        'yaml',
        'json',
        'jsonc',
        'javascript',
        'javascriptreact',
        'typescript',
        'typescriptreact',
        'markdown',
        'sql',
        'lua',
        'vim',
        'help',
        'dockerfile',
        'terraform',
        'terraform-vars',
        'hcl',
        'make',
        'go',
        'gomod',
        'gosum',
        'gowork',
        'nginx',
        'msbuild',
      }

      require('nvim-treesitter').setup {
        install_dir = vim.fn.stdpath 'data' .. '/site',
      }
      require('nvim-treesitter').install(parsers)

      -- c_sharp's grammar ships no indents.scm, so treesitter's indentexpr
      -- can't compute anything for it (new lines land at column 1). Keep
      -- treesitter highlighting for 'cs' but leave indentation to Neovim's
      -- built-in indent/cs.vim (cindent-based, actually works).
      local no_treesitter_indent = { cs = true }

      vim.api.nvim_create_autocmd('FileType', {
        pattern = filetypes,
        callback = function(ev)
          vim.treesitter.start()
          if not no_treesitter_indent[ev.match] then
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },

  -- Render Markdown in-buffer (headings, bold/italic, lists, code blocks, etc.)
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' },
    ft = { 'markdown' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },

  -- Preview Markdown (incl. Mermaid diagrams), synced live. iterm-preview.nvim
  -- intercepts markdown-preview.nvim's browser handoff and renders it in an
  -- iTerm2 split instead of an external browser tab.
  --
  -- One-time manual setup required: iTerm2 > Settings > Profiles > + a new
  -- profile with "General > Command" set to a URL/Browser profile, initial
  -- URL `file:///tmp/iterm-preview.html`. Without that profile this silently
  -- does nothing.
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
  },
  {
    'Kepler2024/iTerm-preview.nvim',
    dependencies = { 'iamcco/markdown-preview.nvim' },
    ft = { 'markdown', 'html' },
    opts = {},
  },

  -- GitHub Copilot: inline ghost-text suggestions, separate from blink.cmp's
  -- LSP/snippet/buffer completion menu.
  --
  -- Accept is <C-y>, not the default <M-l>: macOS terminals don't send
  -- Option as a Meta/Alt modifier by default (Option+L types a literal
  -- character, e.g. ¬ on a US layout), so <M-...> keymaps silently never
  -- fire unless the terminal app is reconfigured to send Option as Esc+.
  -- A Ctrl combo sidesteps that entirely.
  {
    'zbirenbaum/copilot.lua',
    cmd = 'Copilot',
    event = 'InsertEnter',
    opts = {
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = '<C-y>',
          next = '<C-n>',
          prev = '<C-p>',
        },
      },
    },
  },

  -- Syntax-highlighted completion labels (e.g. function signatures keep
  -- their normal token colors instead of being one flat color) for blink.cmp
  { 'xzbdmw/colorful-menu.nvim', opts = {} },

  -- Completion engine
  {
    'saghen/blink.cmp',
    version = '*',
    dependencies = { 'rafamadriz/friendly-snippets', 'xzbdmw/colorful-menu.nvim' },
    opts = {
      keymap = {
        preset = 'enter',
        -- Shift+Up/Down scroll the doc/signature window; these
        -- replace the preset's <C-f>/<C-b>, so unbind those.
        ['<C-f>'] = false,
        ['<C-b>'] = false,
        ['<S-Down>'] = scroll_down,
        ['<S-Up>'] = scroll_up,
      },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        documentation = { auto_show = true },
        menu = {
          draw = {
            columns = { { 'kind_icon' }, { 'label', gap = 1 } },
            components = {
              label = {
                text = function(ctx)
                  return require('colorful-menu').blink_components_text(ctx)
                end,
                highlight = function(ctx)
                  return require('colorful-menu').blink_components_highlight(ctx)
                end,
              },
            },
          },
        },
      },
      sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
      signature = { enabled = true },
    },
    opts_extend = { 'sources.default' },
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    dependencies = {
      {
        'mason-org/mason.nvim',
        opts = {
          -- roslyn isn't in the official Mason registry yet; it's only
          -- published on this community registry maintained by roslyn.nvim's author.
          registries = {
            'github:mason-org/mason-registry',
            'github:Crashdummyy/mason-registry',
          },
        },
      },
      'mason-org/mason-lspconfig.nvim',
      'saghen/blink.cmp',
      'b0o/schemastore.nvim', -- JSON/YAML schemas for yamlls/jsonls (e.g. k8s manifests, docker-compose)
    },
    config = function()
      -- Give every LSP server the extra capabilities blink.cmp provides
      -- didChangeWatchedFiles is turned off for every client: Neovim's
      -- built-in watcher opens one fd per watched directory and hits EMFILE
      -- on huge repos (e.g. aspnetcore). Trade-off: servers won't notice
      -- external changes (git checkout, etc.) until restarted. roslyn does
      -- its own watching (filewatching = 'roslyn' below), so C# is unaffected.
      vim.lsp.config('*', {
        capabilities = vim.tbl_deep_extend('force', require('blink.cmp').get_lsp_capabilities(), {
          workspace = { didChangeWatchedFiles = { dynamicRegistration = false } },
        }),
      })

      -- Servers we want installed + enabled.
      -- Empty {} means "use nvim-lspconfig's defaults, no overrides".
      local servers = {
        clangd = {}, -- C
        bashls = {}, -- sh
        -- schemaStore.enable = false + url = '' turns off yaml-language-server's
        -- own schema-store fetching so schemastore.nvim's list (kept up to date
        -- via its own releases) is the only source, not both at once.
        yamlls = {
          settings = {
            yaml = {
              schemaStore = { enable = false, url = '' },
              schemas = require('schemastore').yaml.schemas(),
            },
          },
        },
        ts_ls = {}, -- JS/TS
        -- Angular template/component support (attaches alongside ts_ls in
        -- Angular projects; only activates where angular.json/nx.json is
        -- found, and needs `ngserver` installed via mason).
        angularls = {},
        sqlls = {}, -- SQL / PostgreSQL
        marksman = {}, -- Markdown
        dockerls = {}, -- Dockerfile
        jsonls = {}, -- JSON (e.g. appsettings.json)
        terraformls = {}, -- Terraform / HCL
        -- Neovim's builtin filetype detection tags Angular component
        -- templates as `htmlangular` (not `html`), so the default
        -- filetypes list never matches those buffers without this override.
        html = { filetypes = { 'html', 'htmlangular' } }, -- HTML
        cssls = {}, -- CSS
        nginx_language_server = {}, -- nginx.conf
        gopls = { -- Go
          settings = {
            gopls = {
              staticcheck = true,
              gofumpt = true,
            },
          },
        },
        -- Spell-check for code (knows camelCase/snake_case); known-typo list,
        -- so far fewer false positives than vim's built-in 'spell'.
        typos_lsp = {},
        lua_ls = {
          settings = {
            Lua = {
              runtime = { version = 'LuaJIT' },
              diagnostics = { globals = { 'vim' } },
              workspace = {
                library = { vim.env.VIMRUNTIME },
                checkThirdParty = false,
              },
            },
          },
        },
      }

      for name, cfg in pairs(servers) do
        vim.lsp.config(name, cfg)
      end

      require('mason-lspconfig').setup {
        ensure_installed = vim.tbl_keys(servers),
        -- omnisharp is left over from the old config; C# is handled by
        -- roslyn.nvim instead, so don't let mason-lspconfig auto-enable it.
        automatic_enable = { exclude = { 'omnisharp' } },
      }

      -- MSBuild project files (*.csproj, *.props, *.targets): tintoy's server isn't
      -- in the Mason registry, so it's an unzipped release (language-server.zip from
      -- https://github.com/tintoy/msbuild-project-tools-server/releases) under
      -- stdpath('data'). Skipped when absent so other machines still start cleanly.
      -- The server picks its MSBuild from `dotnet --version` in its cwd and doesn't
      -- know .NET 11 previews ("Cannot locate MSBuild engine for .NET SDK v11..."),
      -- so it runs from its own dir, which holds a global.json pinning SDK 9.0.x.
      -- SDK 9, not 10: the server bundles NuGet.Frameworks 6.14, and SDK 10's
      -- MSBuild references 7.9 -> MSB4184 "Could not load ... NuGet.Frameworks".
      local msbuild_dir = vim.fn.stdpath 'data' .. '/msbuild-project-tools-server'
      local msbuild_dll = msbuild_dir .. '/MSBuildProjectTools.LanguageServer.Host.dll'
      if vim.uv.fs_stat(msbuild_dll) then
        vim.lsp.config('msbuild_project_tools_server', { cmd = { 'dotnet', msbuild_dll }, cmd_cwd = msbuild_dir })
        vim.lsp.enable 'msbuild_project_tools_server'
      end

      -- Keymaps that only apply in a buffer once an LSP has attached to it
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
          local map = function(keys, fn, desc)
            vim.keymap.set('n', keys, fn, { buffer = ev.buf, desc = 'LSP: ' .. desc })
          end
          map('gd', function()
            -- On a `cs` buffer, roslyn sometimes fails to auto-attach (e.g.
            -- a file outside the resolved solution/target). When that
            -- happens the only client left attached is one that doesn't
            -- support go-to-definition (e.g. copilot), and telescope's
            -- picker just fails with "server does not support
            -- textDocument/definition" with no hint about why.
            if
              vim.bo[ev.buf].filetype == 'cs'
              and #vim.lsp.get_clients { bufnr = ev.buf, method = 'textDocument/definition' } == 0
            then
              vim.notify(
                'No attached LSP client supports go-to-definition here.\nRun :Roslyn target to pick the solution for this buffer.',
                vim.log.levels.WARN,
                { title = 'roslyn.nvim' }
              )
              return
            end
            require('telescope.builtin').lsp_definitions()
          end, 'Goto Definition')
          map('gr', require('telescope.builtin').lsp_references, 'Goto References')
          map('gi', require('telescope.builtin').lsp_implementations, 'Goto Implementation')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('<leader>rn', vim.lsp.buf.rename, 'Rename')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
          map('<leader>ih', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = ev.buf }, { bufnr = ev.buf })
          end, 'Toggle Inlay Hints')

          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client.name == 'gopls' then
            -- gopls formats via conform's lsp fallback, but doesn't fix
            -- imports on its own; ask for organizeImports first (runs before
            -- conform's own BufWritePre save hook, which is registered later).
            -- https://go.dev/gopls/editor/vim
            vim.api.nvim_create_autocmd('BufWritePre', {
              desc = 'gopls: organize imports on save',
              buffer = ev.buf,
              callback = function()
                local params = vim.lsp.util.make_range_params(0, client.offset_encoding)
                params.context = { only = { 'source.organizeImports' } }
                local res = client:request_sync('textDocument/codeAction', params, 1000, ev.buf)
                for _, action in pairs(res and res.result or {}) do
                  if action.edit then
                    vim.lsp.util.apply_workspace_edit(action.edit, client.offset_encoding)
                  end
                end
              end,
            })
          end
          if client and client:supports_method('textDocument/codeLens', ev.buf) then
            vim.lsp.codelens.enable(true, { bufnr = ev.buf })
          end
          if client and client.name == 'roslyn' then
            map('<leader>rt', '<cmd>Roslyn target<cr>', 'Select Roslyn Target')

            -- Roslyn's diagnostics are pull-based and, per the roslyn.nvim
            -- author, "a bit of a hack" that doesn't always refresh on its
            -- own (https://github.com/seblyng/roslyn.nvim/wiki). Without
            -- this, diagnostics look stale until something forces a pull —
            -- e.g. `:Roslyn target`, which actually restarts the whole LSP
            -- client. Pull explicitly on save / leaving insert mode (same
            -- events nvim-lspconfig's roslyn_ls uses) rather than on every
            -- BufEnter, which forced a full recompute on each buffer switch.
            vim.api.nvim_create_autocmd({ 'BufWritePost', 'InsertLeave' }, {
              desc = 'Roslyn: pull fresh diagnostics for this buffer.',
              buffer = ev.buf,
              callback = function()
                client:request('textDocument/diagnostic', {
                  textDocument = vim.lsp.util.make_text_document_params(ev.buf),
                }, nil, ev.buf)
              end,
            })

            -- Typing `///` above a member normally expands into an XML doc
            -- comment (<summary>, <param>, ...) in Visual Studio / VS Code.
            -- Neovim's LSP client has no built-in support for this, so wire
            -- up Roslyn's non-standard `textDocument/_vs_onAutoInsert`
            -- request by hand, per the roslyn.nvim wiki:
            -- https://github.com/seblyng/roslyn.nvim/wiki
            vim.api.nvim_create_autocmd('InsertCharPre', {
              desc = "Roslyn: trigger XML doc comment auto-insert on '/'.",
              buffer = ev.buf,
              callback = function()
                if vim.v.char ~= '/' then
                  return
                end

                local row, col = unpack(vim.api.nvim_win_get_cursor(0))
                row, col = row - 1, col + 1
                local params = {
                  _vs_textDocument = { uri = vim.uri_from_bufnr(ev.buf) },
                  _vs_position = { line = row, character = col },
                  _vs_ch = '/',
                  _vs_options = {
                    tabSize = vim.bo[ev.buf].tabstop,
                    insertSpaces = vim.bo[ev.buf].expandtab,
                  },
                }

                -- Must be sent after the `/` has actually landed in the buffer.
                vim.defer_fn(function()
                  client:request('textDocument/_vs_onAutoInsert', params, function(err, result)
                    if err or not result then
                      return
                    end
                    vim.snippet.expand(result._vs_textEdit.newText)
                  end, ev.buf)
                end, 1)
              end,
            })
          end
        end,
      })

      vim.api.nvim_create_user_command('LspInlayHintsInfo', function()
        local bufnr = vim.api.nvim_get_current_buf()
        local clients = vim.lsp.get_clients { bufnr = bufnr }
        local lines = {
          ('inlay hints enabled: %s'):format(vim.lsp.inlay_hint.is_enabled { bufnr = bufnr }),
          ('visible hints cached: %d'):format(#vim.lsp.inlay_hint.get { bufnr = bufnr }),
        }

        for _, client in ipairs(clients) do
          lines[#lines + 1] = ('%s supports inlayHint: %s'):format(
            client.name,
            client:supports_method('textDocument/inlayHint', bufnr)
          )
        end

        vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO, { title = 'LSP Inlay Hints' })
      end, { desc = 'Show inlay hint status for the current buffer' })
    end,
  },

  -- C# / .NET LSP (Roslyn language server, the modern replacement for OmniSharp)
  {
    'seblyng/roslyn.nvim',
    ft = { 'cs', 'razor' },
    -- Server-specific settings (e.g. inlay hints) go through vim.lsp.config,
    -- not the plugin's own `opts` table — RoslynNvimConfig (opts) only
    -- covers filewatching/target-selection, it has no `settings` field.
    --
    -- This MUST run in `init`, not `config`: roslyn.nvim's plugin/roslyn.lua
    -- calls vim.lsp.enable('roslyn') as soon as the plugin is loaded, which
    -- starts the client using whatever vim.lsp.config('roslyn', ...) holds
    -- at that moment. lazy.nvim sources plugin/ files (and thus fires that
    -- vim.lsp.enable call) before running `config`, so settings set there
    -- arrive too late — the client already started without them. `init`
    -- runs before the plugin itself is loaded, so it's early enough.
    init = function()
      vim.lsp.config('roslyn', {
        settings = {
          ['csharp|inlay_hints'] = {
            csharp_enable_inlay_hints_for_types = true,
            csharp_enable_inlay_hints_for_implicit_object_creation = true,
            csharp_enable_inlay_hints_for_implicit_variable_types = true,
            csharp_enable_inlay_hints_for_lambda_parameter_types = true,
            dotnet_enable_inlay_hints_for_parameters = true,
            dotnet_enable_inlay_hints_for_literal_parameters = true,
            dotnet_enable_inlay_hints_for_indexer_parameters = true,
            dotnet_enable_inlay_hints_for_object_creation_parameters = true,
            dotnet_enable_inlay_hints_for_other_parameters = true,
          },
          -- Shows "N references" / "Run Test | Debug Test" above members,
          -- like VS/VS Code. Neovim still has to be told to display it —
          -- see the codelens.enable() call in the LspAttach autocmd below.
          ['csharp|code_lens'] = {
            dotnet_enable_references_code_lens = true,
            dotnet_enable_tests_code_lens = false,
          },
          -- Only analyze open files instead of the whole solution.
          ['csharp|background_analysis'] = {
            dotnet_analyzer_diagnostics_scope = 'openFiles',
            dotnet_compiler_diagnostics_scope = 'openFiles',
          },
        },
        -- roslyn.nvim's own root_dir (lsp/roslyn.lua) only reuses the
        -- current client's root for `roslyn-source-generated://` buffers.
        -- Decompiled `MetadataAsSource` buffers aren't covered, so without
        -- a .sln pinning the target, each one resolves to its own rootless
        -- client and `gd` inside decompiled code fails with "No locations
        -- found". Extend the same reuse check to MetadataAsSource.
        -- Depends on roslyn.nvim's internal `roslyn.target` module, so a
        -- future plugin update could require revisiting this.
        -- https://github.com/seblyng/roslyn.nvim/issues/116
        root_dir = function(bufnr, on_dir)
          if vim.api.nvim_buf_get_name(bufnr):match 'MetadataAsSource' then
            local existing = vim.lsp.get_clients { name = 'roslyn' }[1]
            if existing and existing.config.root_dir then
              on_dir(existing.config.root_dir)
              return
            end
          end

          local target = require 'roslyn.target'
          local decision = target.resolve(bufnr)
          target.notify_if_needed(decision)
          target.remember(decision)
          on_dir(decision.root_dir)
        end,
      })
    end,
    opts = {
      -- Let Roslyn do its own file watching instead of Neovim's, which the
      -- README suggests when you notice performance issues.
      filewatching = 'roslyn',
    },
  },

  -- Formatting on save
  {
    'stevearc/conform.nvim',
    event = { 'BufWritePre' },
    cmd = { 'ConformInfo' },
    keys = {
      {
        '<leader>f',
        function()
          require('conform').format {
            async = true,
            lsp_format = 'fallback',
          }
        end,
        desc = 'Format buffer',
      },
    },
    opts = {
      formatters_by_ft = {
        c = { 'clang-format' },
        lua = { 'stylua' },
        sh = { 'shfmt' },
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        json = { 'prettier' },
        yaml = { 'prettier' },
        markdown = { 'prettier' },
        nginx = { 'nginxfmt' }, -- needs `:MasonInstall nginx-config-formatter`
      },
      -- Forward EditorConfig-derived buffer indentation to clang-format.
      formatters = {
        ['clang-format'] = {
          prepend_args = function(_, ctx)
            local bo = vim.bo[ctx.buf]
            local width = bo.shiftwidth == 0 and bo.tabstop or bo.shiftwidth
            local style = string.format(
              '{BasedOnStyle: LLVM, IndentWidth: %d, TabWidth: %d, UseTab: %s}',
              width,
              bo.tabstop,
              bo.expandtab and 'Never' or 'Always'
            )
            return { '--style=' .. style }
          end,
        },
      },
      -- No formatter registered for 'cs': lsp_format = 'fallback' below makes
      -- conform hand C# off to the buffer's LSP client (roslyn.nvim's Roslyn
      -- Language Server), both for <leader>f and on save.
      format_on_save = {
        timeout_ms = 2000,
        lsp_format = 'fallback',
      },
    },
  },

  -- Interactive machine translation
  {
    'potamides/pantran.nvim',
    cmd = 'Pantran',
    opts = {
      default_engine = 'google',
      engines = {
        google = {
          default_target = 'zh-TW',
          fallback = {
            default_target = 'zh-TW',
          },
        },
      },
    },
  },

  -- Debug Adapter Protocol (C# debugging via netcoredbg)
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      'rcarriga/nvim-dap-ui',
      'nvim-neotest/nvim-nio',
      'jay-babu/mason-nvim-dap.nvim',
    },
    config = function()
      local dap = require 'dap'
      local dapui = require 'dapui'
      local platform = require 'platform'

      -- mason's netcoredbg package has no native macOS arm64 build (only
      -- x86_64, which fails to attach to native arm64 .NET processes under
      -- Rosetta: "Failed command 'configurationDone': 0x80070005"), so on
      -- macOS this is left out here and installed manually instead (see
      -- netcoredbg_path below). Linux has a proper native mason build.
      require('mason-nvim-dap').setup {
        -- This list takes DAP adapter names; coreclr installs the netcoredbg package.
        ensure_installed = platform.is_linux and { 'coreclr', 'delve' } or { 'delve' },
        automatic_installation = true,
      }

      dapui.setup()

      -- Where to show the source when stopping/stepping. The default
      -- ('uselast') falls back to the previous window when focus is in a
      -- dap-ui panel; if that one is a panel too (e.g. moved Stacks ->
      -- Scopes), the panel refuses the buffer and every step warns
      -- "Invalid cursor line: out of range". Only ever use real file
      -- windows: one already showing the buffer, else the current/last one.
      dap.defaults.fallback.switchbuf = function(bufnr, line, column)
        local function is_code_win(win)
          local buf = vim.api.nvim_win_get_buf(win)
          return vim.api.nvim_win_get_config(win).relative == '' and vim.bo[buf].buftype == ''
        end
        local target
        for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
          if vim.api.nvim_win_get_buf(win) == bufnr then
            target = win
            break
          end
        end
        if not target then
          local cur, prev = vim.api.nvim_get_current_win(), vim.fn.win_getid(vim.fn.winnr '#')
          for _, win in ipairs { cur, prev, unpack(vim.api.nvim_tabpage_list_wins(0)) } do
            if win ~= 0 and is_code_win(win) then
              target = win
              break
            end
          end
        end
        if not target then
          vim.cmd 'botright split'
          target = vim.api.nvim_get_current_win()
        end
        vim.api.nvim_win_set_buf(target, bufnr)
        vim.api.nvim_win_set_cursor(target, { line, math.max(column - 1, 0) })
        vim.api.nvim_set_current_win(target)
        vim.cmd 'normal! zv'
      end
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      local netcoredbg_path
      if platform.is_linux then
        netcoredbg_path = vim.fn.stdpath 'data' .. '/mason/bin/netcoredbg'
      else
        -- see the mason-nvim-dap setup above for why macOS doesn't use mason's build
        netcoredbg_path = vim.fn.stdpath 'data' .. '/netcoredbg-osx-arm64/netcoredbg/netcoredbg'
      end
      dap.adapters.coreclr = {
        type = 'executable',
        command = netcoredbg_path,
        args = { '--interpreter=vscode' },
      }

      dap.configurations.cs = {
        {
          type = 'coreclr',
          name = 'launch - netcoredbg',
          request = 'launch',
          env = {
            ASPNETCORE_URLS = 'http://localhost:8080',
            ASPNETCORE_ENVIRONMENT = 'Development',
          },
          program = function()
            return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/', 'file')
          end,
          cwd = '${workspaceFolder}',
          -- netcoredbg has no Source Link / symbol server support, so
          -- stepping into BCL/framework code (e.g. String.Concat) isn't
          -- achievable regardless of settings — this only controls whether
          -- a breakpoint hit inside non-user code gets auto-skipped.
          justMyCode = false,
        },
        {
          type = 'coreclr',
          name = 'attach - netcoredbg',
          request = 'attach',
          processId = require('dap.utils').pick_process,
        },
      }

      -- Go: debug via delve's DAP server (installed by mason, see ensure_installed above)
      dap.adapters.delve = {
        type = 'server',
        port = '${port}',
        executable = {
          command = vim.fn.stdpath 'data' .. '/mason/bin/dlv',
          args = { 'dap', '-l', '127.0.0.1:${port}' },
        },
      }
      dap.configurations.go = {
        { type = 'delve', name = 'Debug file', request = 'launch', program = '${file}' },
        { type = 'delve', name = 'Debug package', request = 'launch', program = '${fileDirname}' },
        { type = 'delve', name = 'Debug test (package)', request = 'launch', mode = 'test', program = '${fileDirname}' },
      }

      -- C/C++: gdb >= 14 speaks DAP natively (`gdb -i dap`), no extra adapter needed
      -- Built per session (adapter as a function) so a glibc source tree
      -- installed after nvim started is picked up without a restart.
      dap.adapters.gdb = function(callback)
        local args = { '--interpreter=dap', '--eval-command', 'set print pretty on' }
        local function add(cmd)
          vim.list_extend(args, { '--eval-command', cmd })
        end

        -- glibc's debug info (libc6-dbg / debuginfod) points at relative paths
        -- like ./signal/../sysdeps/posix/signal.c. With the matching source
        -- tree (scripts/install-linux.sh fetches it) step-into on printf etc.
        -- shows real glibc code; without it, drop glibc's debug info so gdb
        -- steps over those calls instead of landing in unopenable files.
        local glibc_ver = vim.trim(vim.fn.system { 'getconf', 'GNU_LIBC_VERSION' }):match '^glibc (%S+)$'
        local glibc_src = glibc_ver and (vim.fn.stdpath 'data' .. '/glibc-src/glibc-' .. glibc_ver)
        if glibc_src and vim.fn.isdirectory(glibc_src) == 1 then
          add('directory ' .. glibc_src)
        else
          add 'set debuginfod enabled off'
          add 'set debug-file-directory'
        end

        callback { type = 'executable', command = 'gdb', args = args }
      end
      dap.configurations.c = {
        {
          type = 'gdb',
          name = 'Build & debug current file',
          request = 'launch',
          -- compile the current file with debug info first, so breakpoints
          -- map to source lines (a binary built without -g has no line info)
          program = function()
            local src = vim.fn.expand '%:p'
            local out = vim.fn.expand '%:p:r'
            local result = vim.system({ 'gcc', '-g', '-O0', '-Wall', '-o', out, src }, { text = true }):wait()
            if result.code ~= 0 then
              vim.notify(result.stderr, vim.log.levels.ERROR)
              return require('dap').ABORT
            end
            return out
          end,
          cwd = '${fileDirname}',
          -- gdb (<= 15) starts the inferior on `launch`, before nvim-dap has
          -- sent the breakpoints, so early breakpoints in main get skipped.
          -- Pausing at main's entry gives them time to land; F5 to continue.
          stopAtBeginningOfMainSubprogram = true,
        },
        {
          type = 'gdb',
          name = 'Debug executable',
          request = 'launch',
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '${workspaceFolder}',
          stopAtBeginningOfMainSubprogram = true,
        },
        {
          type = 'gdb',
          name = 'Attach to process',
          request = 'attach',
          pid = require('dap.utils').pick_process,
        },
      }
      dap.configurations.cpp = dap.configurations.c

      vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint' })
      vim.fn.sign_define('DapStopped', { text = '▶', texthl = 'DapStopped', linehl = 'DapStoppedLine' })

      vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
      vim.keymap.set('n', '<F9>', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
      vim.keymap.set('n', '<F6>', dap.step_over, { desc = 'Debug: Step Over' })
      vim.keymap.set('n', '<F7>', dap.step_into, { desc = 'Debug: Step Into' })
      vim.keymap.set('n', '<F8>', dap.step_out, { desc = 'Debug: Step Out' })
      vim.keymap.set('n', '<S-F5>', dap.terminate, { desc = 'Debug: Terminate' })
      vim.keymap.set('n', '<leader>du', dapui.toggle, { desc = 'Debug: Toggle UI' })
    end,
  },
}
