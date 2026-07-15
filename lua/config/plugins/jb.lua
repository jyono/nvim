---@type LazySpec
return {
  {
    'nickkadutskyi/jb.nvim',
    lazy = false,
    priority = 1000,
    config = function()
      require('jb').setup {}
      vim.o.background = 'dark'
      vim.cmd.colorscheme 'jb'
    end,
  },
}
