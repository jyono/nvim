local data = vim.fn.stdpath 'data' .. '/dadbod_ui'

---@type LazySpec
return {
  {
    'kristijanhusak/vim-dadbod-ui',
    dependencies = {
      { 'tpope/vim-dadbod', lazy = true },
      { 'kristijanhusak/vim-dadbod-completion', ft = { 'sql', 'mysql', 'plsql' }, lazy = true },
    },
    cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer', 'DBKube' },
    keys = {
      { '<leader>bb', '<cmd>DBUIToggle<cr>', desc = 'DBUI toggle' },
      { '<leader>bf', '<cmd>DBUIFindBuffer<cr>', desc = 'DBUI find buffer' },
      { '<leader>ba', '<cmd>DBUIAddConnection<cr>', desc = 'DBUI add connection (URL saved to disk)' },
      { '<leader>bk', function() require('config.dadbod_kube').connect() end, desc = 'Postgres via kubectl secret' },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = data
      vim.g.db_ui_tmp_query_location = data .. '/tmp'
      -- Big queries should not run on every write. Execute with <leader>bs in the query buffer.
      vim.g.db_ui_execute_on_save = 0
      vim.g.db_ui_auto_execute_table_helpers = 1
      -- Stock maps use <leader>S/W/E/R. Keep every DB map under <leader>b.
      vim.g.db_ui_disable_mappings_sql = 1
      vim.g.db_ui_disable_mappings_javascript = 1
      vim.g.db_ui_disable_mappings_dbout = 1
    end,
    config = function()
      vim.api.nvim_create_user_command(
        'DBKube',
        function() require('config.dadbod_kube').connect() end,
        { desc = 'Postgres via kubectl secret (port-forward)' }
      )

      local function map(buf, mode, lhs, rhs, desc) vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc }) end

      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('config-dadbod-maps', { clear = true }),
        pattern = { 'sql', 'mysql', 'plsql', 'javascript', 'dbout' },
        callback = function(args)
          -- b:dbui_db_key_name is set after FileType, once the query buffer is wired up.
          vim.schedule(function()
            if not vim.api.nvim_buf_is_valid(args.buf) then return end
            local ft = vim.bo[args.buf].filetype
            if ft == 'dbout' then
              map(args.buf, 'n', '<leader>br', '<Plug>(DBUI_ToggleResultLayout)', 'DB toggle result layout')
              map(args.buf, 'n', '<C-]>', '<Plug>(DBUI_JumpToForeignKey)', 'DB jump to foreign key')
              map(args.buf, 'n', 'vic', '<Plug>(DBUI_YankCellValue)', 'DB select cell value')
              map(args.buf, 'n', 'yh', '<Plug>(DBUI_YankHeader)', 'DB yank column header')
              return
            end
            if vim.b[args.buf].dbui_db_key_name == nil then return end
            map(args.buf, { 'n', 'x' }, '<leader>bs', '<Plug>(DBUI_ExecuteQuery)', 'DB execute query')
            map(args.buf, 'n', '<leader>bw', '<Plug>(DBUI_SaveQuery)', 'DB save query')
            map(args.buf, 'n', '<leader>be', '<Plug>(DBUI_EditBindParameters)', 'DB edit bind parameters')
          end)
        end,
      })
    end,
  },
}
