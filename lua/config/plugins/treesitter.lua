---@type LazySpec
return {
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'main', -- required for Neovim 0.12
    lazy = false,
    build = ':TSUpdate',
    config = function()
      -- Puts site/parser + site/queries on rtp before install.
      require('nvim-treesitter').setup()
      require('nvim-treesitter').install {
        'bash',
        'c',
        'diff',
        'html',
        'lua',
        'luadoc',
        'markdown',
        'markdown_inline',
        'query',
        'vim',
        'vimdoc',
        'go',
        'gomod',
        'gowork',
        'gosum',
        'rust',
        'python',
        'javascript',
        'typescript',
        'tsx',
        'json',
        'toml',
        'css',
        'helm',
        'dockerfile',
        'yaml',
        'sql',
        'hcl',
        'terraform',
      }
      vim.api.nvim_create_autocmd('FileType', {
        callback = function() pcall(vim.treesitter.start) end,
      })
    end,
  },
}
