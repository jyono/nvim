---@type LazySpec
return {
  {
    'nvim-mini/mini.nvim',
    config = function()
      require('mini.ai').setup {
        -- Avoid clashing with built-in treesitter incremental selection (0.12+).
        mappings = { around_next = 'aa', inside_next = 'ii' },
        n_lines = 500,
      }
      require('mini.surround').setup()

      local statusline = require 'mini.statusline'
      statusline.setup { use_icons = vim.g.have_nerd_font }
      statusline.section_location = function() return '%2l:%-2v' end
    end,
  },
}
