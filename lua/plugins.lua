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
        close_command = 'bdelete %d',
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
    keys = {
      { '<leader>sf', '<cmd>Telescope find_files<CR>', desc = 'Search Files' },
      { '<leader>sg', '<cmd>Telescope live_grep<CR>', desc = 'Search by Grep' },
      { '<leader>sb', '<cmd>Telescope buffers<CR>', desc = 'Search Buffers' },
      { '<leader>sh', '<cmd>Telescope help_tags<CR>', desc = 'Search Help' },
      { '<leader>sd', '<cmd>Telescope diagnostics<CR>', desc = 'Search Diagnostics' },
      { '<leader>sk', '<cmd>Telescope keymaps<CR>', desc = 'Search Keymaps' },
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
    },
    keys = {
      { '<leader>e', '<cmd>Neotree toggle<CR>', desc = 'Toggle file explorer' },
    },
    opts = {
      filesystem = {
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
      }
      local filetypes = {
        'c',
        'cs',
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
      }

      require('nvim-treesitter').setup {
        install_dir = vim.fn.stdpath 'data' .. '/site',
      }
      require('nvim-treesitter').install(parsers)

      vim.api.nvim_create_autocmd('FileType', {
        pattern = filetypes,
        callback = function()
          vim.treesitter.start()
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
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

  -- Preview Markdown (incl. Mermaid diagrams) in the browser, synced live
  {
    'iamcco/markdown-preview.nvim',
    cmd = { 'MarkdownPreviewToggle', 'MarkdownPreview', 'MarkdownPreviewStop' },
    build = 'cd app && yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    ft = { 'markdown' },
    keys = {
      { '<leader>mp', '<cmd>MarkdownPreviewToggle<CR>', desc = 'Markdown Preview' },
    },
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
        -- The 'enter' preset's scroll_documentation_* only scrolls the
        -- completion-item doc window; blink.cmp doesn't expose a command
        -- for scrolling the signature help (overload) window, so scroll
        -- that one directly when it's open, falling back otherwise.
        ['<C-f>'] = {
          function()
            if require('blink.cmp').is_signature_visible() then
              require('blink.cmp.signature.window').scroll_down(4)
              return true
            end
          end,
          'scroll_documentation_down',
          'fallback',
        },
        ['<C-b>'] = {
          function()
            if require('blink.cmp').is_signature_visible() then
              require('blink.cmp.signature.window').scroll_up(4)
              return true
            end
          end,
          'scroll_documentation_up',
          'fallback',
        },
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
    },
    config = function()
      -- Give every LSP server the extra capabilities blink.cmp provides
      vim.lsp.config('*', {
        capabilities = require('blink.cmp').get_lsp_capabilities(),
      })

      -- Servers we want installed + enabled.
      -- Empty {} means "use nvim-lspconfig's defaults, no overrides".
      local servers = {
        clangd = {},      -- C
        bashls = {},      -- sh
        yamlls = {},      -- YAML
        ts_ls = {},       -- JS/TS
        sqlls = {},       -- SQL / PostgreSQL
        marksman = {},    -- Markdown
        dockerls = {},    -- Dockerfile
        jsonls = {},      -- JSON (e.g. appsettings.json)
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

      -- Keymaps that only apply in a buffer once an LSP has attached to it
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(ev)
          local map = function(keys, fn, desc)
            vim.keymap.set('n', keys, fn, { buffer = ev.buf, desc = 'LSP: ' .. desc })
          end
          map('gd', require('telescope.builtin').lsp_definitions, 'Goto Definition')
          map('gr', require('telescope.builtin').lsp_references, 'Goto References')
          map('gi', require('telescope.builtin').lsp_implementations, 'Goto Implementation')
          map('K', vim.lsp.buf.hover, 'Hover Documentation')
          map('<leader>rn', vim.lsp.buf.rename, 'Rename')
          map('<leader>ca', vim.lsp.buf.code_action, 'Code Action')
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = ev.buf }, { bufnr = ev.buf })
          end, 'Toggle Inlay Hints')

          local client = vim.lsp.get_client_by_id(ev.data.client_id)
          if client and client:supports_method('textDocument/inlayHint', ev.buf) then
            vim.lsp.inlay_hint.enable(true, { bufnr = ev.buf })
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
    ft = 'cs',
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
        },
      })
    end,
    opts = {},
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
          require('conform').format { async = true }
        end,
        desc = 'Format buffer',
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { 'stylua' },
        sh = { 'shfmt' },
        javascript = { 'prettier' },
        typescript = { 'prettier' },
        json = { 'prettier' },
        yaml = { 'prettier' },
        markdown = { 'prettier' },
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
        ensure_installed = platform.is_linux and { 'netcoredbg' } or {},
        automatic_installation = true,
      }

      dapui.setup()
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
