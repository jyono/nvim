local M = {}

-- gopls build tags for this monorepo (editing/analysis only; dap-go uses stock build).
M.tags = 'functional,integration,small,medium,large'
M.gopls_build_flags = { '-tags', M.tags }

function M.mod_root(start_dir)
  local dir = start_dir or vim.fn.expand '%:p:h'
  for _ = 1, 64 do
    if vim.uv.fs_stat(dir .. '/go.mod') then
      return dir
    end
    local parent = vim.fn.fnamemodify(dir, ':h')
    if parent == dir then
      break
    end
    dir = parent
  end
  return vim.fn.getcwd()
end

return M
