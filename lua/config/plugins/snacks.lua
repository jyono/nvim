---@type LazySpec
return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false, -- quickfile before VimEnter on `nvim file`
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      explorer = { replace_netrw = true },
      picker = {
        win = {
          -- WSL often eats <C-v>; plain s for vertical split in picker/explorer.
          input = {
            keys = {
              s = { 'edit_vsplit', mode = 'n' },
            },
          },
          list = {
            keys = {
              s = 'edit_vsplit',
            },
          },
        },
        formatters = {
          file = {
            filename_first = false,
            -- `truncate = false` is ignored (falls through to center `…`).
            -- Length is always max(list width, min_width); bump min_width to keep full paths.
            min_width = 300,
          },
        },
        ui_select = true,
        -- Only `file:` uses fzf field syntax; `image:foo` etc. should search literally.
        matcher = { file_pos = true },
        -- Unbounded finds (hidden+ignored in $HOME) re-sort the list for ~20s, so <CR> opens
        -- whatever landed on the cursor index instead of the rendered line.
        limit = 100000,
        sources = {
          explorer = {
            watch = true,
            git_status = true,
            git_untracked = true,
            hidden = true,
            ignored = true,
          },
        },
      },
      bigfile = {},
      quickfile = {},
      input = {},
      gitbrowse = { what = 'file' },
      lazygit = {},
      terminal = {},
      words = {},
    },
    config = function(_, opts)
      Snacks.setup(opts)

      local picker = Snacks.picker

      local function explorer_toggle()
        local current = Snacks.picker.current
        if current and current.opts.source == 'explorer' then
          current:close()
          return
        end
        Snacks.explorer()
      end

      vim.keymap.set('n', '<leader>x', explorer_toggle, { desc = 'Explorer toggle' })
      vim.keymap.set('n', '<leader>sh', picker.help, { desc = '[S]earch [H]elp' })
      vim.keymap.set('n', '<leader>sk', picker.keymaps, { desc = '[S]earch [K]eymaps' })
      vim.keymap.set('n', '<leader>sf', picker.files, { desc = '[S]earch [F]iles' })
      vim.keymap.set('n', '<leader>ss', function() picker() end, { desc = '[S]earch [S]elect Snacks' })
      vim.keymap.set({ 'n', 'v' }, '<leader>sw', picker.grep_word, { desc = '[S]earch current [W]ord' })
      vim.keymap.set('n', '<leader>sg', picker.grep, { desc = '[S]earch by [G]rep' })
      vim.keymap.set('n', '<leader>sd', picker.diagnostics, { desc = '[S]earch [D]iagnostics' })
      vim.keymap.set('n', '<leader>sq', picker.diagnostics_buffer, { desc = '[S]earch buffer diagnostics [Q]uickfix' })
      vim.keymap.set('n', '<leader>sr', picker.resume, { desc = '[S]earch [R]esume' })
      vim.keymap.set('n', '<leader>s.', picker.recent, { desc = '[S]earch Recent Files ("." for repeat)' })
      vim.keymap.set('n', '<leader>sc', picker.commands, { desc = '[S]earch [C]ommands' })
      vim.keymap.set('n', '<leader><leader>', picker.buffers, { desc = '[ ] Find existing buffers' })
      vim.keymap.set(
        'n',
        '<leader>/',
        function()
          picker.lines {
            layout = { preset = 'ivy', hidden = { 'preview' } },
            title = 'Fuzzily search in current buffer',
          }
        end,
        { desc = '[/] Fuzzily search in current buffer' }
      )
      vim.keymap.set('n', '<leader>s/', picker.grep_buffers, { desc = '[S]earch [/] in Open Files' })
      vim.keymap.set(
        'n',
        '<leader>sn',
        function() picker.files { cwd = vim.fn.stdpath 'config', title = 'Neovim config files' } end,
        { desc = '[S]earch [N]eovim files' }
      )
      -- Hidden/ignored files: <a-h>/<a-i> inside any picker; `.git` is excluded by default.
      -- Git: status/stage/diff/log/commit all live in lazygit; signs and hunk nav in gitsigns.
      vim.keymap.set('n', '<leader>gg', function() Snacks.lazygit() end, { desc = 'Git lazy[g]it' })
      vim.keymap.set({ 'n', 'v' }, '<leader>go', function() Snacks.gitbrowse() end, { desc = 'Git [o]pen in browser' })
      vim.keymap.set('n', ']]', function() Snacks.words.jump(vim.v.count1) end, { desc = 'Next LSP reference' })
      vim.keymap.set('n', '[[', function() Snacks.words.jump(-vim.v.count1) end, { desc = 'Prev LSP reference' })
    end,
  },
}
