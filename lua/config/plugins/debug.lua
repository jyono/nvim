--[[
  Path: lua/config/plugins/debug.lua
  Module: config.plugins.debug

  Purpose
    Lazy spec for nvim-dap + nvim-dap-ui + mason-nvim-dap + nvim-dap-go: Delve
    adapter, IDE-style UI layout, Mason `dlv`, and Go debug keymaps (incl.
    treesitter “nearest test”).

  Rationale
    Go debugging breaks most often from (1) a different `dlv` on PATH than Mason,
    (2) build tags not matching gopls, or (3) DAP UI closing before you read the
    REPL. This file centralizes fixes for those cases.

  See `:help dap.txt`, https://github.com/leoluz/nvim-dap-go
]]

---@module 'lazy'
---@type LazySpec
return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'leoluz/nvim-dap-go',
  },
  keys = {
    { '<leader>dc', function() require('dap').continue() end, desc = 'DAP: Continue' },
    { '<leader>dC', function() require('dap').run_last() end, desc = 'DAP: Run last' },
    { '<leader>di', function() require('dap').step_into() end, desc = 'DAP: Step into' },
    { '<leader>dn', function() require('dap').step_over() end, desc = 'DAP: Step over (next)' },
    { '<leader>dO', function() require('dap').step_out() end, desc = 'DAP: Step out' },
    { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = 'DAP: Toggle breakpoint' },
    {
      '<leader>dB',
      function() require('dap').set_breakpoint(vim.fn.input 'Breakpoint condition: ') end,
      desc = 'DAP: Conditional breakpoint',
    },
    { '<leader>du', function() require('dapui').toggle() end, desc = 'DAP: Toggle UI' },
    {
      '<leader>dq',
      function()
        require('dap').terminate()
        require('dapui').close()
      end,
      desc = 'DAP: Terminate and close UI',
    },
    {
      '<leader>dt',
      function() require('dap-go').debug_test() end,
      ft = 'go',
      desc = 'DAP: Debug nearest Go test',
    },
    {
      '<leader>dL',
      function() require('dap-go').debug_last_test() end,
      ft = 'go',
      desc = 'DAP: Debug last Go test',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'
    local go_dev = require 'config.go'

    require('mason-nvim-dap').setup {
      automatic_installation = false,
      handlers = {},
      ensure_installed = { 'delve' },
    }

    ---@diagnostic disable-next-line: missing-fields
    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      ---@diagnostic disable-next-line: missing-fields
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
      layouts = {
        {
          elements = {
            { id = 'scopes', size = 0.33 },
            { id = 'breakpoints', size = 0.17 },
            { id = 'stacks', size = 0.25 },
            { id = 'watches', size = 0.25 },
          },
          size = 40,
          position = 'left',
        },
        {
          elements = {
            { id = 'repl', size = 0.45 },
            { id = 'console', size = 0.55 },
          },
          size = 0.33,
          position = 'bottom',
        },
      },
    }

    vim.api.nvim_set_hl(0, 'DapBreak', { fg = '#e51400' })
    vim.api.nvim_set_hl(0, 'DapStop', { fg = '#ffcc00' })
    local breakpoint_icons = vim.g.have_nerd_font
        and { Breakpoint = '', BreakpointCondition = '', BreakpointRejected = '', LogPoint = '', Stopped = '' }
      or { Breakpoint = '●', BreakpointCondition = '⊜', BreakpointRejected = '⊘', LogPoint = '◆', Stopped = '⭔' }
    for type, icon in pairs(breakpoint_icons) do
      local tp = 'Dap' .. type
      local hl = (type == 'Stopped') and 'DapStop' or 'DapBreak'
      vim.fn.sign_define(tp, { text = icon, texthl = hl, numhl = hl })
    end

    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open { reset = true }
    end
    -- Keep REPL / console visible after the debuggee stops so failures are readable.
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
    end

    require('dap-go').setup {
      delve = {
        path = go_dev.delve_executable(),
        build_flags = go_dev.delve_build_flags,
        initialize_timeout_sec = 40,
        detached = vim.fn.has 'win32' == 0,
        output_mode = 'remote',
      },
      tests = { verbose = false },
      dap_configurations = {
        {
          type = 'go',
          name = 'Attach remote (localhost:2345)',
          mode = 'remote',
          request = 'attach',
          port = 2345,
          host = '127.0.0.1',
          substitutePath = {
            { from = '${workspaceFolder}', to = vim.fn.getcwd() },
          },
        },
      },
    }
  end,
}
