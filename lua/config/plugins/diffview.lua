---@type LazySpec
return {
  {
    'sindrets/diffview.nvim',
    -- Full-changeset diffs. Replaces the per-file gitsigns diffthis maps (gh/gi/gm).
    cmd = { 'DiffviewOpen', 'DiffviewClose', 'DiffviewFileHistory', 'DiffviewToggleFiles', 'DiffviewFocusFiles' },
    keys = {
      {
        '<leader>gd',
        function()
          -- Branch vs main, GitHub-style (merge-base). Resolve the base ref robustly.
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
              vim.cmd('DiffviewOpen ' .. ref .. '...HEAD')
              return
            end
            seen[ref] = true
          end
          vim.notify('No main or master branch found', vim.log.levels.WARN)
        end,
        desc = 'Git [d]iff branch vs main (Diffview)',
      },
      {
        '<leader>gh',
        '<cmd>DiffviewOpen HEAD<cr>',
        desc = 'Git diff since last commit ([h]ead, Diffview)',
      },
      {
        '<leader>gH',
        '<cmd>DiffviewFileHistory %<cr>',
        desc = 'Git file [H]istory (Diffview)',
      },
      {
        '<leader>gq',
        '<cmd>DiffviewClose<cr>',
        desc = 'Git diffview [q]uit',
      },
    },
    opts = {},
  },
}
