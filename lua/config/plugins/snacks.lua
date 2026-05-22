--[[
  Path: lua/config/plugins/snacks.lua
  Module: config.plugins.snacks

  Purpose
    Lazy spec for folke/snacks.nvim: fuzzy finder (picker) for files, grep,
    diagnostics, help, and LSP; replaces telescope.nvim.

  Rationale
    Keymaps mirror the former Telescope `<leader>s*` layout. LSP maps in
    `lsp.lua` defer `Snacks.picker.*` until keypress for the same VimEnter reason.

  See snacks picker docs: https://github.com/folke/snacks.nvim/blob/main/docs/picker.md
]]

---@type LazySpec
return {
{
  'folke/snacks.nvim',
  event = 'VimEnter',
  dependencies = {
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
  },
  ---@type snacks.Config
  opts = {
    picker = {
      ui_select = true,
    },
  },
  config = function()
    local picker = Snacks.picker

    vim.keymap.set('n', '<leader>sh', picker.help, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', picker.keymaps, { desc = '[S]earch [K]eymaps' })
    vim.keymap.set('n', '<leader>sf', picker.files, { desc = '[S]earch [F]iles' })
    vim.keymap.set('n', '<leader>ss', function() picker() end, { desc = '[S]earch [S]elect Snacks' })
    vim.keymap.set({ 'n', 'v' }, '<leader>sw', picker.grep_word, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sg', picker.grep, { desc = '[S]earch by [G]rep' })
    vim.keymap.set('n', '<leader>sd', picker.diagnostics, { desc = '[S]earch [D]iagnostics' })
    vim.keymap.set('n', '<leader>sq', picker.diagnostics_buffer, { desc = '[S]earch buffer diagnostics [Q]uickfix' })
    vim.keymap.set('n', '<leader>sD', function()
      local current_dir = vim.fn.expand '%:p:h'
      picker.diagnostics { cwd = current_dir, title = 'Diagnostics in current directory' }
    end, { desc = '[S]earch [D]iagnostics in current directory' })
    vim.keymap.set('n', '<leader>sr', picker.resume, { desc = '[S]earch [R]esume' })
    vim.keymap.set('n', '<leader>s.', picker.recent, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader>sc', picker.commands, { desc = '[S]earch [C]ommands' })
    vim.keymap.set('n', '<leader><leader>', picker.buffers, { desc = '[ ] Find existing buffers' })

    vim.keymap.set('n', '<leader>/', function()
      picker.lines {
        layout = { preset = 'ivy', hidden = { 'preview' } },
        title = 'Fuzzily search in current buffer',
      }
    end, { desc = '[/] Fuzzily search in current buffer' })

    vim.keymap.set('n', '<leader>s/', picker.grep_buffers, { desc = '[S]earch [/] in Open Files' })

    vim.keymap.set('n', '<leader>sn', function()
      picker.files { cwd = vim.fn.stdpath 'config', title = 'Neovim config files' }
    end, { desc = '[S]earch [N]eovim files' })

    vim.keymap.set('n', '<leader>sag', function()
      picker.grep {
        title = 'Live Grep (All Files)',
        hidden = true,
        ignored = true,
        exclude = { '.git/' },
      }
    end, { desc = '[S]earch [A]ll Files [G]rep' })

    vim.keymap.set('n', '<leader>saf', function()
      picker.files {
        title = 'Find All Files (Hidden + Ignored)',
        hidden = true,
        ignored = true,
        exclude = { '.git/' },
      }
    end, { desc = '[S]earch [A]ll [F]iles' })
  end,
},
}
