---@type LazySpec
return {
  'mfussenegger/nvim-lint',
  event = { 'BufReadPre', 'BufNewFile' },
  config = function()
    local lint = require 'lint'
    -- Skip when markdownlint is not on PATH yet (Mason install pending).
    lint.linters_by_ft = {
      markdown = vim.fn.executable 'markdownlint' == 1 and { 'markdownlint' } or {},
    }

    local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
      group = lint_augroup,
      callback = function()
        -- Skip LSP hover pop-ups and other unmodifiable buffers.
        if vim.bo.modifiable then
          lint.try_lint()
        end
      end,
    })
  end,
}
