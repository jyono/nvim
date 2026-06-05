--[[
  Path: lua/config/plugins/render_markdown.lua
  Module: config.plugins.render_markdown

  Purpose
    Lazy spec for render-markdown.nvim: in-buffer Markdown preview (no external
    server), with LaTeX disabled and LSP/blink completion hooks enabled.

  Rationale
    Filetype-limited load keeps startup lean; pairs with Treesitter + mini.nvim
    as declared dependencies.

  See plugin README; `:help render-markdown.nvim` if bundled.
]]

---@type LazySpec
return {
{
  'MeanderingProgrammer/render-markdown.nvim',
  dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' },
  ft = { 'markdown', 'markdown.mdx' },
  opts = {
    latex = { enabled = false },
    completions = { lsp = { enabled = true }, blink = { enabled = true } },
  },
  config = function(_, opts)
    local decorator = require 'render-markdown.lib.decorator'
    local schedule = decorator.schedule
    function decorator:schedule(debounce, ms, callback)
      schedule(self, debounce, ms, function()
        vim.defer_fn(callback, 0)
      end)
    end
    require('render-markdown').setup(opts)
  end,
},
}
