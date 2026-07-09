local M = {}

M.default_attach_host = '127.0.0.1'
M.default_attach_port = 2345

--- Port for attaching to an external headless Delve server.
---@return number
function M.attach_port()
  local from_env = vim.env.DAP_ATTACH_PORT or vim.env.DLV_PORT
  if from_env and from_env ~= '' then
    return tonumber(from_env) or M.default_attach_port
  end
  local listen = vim.env.DLV_LISTEN
  if listen and listen ~= '' then
    local port = listen:match ':(%d+)$'
    if port then
      return tonumber(port) or M.default_attach_port
    end
  end
  return M.default_attach_port
end

--- Attach to a Delve server started outside nvim (e.g. `make debug`).
--- Process keeps env from the external shell; nvim only connects the debugger.
---@param opts? { host?: string, port?: number }
function M.attach_remote(opts)
  opts = opts or {}
  require('dap').run(
    {
      type = 'go',
      name = 'Attach remote (Delve headless)',
      request = 'attach',
      mode = 'remote',
      host = opts.host or M.default_attach_host,
      port = opts.port or M.attach_port(),
    },
    { new = true }
  )
end

return M
