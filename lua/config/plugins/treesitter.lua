--[[
  Path: lua/config/plugins/treesitter.lua
  Module: config.plugins.treesitter

  Purpose
    Lazy spec for nvim-treesitter: parser install list, `TSUpdate` build step,
    highlight/indent toggles, and `lazy = false` so buffers get treesitter early.

  Rationale
    Syntax/folds/indent for supported languages; `auto_install` pulls missing
    parsers on demand. Ruby keeps vim regex highlighting (see nvim-treesitter docs).

  See `:help nvim-treesitter`.
]]

---@type LazySpec
return {
{ -- Highlight, edit, and navigate code
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
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
