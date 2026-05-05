--[[
  Path: lua/config/go.lua
  Module: config.go

  Purpose
    Shared Go build tag string for gopls and Delve so tests/binaries compile the
    same way when editing, running, and debugging.

  Rationale
    Mismatched tags are the most common reason Delve “misses” breakpoints or
    skips integration-tagged code during debug sessions.
]]

local M = {}

--- Comma-separated list passed to `-tags=...` for tools that expect one string.
M.tags = 'functional,integration,small,medium,large'

--- gopls `settings.gopls.buildFlags` shape (list of argv tokens).
M.gopls_build_flags = { '-tags', M.tags }

--- nvim-dap-go `delve.build_flags` shape (`dlv` expects a single `-tags=...` flag).
M.delve_build_flags = '-tags=' .. M.tags

--- Prefer Mason’s `dlv` when present so PATH does not shadow an older binary.
function M.delve_executable()
  local mason = (vim.fn.stdpath 'data') .. '/mason/packages/delve/dlv'
  if vim.uv.fs_stat(mason) then
    return mason
  end
  return 'dlv'
end

return M
