---@type LazySpec
return {
  {
    'EdenEast/nightfox.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('nightfox').setup {}
      vim.o.background = 'dark'
      vim.cmd.colorscheme 'carbonfox'
    end,
  },
}
