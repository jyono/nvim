--[[
  Path: lua/config/go.lua
  Module: config.go

  Purpose
    Shared Go settings for **gopls** (`buildFlags` / tags) and a small helper to
    find the module root (`go.mod`) for tools that care about cwd.

  Rationale
    Delve uses stock `go build` / `dlv` defaults from nvim-dap-go — no custom
    `-tags` or Mason path wiring here, so debugging stays predictable.
]]

local M = {}

--- Comma-separated list for gopls `-tags=...` (editing / analysis only).
M.tags = 'functional,integration,small,medium,large'

M.gopls_build_flags = { '-tags', M.tags }

--- Walk up from `start_dir` (default: current buffer’s directory) to `go.mod`.
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
