---@type LazySpec
return {
  {
    'mistweaverco/kulala.nvim',
    ft = { 'http', 'rest' },
    opts = {
      global_keymaps = {
        ['Import collection'] = {
          'I',
          function() require('kulala').import() end,
          ft = { 'http', 'rest' },
        },
        ['Export collection'] = {
          'E',
          function() require('kulala').export() end,
          ft = { 'http', 'rest' },
        },
      },
      global_keymaps_prefix = '<leader>K',
      kulala_keymaps = true,
      kulala_keymaps_prefix = '',
    },
    keys = {
      { '<leader>Ks', function() require('kulala').run() end, desc = 'Send request', mode = { 'n', 'v' } },
      { '<leader>Ka', function() require('kulala').run_all() end, desc = 'Send all requests', mode = { 'n', 'v' } },
      { '<leader>Kb', function() require('kulala').scratchpad() end, desc = 'Open scratchpad' },
      { '<leader>Ko', function() require('kulala').open() end, desc = 'Open kulala' },
      { '<leader>Kr', function() require('kulala').replay() end, desc = 'Replay last request' },
      { '<leader>Kc', function() require('kulala').copy() end, desc = 'Copy as cURL' },
      { '<leader>KC', function() require('kulala').from_curl() end, desc = 'Paste from curl' },
      { '<leader>Ki', function() require('kulala').inspect() end, desc = 'Inspect request' },
      { '<leader>KI', function() require('kulala').import() end, desc = 'Import collection' },
      { '<leader>KE', function() require('kulala').export() end, desc = 'Export collection' },
      { '<leader>Kj', function() require('kulala').open_cookies_jar() end, desc = 'Open cookies jar' },
      { '<leader>Ke', function() require('kulala').set_selected_env() end, desc = 'Select environment' },
      { '<leader>Ku', function() require('kulala.ui.auth_manager').open_auth_config() end, desc = 'Manage auth' },
      { '<leader>Kg', function() require('kulala').download_graphql_schema() end, desc = 'Download GraphQL schema' },
      { '<leader>Kn', function() require('kulala').jump_next() end, desc = 'Next request' },
      { '<leader>Kp', function() require('kulala').jump_prev() end, desc = 'Previous request' },
      { '<leader>Kf', function() require('kulala').search() end, desc = 'Find request' },
      { '<leader>Kt', function() require('kulala').toggle_view() end, desc = 'Toggle headers/body' },
      { '<leader>KS', function() require('kulala').show_stats() end, desc = 'Show stats' },
      { '<leader>Kq', function() require('kulala').close() end, desc = 'Close kulala window' },
      { '<leader>Kx', function() require('kulala').scripts_clear_global() end, desc = 'Clear script globals' },
      { '<leader>KX', function() require('kulala').clear_cached_files() end, desc = 'Clear cached files' },
    },
  },
}
