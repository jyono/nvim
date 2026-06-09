vim.api.nvim_create_autocmd('TextYankPost', {
  group = vim.api.nvim_create_augroup('config-highlight-yank', { clear = true }),
  callback = function() vim.hl.on_yank() end,
})

-- Untrusted READMEs can embed vim modelines; don't execute them on markdown.
vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('config-markdown-safe-read', { clear = true }),
  pattern = 'markdown',
  callback = function() vim.opt_local.modeline = false end,
})
