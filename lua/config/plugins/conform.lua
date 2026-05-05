--[[
  Path: lua/config/plugins/conform.lua
  Module: config.plugins.conform

  Purpose
    Lazy spec for conform.nvim: formatter orchestration (`<leader>f`), per-FT
    formatter lists (stylua, sql_formatter, prettier, ruff, etc.), and
    format-on-save policy.

  Rationale
    Keeps formatting separate from LSP where you explicitly disable or gate LSP
    format fallback per filetype.

  See `:help conform.nvim`.
]]

---@type LazySpec
return {
{ -- Autoformat
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function() require('conform').format { async = true } end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  ---@module 'conform'
  ---@type conform.setupOpts
  opts = {
    notify_on_error = false,
    -- No format-on-save by default (`<leader>f`). Buffers with
    -- `vim.b.disable_autoformat` (see ts_ls in lsp.lua) stay opt-out if you
    -- switch this to a function later.
    format_on_save = false,
    default_format_opts = {
      lsp_format = 'fallback', -- Use external formatters if configured below, otherwise use LSP formatting. Set to `false` to disable LSP formatting entirely.
    },
    -- You can also specify external formatters in here.
    formatters_by_ft = {
      lua = { 'stylua' },
      sql = { 'sql_formatter' },
      json = { 'prettier' },
      jsonc = { 'prettier' },
      javascript = { 'prettier' },
      javascriptreact = { 'prettier' },
      typescript = { 'prettier' },
      typescriptreact = { 'prettier' },
      vue = { 'prettier' },
      css = { 'prettier' },
      scss = { 'prettier' },
      html = { 'prettier' },
      markdown = { 'prettier' },
      python = { 'ruff_organize_imports', 'ruff_format' },
      -- Conform can also run multiple formatters sequentially
      -- You can use 'stop_after_first' to run the first available formatter from the list
      -- javascript = { "prettierd", "prettier", stop_after_first = true },
    },
    formatters = {
      ['sql_formatter'] = {
        prepend_args = { '-l', 'postgresql', '-c', '{"useTabs": true}' },
      },
    },
  },
},
}
