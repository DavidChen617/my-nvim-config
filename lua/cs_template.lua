-- Fills a brand-new *.cs buffer with a file-scoped namespace and a type, like
-- Rider/VS "New Class". Triggered by BufNewFile, so it works from neo-tree's
-- `a`, `:e Foo.cs`, etc. Namespace = <RootNamespace or csproj name> + the
-- folder path below the csproj. `IFoo` -> interface, otherwise class.
local M = {}

local function read_root_namespace(csproj)
  for line in io.lines(csproj) do
    local ns = line:match '<RootNamespace>%s*([^<%s]+)%s*</RootNamespace>'
    if ns then
      return ns
    end
  end
end

---@param file string absolute path of the new file
---@return string|nil
function M.namespace_for(file)
  local dir = vim.fs.dirname(file)
  local proj = vim.fs.find(function(name)
    return name:match '%.csproj$' ~= nil
  end, { path = dir, upward = true, type = 'file', limit = 1 })[1]
  if not proj then
    return nil
  end
  local root = read_root_namespace(proj) or vim.fn.fnamemodify(proj, ':t:r')
  local rel = dir:sub(#vim.fs.dirname(proj) + 2)
  -- folder segments may contain characters invalid in identifiers
  local parts = { root }
  for seg in rel:gmatch '[^/]+' do
    if seg ~= 'bin' and seg ~= 'obj' then
      table.insert(parts, (seg:gsub('[^%w_]', '_')))
    end
  end
  return table.concat(parts, '.')
end

function M.fill(buf)
  if vim.api.nvim_buf_line_count(buf) > 1 or vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] ~= '' then
    return
  end
  local file = vim.api.nvim_buf_get_name(buf)
  local name = vim.fn.fnamemodify(file, ':t:r'):gsub('[^%w_]', '_')
  local kind = name:match '^I%u' and 'interface' or 'class'
  local ns = M.namespace_for(file)

  local lines = {}
  if ns then
    vim.list_extend(lines, { 'namespace ' .. ns .. ';', '' })
  end
  vim.list_extend(lines, { 'public ' .. kind .. ' ' .. name, '{', '    ', '}' })
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  -- cursor inside the braces, ready to type
  vim.api.nvim_win_set_cursor(0, { #lines - 1, 4 })
  vim.bo[buf].modified = false
end

function M.setup()
  vim.api.nvim_create_autocmd('BufNewFile', {
    desc = 'C#: namespace + type boilerplate for new files',
    group = vim.api.nvim_create_augroup('cs-new-file', { clear = true }),
    pattern = '*.cs',
    callback = function(ev)
      M.fill(ev.buf)
    end,
  })
  -- neo-tree's `a` creates the file on disk first and then opens it, so the
  -- buffer is an existing empty file and BufNewFile never fires.
  vim.api.nvim_create_autocmd('BufReadPost', {
    desc = 'C#: namespace + type boilerplate for freshly created empty files',
    group = 'cs-new-file',
    pattern = '*.cs',
    callback = function(ev)
      if vim.fn.getfsize(ev.file) == 0 then
        M.fill(ev.buf)
      end
    end,
  })
end

return M
