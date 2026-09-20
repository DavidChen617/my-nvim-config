require 'options'
require 'keymaps'

-- Neovim's built-in `.tf` detection is content-based (vim.filetype.detect.tf):
-- it falls back to the legacy Tcl-style `tf` filetype whenever every
-- non-blank line in the buffer starts with `;` or `/` (e.g. a file that's
-- all `//` comments), instead of `terraform`. Force it by extension so
-- terraformls/treesitter always attach regardless of file content.
vim.filetype.add {
  extension = {
    tf = 'terraform',
    tfvars = 'terraform-vars',
  },
}

-- Briefly highlight the yanked text so a copy/delete gives visual feedback.
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight yanked text',
  group = vim.api.nvim_create_augroup('highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system {
    'git',
    'clone',
    '--filter=blob:none',
    '--branch=stable',
    'https://github.com/folke/lazy.nvim.git',
    lazypath,
  }
  if vim.v.shell_error ~= 0 then
    error('Error cloning lazy.nvim:\n' .. out)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup(require 'plugins')

-- Transparent background: let the terminal's own background show through
-- instead of whatever the active colorscheme paints.
local function set_transparent_bg()
  local groups = {
    'Normal',
    'NormalNC',
    'SignColumn',
    'EndOfBuffer',
    'LineNr',
    'FoldColumn',
    'VertSplit',
    'WinSeparator',
  }
  for _, group in ipairs(groups) do
    vim.api.nvim_set_hl(0, group, { bg = 'none' })
  end

  -- Floating windows (hover, code action, telescope, ...) get their own
  -- solid background instead of inheriting the transparent terminal, so
  -- popups stay legible over whatever's behind the terminal.
  vim.api.nvim_set_hl(0, 'NormalFloat', { bg = '#1e2030' })
  vim.api.nvim_set_hl(0, 'FloatBorder', { bg = '#1e2030', fg = '#414868' })
end

set_transparent_bg()
vim.api.nvim_create_autocmd('ColorScheme', { callback = set_transparent_bg })

-- Syntax colors pulled from the actual "Rider Islands Dark" scheme in use
-- in Rider (~/Library/Application Support/JetBrains/Rider2026.2/colors, via
-- the rider-theme-pack plugin's colorSchemes/RiderIslandsDark.xml). Only
-- foreground colors are set here; background stays transparent per
-- set_transparent_bg() above. Treesitter captures are coarser than Rider's
-- full semantic (ReSharper) highlighting, so this is a close approximation,
-- not a pixel-perfect port.
local function set_rider_islands_dark_syntax()
  local colors = {
    keyword = '#6C95EB',
    type = '#C191FF',
    func = '#39CC9B',
    field = '#66C3CC',
    variable = '#BDBDBD',
    string = '#C9A26D',
    string_escape = '#D688D4',
    number = '#ED94C0',
    comment = '#85C46C',
  }

  local hl = vim.api.nvim_set_hl

  -- Keywords / control flow
  for _, group in ipairs {
    'Keyword',
    '@keyword',
    '@keyword.function',
    '@keyword.return',
    '@keyword.import',
    '@keyword.modifier',
    '@keyword.operator',
    '@conditional',
    '@repeat',
    '@exception',
    '@boolean',
  } do
    hl(0, group, { fg = colors.keyword })
  end

  -- Types / classes / interfaces
  for _, group in ipairs { 'Type', '@type', '@type.builtin', '@constructor' } do
    hl(0, group, { fg = colors.type })
  end

  -- Methods / functions
  for _, group in ipairs {
    'Function',
    '@function',
    '@function.call',
    '@function.method',
    '@function.method.call',
  } do
    hl(0, group, { fg = colors.func })
  end

  -- Fields / properties / constants
  for _, group in ipairs { '@field', '@property', '@variable.member' } do
    hl(0, group, { fg = colors.field })
  end
  hl(0, '@constant', { fg = colors.field, bold = true })

  -- Local variables / parameters / punctuation / operators
  for _, group in ipairs {
    '@variable',
    '@parameter',
    '@variable.parameter',
    '@operator',
    '@punctuation.bracket',
    '@punctuation.delimiter',
  } do
    hl(0, group, { fg = colors.variable })
  end

  -- Strings / numbers
  hl(0, 'String', { fg = colors.string })
  hl(0, '@string', { fg = colors.string })
  hl(0, '@string.escape', { fg = colors.string_escape })
  hl(0, 'Number', { fg = colors.number })
  hl(0, '@number', { fg = colors.number })

  -- Comments (italic, matching Rider's FONT_TYPE=2)
  hl(0, 'Comment', { fg = colors.comment, italic = true })
  hl(0, '@comment', { fg = colors.comment, italic = true })
  hl(0, '@comment.documentation', { fg = colors.comment, italic = true })

  -- C# attributes, e.g. [Obsolete]
  hl(0, '@attribute', { fg = colors.type })
end

set_rider_islands_dark_syntax()
vim.api.nvim_create_autocmd('ColorScheme', { callback = set_rider_islands_dark_syntax })
