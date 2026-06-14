---@type LazySpec
return {
  {
    'mistweaverco/kulala.nvim',
    keys = {
      { '<leader>Ks', function() require('kulala').run() end, desc = 'Send request', mode = { 'n', 'v' } },
      { '<leader>Ka', function() require('kulala').run_all() end, desc = 'Send all requests', mode = { 'n', 'v' } },
      { '<leader>Kb', function() require('kulala').scratchpad() end, desc = 'Open scratchpad' },
    },
    ft = { 'http', 'rest' },
    opts = {
      global_keymaps = true,
      global_keymaps_prefix = '<leader>K',
      kulala_keymaps_prefix = '',
    },
  },
}
