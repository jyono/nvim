---@type LazySpec
return {
  {
    'folke/which-key.nvim',
    event = 'VimEnter',
    opts = {
      delay = 0,
      icons = { mappings = vim.g.have_nerd_font },
      spec = {
        { '<leader>d', group = 'DAP / [D]ebug', mode = { 'n' } },
        { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>ti', desc = 'LSP inlay hints', mode = { 'n' } },
        { '<leader>k', group = '[k]ulala' },
        { '<leader>g', group = 'Git', mode = { 'n', 'v' } },
        { 'gr', group = 'LSP Actions', mode = { 'n' } },
      },
    },
  },
}
