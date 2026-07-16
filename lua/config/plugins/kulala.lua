local function paste_from_curl()
  -- Upstream from_curl only reads `+`. On WSL, curl may sit in `"` or arrive with CRLF.
  local function looks_like_curl(s)
    s = vim.trim(s or '')
    return s:find('^[Cc]url%.?e?x?e?%s') ~= nil or s:find('/curl%s') ~= nil
  end

  local curl
  for _, reg in ipairs { '+', '"' } do
    local text = vim.fn.getreg(reg)
    if type(text) == 'string' then
      text = text:gsub('\r', '')
      if looks_like_curl(text) then
        curl = text
        break
      end
    end
  end

  if not curl then
    vim.notify('kulala: no curl command in clipboard', vim.log.levels.WARN)
    return
  end

  local Bridge = require('kulala.cmd.kulala_core_bridge')
  if not Bridge.enabled() then
    vim.notify('kulala: kulala-core not available', vim.log.levels.ERROR)
    return
  end

  local lines, err = Bridge.from_curl(curl)
  if not lines then
    vim.notify('kulala: ' .. (err or 'from_curl failed'), vim.log.levels.ERROR)
    return
  end

  vim.api.nvim_put(lines, 'l', false, false)
end

---@type LazySpec
return {
  {
    'mistweaverco/kulala.nvim',
    ft = { 'http', 'rest' },
    -- Lazy keys: load plugin from any buffer + show in which-key before opening .http.
    -- Kulala's global_keymaps (below) registers the full default set on load.
    keys = {
      { '<leader>ks', function() require('kulala').run() end, desc = 'Send request', mode = { 'n', 'v' } },
      { '<leader>ka', function() require('kulala').run_all() end, desc = 'Send all requests', mode = { 'n', 'v' } },
      { '<leader>kb', function() require('kulala').scratchpad() end, desc = 'Open scratchpad' },
      { '<leader>ko', function() require('kulala').open() end, desc = 'Open kulala' },
      { '<leader>kr', function() require('kulala').replay() end, desc = 'Replay last request' },
      { '<leader>kc', function() require('kulala').copy() end, desc = 'Copy as cURL' },
      { '<leader>kC', paste_from_curl, desc = 'Paste from curl' },
      { '<leader>ki', function() require('kulala').inspect() end, desc = 'Inspect request' },
      { '<leader>ke', function() require('kulala').set_selected_env() end, desc = 'Select environment' },
      { '<leader>kE', function() require('kulala').export() end, desc = 'Export collection' },
    },
    opts = {
      -- Merge with kulala defaults; only override paste (WSL clipboard fix).
      -- Custom entries skip prefix application — use full lhs, not bare 'C'.
      global_keymaps = {
        ['Paste from curl'] = {
          '<leader>kC',
          paste_from_curl,
          ft = { 'http', 'rest' },
        },
      },
      global_keymaps_prefix = '<leader>k',
      kulala_keymaps_prefix = '',
    },
  },
}
