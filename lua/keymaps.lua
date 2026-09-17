-- For conciseness
local opts = { noremap = true, silent = true }

-- save file
vim.keymap.set('n', '<C-s>', '<cmd>w<CR>', opts)

-- quit file
vim.keymap.set('n', '<C-q>', '<cmd>q<CR>', opts)

--delete single character without copying into register
vim.keymap.set('n', 'x', '"_x', opts)

-- Vertical scroll and center
vim.keymap.set('n', '<C-d>', '<C-d>zz', opts) -- page down
vim.keymap.set('n', '<C-u>', '<C-u>zz', opts) -- page up

-- Find and center
vim.keymap.set('n', 'n', 'nzzzv', opts)
vim.keymap.set('n', 'N', 'Nzzzv', opts)

-- Resize with arrows
vim.keymap.set('n', '<Up>', '<cmd>resize -2<CR>', opts)
vim.keymap.set('n', '<Down>', '<cmd>resize +2<CR>', opts)
vim.keymap.set('n', '<Left>', '<cmd>vertical resize -2<CR>', opts)
vim.keymap.set('n', '<Right>', '<cmd>vertical resize +2<CR>', opts)

-- Buffers
vim.keymap.set('n', '<Tab>', '<cmd>bnext<CR>', opts)
vim.keymap.set('n', '<S-Tab>', '<cmd>bprevious<CR>', opts)
vim.keymap.set('n', '<leader>x', '<cmd>bdelete!<CR>', { desc = 'Close buffer' })
vim.keymap.set('n', '<leader>b', '<cmd>enew<CR>', { desc = 'New buffer' })
vim.keymap.set('n', '<leader>bo', '<cmd>BufferLineCloseOthers<CR>', { desc = 'Close other buffers' })

-- Window management
vim.keymap.set('n', '<leader>v', '<C-w>v', { desc = 'Split window vertically' })
vim.keymap.set('n', '<leader>h', '<C-w>s', { desc = 'Split window horizontally' })
vim.keymap.set('n', '<leader>se', '<C-w>=', { desc = 'Equalize split sizes' })
vim.keymap.set('n', '<leader>xs', '<cmd>close<CR>', { desc = 'Close current split' })

-- Navigate between splits
vim.keymap.set('n', '<C-h>', '<C-w>h', opts)
vim.keymap.set('n', '<C-j>', '<C-w>j', opts)
vim.keymap.set('n', '<C-k>', '<C-w>k', opts)
vim.keymap.set('n', '<C-l>', '<C-w>l', opts)

-- Stay in indent mode
vim.keymap.set('v', '<', '<gv', opts)
vim.keymap.set('v', '>', '>gv', opts)

-- Keep last yanked when pasting over a selection
vim.keymap.set('v', 'p', '"_dP', opts)

-- Diagnostic keymaps
vim.keymap.set('n', '[d', function()
  vim.diagnostic.jump { count = -1, float = true }
end, { desc = 'Go to previous diagnostic' })

vim.keymap.set('n', ']d', function()
  vim.diagnostic.jump { count = 1, float = true }
end, { desc = 'Go to next diagnostic' })

vim.keymap.set('n', '<leader>d', vim.diagnostic.open_float, { desc = 'Show line diagnostics' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })

-- Open terminal in a split (keeps it from taking over the only window)
vim.keymap.set('n', '<leader>th', '<cmd>split | terminal<CR>', { desc = 'Open terminal (horizontal split)' })
vim.keymap.set('n', '<leader>tv', '<cmd>vsplit | terminal<CR>', { desc = 'Open terminal (vertical split)' })

-- Terminal mode: Esc to go back to normal mode
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>', opts)

-- Copy current file's path to the system clipboard
vim.keymap.set('n', '<leader>cp', function()
  local path = vim.api.nvim_buf_get_name(0)
  vim.fn.setreg('+', path)
  vim.notify('Copied: ' .. path)
end, { desc = 'Copy absolute file path' })

vim.keymap.set('n', '<leader>cP', function()
  local path = vim.fn.expand '%:.'
  vim.fn.setreg('+', path)
  vim.notify('Copied: ' .. path)
end, { desc = 'Copy relative file path' })

-- Open preview: markdown -> markdown-preview.nvim, html -> iterm-preview.nvim's
-- generic open_url() pointed at the buffer's own file:// path.
vim.keymap.set('n', '<leader>op', function()
  local ft = vim.bo.filetype
  if ft == 'markdown' then
    vim.cmd.MarkdownPreviewToggle()
  elseif ft == 'html' then
    require('iterm-preview').open_url('file://' .. vim.api.nvim_buf_get_name(0))
  else
    vim.notify('No preview available for filetype: ' .. ft, vim.log.levels.WARN)
  end
end, { desc = 'Open preview (md/html)' })
