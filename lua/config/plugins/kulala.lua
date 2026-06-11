---@type LazySpec
return {
  {
    'mistweaverco/kulala.nvim',
    keys = {
      { '<leader>Rs', function() require('kulala').run() end, desc = 'Send request', mode = { 'n', 'v' } },
      { '<leader>Ra', function() require('kulala').run_all() end, desc = 'Send all requests', mode = { 'n', 'v' } },
      { '<leader>Rb', function() require('kulala').scratchpad() end, desc = 'Open scratchpad' },
    },
    ft = { 'http', 'rest' },
    opts = {
      global_keymaps = true,
      global_keymaps_prefix = '<leader>R',
      kulala_keymaps_prefix = '',
    },
  },
}
