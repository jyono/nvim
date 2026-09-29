---@type LazySpec
return {
  {
    'mfussenegger/nvim-lint',
    ft = 'go',
    -- Manual trigger, not BufWritePost: golangci-lint takes ~8s warm / ~17s cold on the
    -- chariot monorepo and saturates 8 cores. Attach it to an autocmd only on small repos.
    keys = {
      {
        '<leader>l',
        function()
          require('lint').try_lint()
          vim.notify('golangci-lint running…', vim.log.levels.INFO, { title = 'lint' })
        end,
        ft = 'go',
        desc = 'golangci-[l]int current package',
      },
    },
    config = function()
      local lint = require 'lint'
      lint.linters_by_ft = { go = { 'golangcilint' } }

      -- Mason's bin dir is not guaranteed to be on PATH when nvim-lint resolves the binary.
      local mason_bin = vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', 'bin', 'golangci-lint')
      if vim.uv.fs_stat(mason_bin) then lint.linters.golangcilint.cmd = mason_bin end
    end,
  },
}
