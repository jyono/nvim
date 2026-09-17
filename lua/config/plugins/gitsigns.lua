---@type LazySpec
return {
  {
    'lewis6991/gitsigns.nvim',
    -- Signs, hunk nav, blame, side-by-side diffs. Stage/reset/commit → lazygit (`<leader>gg`).
    opts = {
      diffthis = {
        split = 'belowright',
        vertical = true,
      },
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '‾' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gitsigns = require 'gitsigns'

        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map('n', ']c', function()
          if vim.wo.diff then
            vim.cmd.normal { ']c', bang = true }
          else
            gitsigns.nav_hunk 'next'
          end
        end, { desc = 'Next git [c]hange' })

        map('n', '[c', function()
          if vim.wo.diff then
            vim.cmd.normal { '[c', bang = true }
          else
            gitsigns.nav_hunk 'prev'
          end
        end, { desc = 'Previous git [c]hange' })

        map('n', '<leader>gB', gitsigns.blame, { desc = 'Git [B]lame buffer' })
        map('n', '<leader>gh', function()
          gitsigns.diffthis '@'
        end, { desc = 'Git [h]ead side-by-side diff' })
        map('n', '<leader>gi', gitsigns.diffthis, { desc = 'Git [i]ndex side-by-side diff' })
        map('n', '<leader>gm', function()
          local root = vim.fn.systemlist({ 'git', 'rev-parse', '--show-toplevel' })[1]
          if not root or root == '' or root:match '^fatal' then
            vim.notify('Not in a git repository', vim.log.levels.WARN)
            return
          end
          local candidates = {}
          local origin_head = vim.trim(vim.fn.system { 'git', '-C', root, 'rev-parse', '--abbrev-ref', 'origin/HEAD' })
          if origin_head ~= '' and not origin_head:match '^fatal' then
            candidates[#candidates + 1] = origin_head
          end
          for _, ref in ipairs { 'origin/main', 'origin/master', 'main', 'master' } do
            candidates[#candidates + 1] = ref
          end
          local seen = {}
          for _, ref in ipairs(candidates) do
            if not seen[ref] and vim.fn.system({ 'git', '-C', root, 'rev-parse', '--verify', ref }) ~= '' then
              gitsigns.diffthis(ref)
              return
            end
            seen[ref] = true
          end
          vim.notify('No main or master branch found', vim.log.levels.WARN)
        end, { desc = 'Git [m]ain/master side-by-side diff' })
      end,
    },
  },
}
