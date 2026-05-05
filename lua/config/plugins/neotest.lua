--[[
  Path: lua/config/plugins/neotest.lua
  Module: config.plugins.neotest

  Purpose
    nvim-neotest + adapters aligned with common Chariot-style stacks: Go
    (neotest-golang + dap-go), Python (pytest), Jest/TS (pnpm when available).

  See :help neotest.txt, https://github.com/nvim-neotest/neotest
]]

---@param file_path string
---@return string|nil
local function find_jest_config(file_path)
  local p = vim.fs.normalize(vim.fn.fnamemodify(file_path, ':p:h'))
  while p and #p > 1 do
    for _, name in ipairs { 'jest.config.ts', 'jest.config.js', 'jest.config.mjs' } do
      local cfg = vim.fs.joinpath(p, name)
      if vim.uv.fs_stat(cfg) then return cfg end
    end
    local parent = vim.fn.fnamemodify(p, ':h')
    if parent == p then break end
    p = parent
  end
end

---@type LazySpec
return {
  {
    'nvim-neotest/neotest',
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'fredrikaverpil/neotest-golang',
      'nvim-neotest/neotest-python',
      'nvim-neotest/neotest-jest',
    },
    keys = {
      {
        '<leader>tn',
        function() require('neotest').run.run() end,
        desc = 'Neotest: run nearest',
      },
      {
        '<leader>tf',
        function() require('neotest').run.run(vim.fn.expand '%:p') end,
        desc = 'Neotest: run file',
      },
      {
        '<leader>ts',
        function() require('neotest').run.stop() end,
        desc = 'Neotest: stop',
      },
      {
        '<leader>to',
        function() require('neotest').output_panel.toggle() end,
        desc = 'Neotest: toggle output panel',
      },
      {
        '<leader>tO',
        function() require('neotest').output.open { enter = true } end,
        desc = 'Neotest: open output (focus)',
      },
      {
        '<leader>tw',
        function() require('neotest').watch.toggle(vim.fn.expand '%:p') end,
        desc = 'Neotest: toggle watch file',
      },
      {
        '<leader>tS',
        function() require('neotest').summary.toggle() end,
        desc = 'Neotest: toggle summary',
      },
    },
    config = function()
      require('neotest').setup {
        adapters = {
          -- Defaults: runner = "go", dap_mode = "dap-go" (pairs with leoluz/nvim-dap-go).
          require('neotest-golang')(),
          require('neotest-python') {
            runner = 'pytest',
          },
          require('neotest-jest') {
            jestCommand = vim.fn.executable 'pnpm' == 1 and 'pnpm exec jest --' or 'npx jest --',
            jestConfigFile = function(path) return find_jest_config(path) end,
          },
        },
      }
    end,
  },
}
