vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

vim.o.number = true
vim.o.relativenumber = true
vim.o.mouse = 'a'
vim.o.cursorline = true
vim.o.scrolloff = 8

vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.ignorecase = true
vim.opt.smartcase = true

vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.undofile = true
vim.opt.termguicolors = true

-- Rounded borders on all floating windows (hover, signature, completion menu, etc.)
vim.opt.winborder = 'rounded'

-- Folding based on treesitter, starting fully unfolded
vim.o.foldmethod = 'expr'
vim.o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99

-- System clipboard integration. macOS's `*` register maps to pbcopy/pbpaste
-- directly; Linux needs `+` (unnamedplus) to hit the real clipboard instead
-- of the X11 PRIMARY selection.
local platform = require 'platform'
vim.opt.clipboard = platform.is_linux and 'unnamedplus' or 'unnamed'
