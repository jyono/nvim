local levels = { 'all', 'errors', 'off' }
local idx = { all = 1, errors = 2, off = 3 }
local min_sev = { all = vim.diagnostic.severity.HINT, errors = vim.diagnostic.severity.ERROR }

-- Single vim.diagnostic.config here; lsp.lua does not override display.
local function ui()
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
    virtual_text = { source = 'if_many', spacing = 2 },
  }
end

local function apply(level, quiet)
  vim.g.diagnostics_level = level
  if level == 'off' then
    vim.diagnostic.enable(false)
  else
    vim.diagnostic.enable(true)
    vim.diagnostic.config(vim.tbl_extend('force', ui(), { severity = { min = min_sev[level] } }))
  end
  if not quiet then
    vim.notify('Diagnostics: ' .. level, vim.log.levels.INFO)
  end
end

local function cycle()
  apply(levels[(idx[vim.g.diagnostics_level or 'all'] or 0) % #levels + 1])
end

apply(vim.g.diagnostics_level or 'all', true)

vim.api.nvim_create_user_command('DiagnosticsLevel', function(o)
  if o.args == '' then
    cycle()
  elseif vim.tbl_contains(levels, o.args) then
    apply(o.args)
  end
end, { nargs = '?', complete = function() return levels end })

vim.keymap.set('n', '<leader>td', cycle, { desc = 'Cycle diagnostic level (all / errors / off)' })
