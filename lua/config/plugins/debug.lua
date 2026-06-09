---@type LazySpec
return {
  'mfussenegger/nvim-dap',
  -- Stock nvim-dap-go / Delve defaults; Go tags live in config.go for gopls only.
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'mason-org/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',
    'leoluz/nvim-dap-go',
  },
  keys = {
    { '<leader>dc', function() require('dap').continue() end, desc = 'DAP: Continue / start (choose configuration)' },
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
    { '<leader>dt', function() require('dap-go').debug_test() end, ft = 'go', desc = 'DAP: Debug nearest Go test' },
    { '<leader>dL', function() require('dap-go').debug_last_test() end, ft = 'go', desc = 'DAP: Debug last Go test' },
    {
      '<leader>dF',
      function()
        if vim.bo.filetype ~= 'go' then
          vim.notify('DAP: not a Go buffer', vim.log.levels.WARN)
          return
        end
        require('dap').run(
          {
            type = 'go',
            name = 'Debug this file',
            request = 'launch',
            program = vim.fn.expand '%:p',
            cwd = require('config.go').mod_root(),
          },
          { new = true }
        )
      end,
      ft = 'go',
      desc = 'DAP: Go — debug this file',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      automatic_installation = false,
      handlers = {},
      ensure_installed = { 'delve' },
    }

    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
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
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
    end

    require('dap-go').setup()
  end,
}
