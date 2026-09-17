---@type LazySpec
return {
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },
      -- Drop `local` so buffer maps (gitsigns) interleave A–Z with global ones.
      sort = { 'group', 'alphanum', 'mod' },
      spec = {
        { '<leader>d', group = 'DAP / [D]ebug', mode = { 'n' } },
        { '<leader>g', group = 'Git', mode = { 'n', 'v' } },
        { '<leader>k', group = '[k]ulala' },
        { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>ti', desc = 'LSP inlay hints', mode = { 'n' } },
        { 'gr', group = 'LSP Actions', mode = { 'n' } },
      },
    },
  },
}
