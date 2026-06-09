---@type LazySpec
return {
  {
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
    opts = {
      notify_on_error = false,
      format_on_save = false, -- use `<leader>f`; see ts_ls disable_autoformat in lsp.lua
      default_format_opts = { lsp_format = 'fallback' },
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
      },
      formatters = {
        ['sql_formatter'] = {
          prepend_args = { '-l', 'postgresql', '-c', '{"useTabs": true}' },
        },
      },
    },
  },
}
