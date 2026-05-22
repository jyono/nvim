--[[
  Path: lua/config/plugins/gitsigns.lua
  Module: config.plugins.gitsigns

  Purpose
    Gutter signs (+ ~ _) and light in-buffer peek at changes. No stage/reset
    maps — use git CLI or Snacks LazyGit (`<leader>gg`). Browse diffs via
    Snacks picker (`<leader>gd`, `gs`, …).

  See `:help gitsigns`.
]]

---@type LazySpec
return {
{
  'lewis6991/gitsigns.nvim',
  ---@module 'gitsigns'
  ---@type Gitsigns.Config
  ---@diagnostic disable-next-line: missing-fields
  opts = {
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

      map('n', '<leader>gp', gitsigns.preview_hunk, { desc = 'Git [p]review hunk at cursor' })
      map('n', '<leader>gb', gitsigns.blame_line, { desc = 'Git [b]lame line' })
      map('n', '<leader>gB', gitsigns.blame, { desc = 'Git [B]lame buffer' })
      map('n', '<leader>gv', gitsigns.preview_hunk_inline, { desc = 'Git inline deleted [v]iew' })
    end,
  },
},
}
