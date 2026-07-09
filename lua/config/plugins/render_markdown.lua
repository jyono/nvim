---@type LazySpec
return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    ft = { 'markdown', 'markdown.mdx' },
    opts = {
      latex = { enabled = false },
      completions = { lsp = { enabled = true }, blink = { enabled = true } },
    },
  },
}
