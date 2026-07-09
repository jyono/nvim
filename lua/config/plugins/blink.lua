-- ---@type LazySpec
-- return {
--   {
--     'saghen/blink.cmp',
--     event = 'VimEnter',
--     version = '1.*',
--     dependencies = {
--       {
--         'L3MON4D3/LuaSnip',
--         version = '2.*',
--         build = (function()
--           -- jsregexp needs make; skip on Windows or when make is missing.
--           if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
--             return
--           end
--           return 'make install_jsregexp'
--         end)(),
--         dependencies = {
--           {
--             'rafamadriz/friendly-snippets',
--             config = function()
--               require('luasnip.loaders.from_vscode').lazy_load()
--             end,
--           },
--         },
--         opts = {},
--       },
--     },
--     opts = {
--       keymap = { preset = 'super-tab' },
--       appearance = { nerd_font_variant = 'mono' },
--       completion = { documentation = { auto_show = false, auto_show_delay_ms = 10 } },
--       sources = { default = { 'lsp', 'path', 'snippets' } },
--       snippets = { preset = 'luasnip' },
--       fuzzy = { implementation = 'prefer_rust_with_warning' }, -- :checkhealth without hererocks
--       signature = { enabled = true },
--     },
--   },
-- }
---@type LazySpec
return {
  {
    'saghen/blink.cmp',
    event = 'VimEnter',
    version = '1.*',
    dependencies = {
      -- Keeps your massive collection of community code snippets
      'rafamadriz/friendly-snippets',
    },
    opts = {
      keymap = { preset = 'super-tab' },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        documentation = { auto_show = false, auto_show_delay_ms = 500 },
      },
      -- Leverages Neovim's lightning-fast built-in snippet engine
      snippets = { preset = 'default' },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
      signature = { enabled = true },
    },
  },
}
