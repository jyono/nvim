--[[
  Path: lua/config/diagnostics.lua
  Module: config.diagnostics

  Purpose
    One global `vim.diagnostic.config` for how LSP diagnostics render: signs,
    virtual text, floating previews, underline, and sort order.

  Rationale
    A single module avoids conflicting `vim.diagnostic.config` calls (e.g. one
    at startup and another inside LSP setup) overwriting each other.

  Levels (`vim.g.diagnostics_level`, cycle with <leader>td or :DiagnosticsLevel):
    all    — HINT and up (default display)
    errors — ERROR only (hides markdownlint WARN and most LSP warnings)
    off    — no signs, underline, or virtual text

  See `:help vim.diagnostic.config()`, `:help diagnostic-severity`.
]]

local M = {}

M.levels = { 'all', 'errors', 'off' }

local severity_min = {
  all = vim.diagnostic.severity.HINT,
  errors = vim.diagnostic.severity.ERROR,
}

local function base_config()
  return {
    severity_sort = true,
    float = { border = 'rounded', source = 'if_many' },
    underline = true,
    signs = vim.g.have_nerd_font and {
      text = {
        [vim.diagnostic.severity.ERROR] = '󰅚 ',
        [vim.diagnostic.severity.WARN] = '󰀪 ',
        [vim.diagnostic.severity.INFO] = '󰋽 ',
        [vim.diagnostic.severity.HINT] = '󰌶 ',
      },
    } or {},
    virtual_text = {
      source = 'if_many',
      spacing = 2,
      format = function(diagnostic)
        local diagnostic_message = {
          [vim.diagnostic.severity.ERROR] = diagnostic.message,
          [vim.diagnostic.severity.WARN] = diagnostic.message,
          [vim.diagnostic.severity.INFO] = diagnostic.message,
          [vim.diagnostic.severity.HINT] = diagnostic.message,
        }
        return diagnostic_message[diagnostic.severity]
      end,
    },
  }
end

function M.get_level()
  return vim.g.diagnostics_level or 'all'
end

---@param level 'all'|'errors'|'off'
---@param opts? { silent?: boolean }
function M.apply(level, opts)
  opts = opts or {}
  vim.g.diagnostics_level = level

  if level == 'off' then
    vim.diagnostic.enable(false)
    if not opts.silent then vim.notify('Diagnostics: off', vim.log.levels.INFO) end
    return
  end

  vim.diagnostic.enable(true)
  vim.diagnostic.config(vim.tbl_extend('force', base_config(), {
    severity = { min = severity_min[level] },
  }))
  if not opts.silent then vim.notify(('Diagnostics: %s'):format(level), vim.log.levels.INFO) end
end

function M.cycle()
  local current = M.get_level()
  local next_idx = 1
  for i, name in ipairs(M.levels) do
    if name == current then
      next_idx = (i % #M.levels) + 1
      break
    end
  end
  M.apply(M.levels[next_idx])
end

M.apply(M.get_level(), { silent = true })

vim.api.nvim_create_user_command('DiagnosticsLevel', function(opts)
  local arg = opts.args
  if arg == '' then
    M.cycle()
    return
  end
  if not vim.tbl_contains(M.levels, arg) then
    vim.notify(('Unknown level %q (use all, errors, or off)'):format(arg), vim.log.levels.ERROR)
    return
  end
  M.apply(arg)
end, {
  nargs = '?',
  complete = function()
    return M.levels
  end,
  desc = 'Set or cycle diagnostic display level (all | errors | off)',
})

vim.keymap.set('n', '<leader>td', M.cycle, { desc = 'Cycle diagnostic level (all / errors / off)' })

return M
