-- Detected once per session; `require` caches this module, so every
-- subsequent `require 'platform'` elsewhere reuses this same table instead
-- of re-running os_uname().
local sysname = vim.uv.os_uname().sysname

local M = {}
M.is_linux = sysname == 'Linux'
M.is_mac = sysname == 'Darwin'
return M
