---@type LazySpec
return {
  {
    'folke/snacks.nvim',
    priority = 1000,
    lazy = false, -- quickfile before VimEnter on `nvim file`
    dependencies = {
      { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },
    },
    opts = {
      explorer = { replace_netrw = true },
      picker = {
        formatters = {
          file = {
            filename_first = false,
            truncate = false,
          }
        },
        ui_select = true,
        -- Only `file:` uses fzf field syntax; `image:foo` etc. should search literally.
        matcher = { file_pos = true },
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
      words = {},
    },
    config = function(_, opts)
      Snacks.setup(opts)

      -- Snacks treats `word:rest` as a field filter; quote unknown fields so `:` is literal.
      do
        local matcher = require 'snacks.picker.core.matcher'
        local prepare = matcher._prepare
        function matcher:_prepare(pattern)
          local field = pattern:match '^([%w_][%w_]+):(.*)$'
          if field and field ~= 'file' and pattern:sub(1, 1) ~= "'" then pattern = "'" .. pattern end
          return prepare(self, pattern)
        end
      end

      local picker = Snacks.picker

      local function git_root() return Snacks.git.get_root() end

      local function git_rev_ok(root, ref) return vim.fn.system { 'git', '-C', root, 'rev-parse', '--verify', ref } ~= '' end

      local function git_main_ref(root)
        -- Default branch (main/master), not the current branch's upstream.
        local candidates = {}
        local origin_head = vim.trim(vim.fn.system { 'git', '-C', root, 'rev-parse', '--abbrev-ref', 'origin/HEAD' })
        if origin_head ~= '' and not origin_head:match '^fatal' then table.insert(candidates, origin_head) end
        for _, ref in ipairs { 'origin/main', 'origin/master', 'main', 'master' } do
          table.insert(candidates, ref)
        end
        local seen = {}
        for _, ref in ipairs(candidates) do
          if not seen[ref] and git_rev_ok(root, ref) then return ref end
          seen[ref] = true
        end
      end

      local function with_git_root(pick)
        return function(pick_opts)
          pick_opts = pick_opts or {}
          local root = git_root()
          if not root then
            Snacks.notify.warn('Not in a git repository (open a project file first)', { title = 'Snacks Picker' })
            return
          end
          pick_opts.cwd = root
          return pick(pick_opts)
        end
      end

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
      vim.keymap.set(
        'n',
        '<leader>sD',
        function() picker.diagnostics { cwd = vim.fn.expand '%:p:h', title = 'Diagnostics in current directory' } end,
        { desc = '[S]earch [D]iagnostics in current directory' }
      )
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
      vim.keymap.set(
        'n',
        '<leader>sag',
        function() picker.grep { title = 'Live Grep (All Files)', hidden = true, ignored = true, exclude = { '.git/' } } end,
        { desc = '[S]earch [A]ll Files [G]rep' }
      )
      vim.keymap.set(
        'n',
        '<leader>saf',
        function() picker.files { title = 'Find All Files (Hidden + Ignored)', hidden = true, ignored = true, exclude = { '.git/' } } end,
        { desc = '[S]earch [A]ll [F]iles' }
      )
      vim.keymap.set('n', '<leader>gg', function() Snacks.lazygit() end, { desc = 'Git [G]UI (LazyGit)' })
      vim.keymap.set('n', '<leader>gs', with_git_root(picker.git_status), { desc = 'Git [s]tatus (changed files)' })
      vim.keymap.set('n', '<leader>gd', with_git_root(picker.git_diff), { desc = 'Git [d]iff (hunks)' })
      vim.keymap.set('n', '<leader>gM', function()
        local root = git_root()
        if not root then
          Snacks.notify.warn('Not in a git repository (open a project file first)', { title = 'Snacks Picker' })
          return
        end
        local base = git_main_ref(root)
        if not base then
          Snacks.notify.warn('No main or master branch found', { title = 'Snacks Picker' })
          return
        end
        picker.git_diff { cwd = root, base = base, group = true, title = 'Changes vs ' .. base }
      end, { desc = 'Git diff vs [M]ain/master' })
      vim.keymap.set('n', '<leader>gl', with_git_root(picker.git_log), { desc = 'Git [l]og' })
      vim.keymap.set('n', '<leader>gf', with_git_root(picker.git_log_file), { desc = 'Git log current [f]ile' })
      vim.keymap.set('n', '<leader>gL', with_git_root(picker.git_log_line), { desc = 'Git log current [L]ine' })
      vim.keymap.set({ 'n', 'v' }, '<leader>go', function() Snacks.gitbrowse() end, { desc = 'Git [o]pen in browser' })
      vim.keymap.set({ 'n', 't' }, ']]', function() Snacks.words.jump(vim.v.count1) end, { desc = 'Next LSP reference' })
      vim.keymap.set({ 'n', 't' }, '[[', function() Snacks.words.jump(-vim.v.count1) end, { desc = 'Prev LSP reference' })
    end,
  },
}
