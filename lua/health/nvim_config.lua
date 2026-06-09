--[[
  Discovered by `:checkhealth nvim_config` (see :help health-dev).

  Previously lived at lua/config/health.lua, which Neovim does not load for
  :checkhealth.
]]

local M = {}

function M.check()
  vim.health.start 'nvim configuration'

  vim.health.info [[NOTE: Not every warning is a 'must-fix' in `:checkhealth`

  Fix only warnings for plugins and languages you intend to use.
    Mason will give warnings for languages that are not installed.
    You do not need to install, unless you want to use those languages!]]

  local uv = vim.uv or vim.loop
  vim.health.info('System Information: ' .. vim.inspect(uv.os_uname()))

  local verstr = tostring(vim.version())
  if not vim.version.ge then
    vim.health.error(string.format("Neovim out of date: '%s'. Upgrade to 0.12+ stable or nightly", verstr))
  elseif vim.version.ge(vim.version(), '0.12') then
    vim.health.ok(string.format("Neovim version is: '%s'", verstr))
    vim.health.info(string.format("Binary: %s", vim.v.progpath))
    local missing = {}
    if type(vim.list) ~= 'table' or type(vim.list.unique) ~= 'function' then
      missing[#missing + 1] = 'vim.list'
    end
    if type(vim.text) ~= 'table' or type(vim.text.diff) ~= 'function' then
      missing[#missing + 1] = 'vim.text.diff'
    end
    if #missing > 0 then
      vim.health.error(string.format(
        'Incomplete 0.12 runtime (missing %s). Upgrade Neovim — not WSL; the Ubuntu dev package is incomplete.',
        table.concat(missing, ', ')
      ))
    end
  else
    vim.health.error(string.format("Neovim out of date: '%s'. This config targets 0.12+ (see :h news)", verstr))
  end

  for _, exe in ipairs { 'git', 'make', 'unzip', 'rg' } do
    if vim.fn.executable(exe) == 1 then
      vim.health.ok(string.format("Found executable: '%s'", exe))
    else
      vim.health.warn(string.format("Could not find executable: '%s'", exe))
    end
  end
end

return M
