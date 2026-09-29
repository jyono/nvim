local M = {}

-- gopls build tags for this monorepo (editing/analysis only; dap-go uses stock build).
-- Mirrors the //go:build tags actually present in chariot. `wireinject` is deliberately
-- absent: enabling it would analyze the wire.go injectors and exclude the generated
-- wire_gen.go (//go:build !wireinject) that actually compiles.
M.tags = 'unit,integration,functional,medium,large,benchmark'
M.gopls_build_flags = { '-tags', M.tags }

function M.mod_root(start_dir)
  local dir = start_dir or vim.fn.expand '%:p:h'
  for _ = 1, 64 do
    if vim.uv.fs_stat(dir .. '/go.mod') then return dir end
    local parent = vim.fn.fnamemodify(dir, ':h')
    if parent == dir then break end
    dir = parent
  end
  return vim.fn.getcwd()
end

return M
