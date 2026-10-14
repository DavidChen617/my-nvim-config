-- C uses real tab characters, 4 columns wide (everything else uses 4 spaces,
-- see options.lua). In `after/` so it runs after the built-in C ftplugin.
-- keep vim-sleuth from re-guessing the indent per file (it picked sw=2 here)
vim.b.sleuth_automatic = 0
vim.bo.expandtab = false
vim.bo.tabstop = 4
vim.bo.shiftwidth = 4
vim.bo.softtabstop = 0
-- :Man / K-in-man-buffers: prefer section 3 (libc) then 2 (syscalls) in C
vim.b.man_default_sects = '3,2'
