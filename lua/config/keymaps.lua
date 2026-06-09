vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

vim.keymap.set('n', '<leader>th', ':split | terminal<CR>', { desc = 'Terminal horizontal split' })
vim.keymap.set('n', '<leader>tv', ':vsplit | terminal<CR>', { desc = 'Terminal vertical split' })
vim.keymap.set('n', '<leader>tt', ':tabnew | terminal<CR>', { desc = 'Terminal in new tab' })
vim.keymap.set('n', '<leader>tf', ':ToggleTerm<CR>', { desc = 'Toggle floating terminal' })

-- Keep the yanked text when pasting over a visual selection.
vim.keymap.set('x', 'p', '"_dP', { noremap = true, silent = true })
