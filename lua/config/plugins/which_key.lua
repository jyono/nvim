---@type LazySpec
return {
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      -- Drop `local` so buffer maps (gitsigns) interleave A–Z with global ones.
      sort = { 'group', 'alphanum', 'mod' },
      spec = {
        { '<leader>d', group = 'DAP / [D]ebug', mode = { 'n' } },
        { '<leader>g', group = 'Git', mode = { 'n', 'v' } },
        { '<leader>k', group = '[k]ulala' },
        { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
        { '<leader>t', group = '[T]oggle' },
        { 'gr', group = 'LSP Actions', mode = { 'n' } },
      },
    },
  },
}
