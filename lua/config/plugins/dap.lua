local default_attach_host = '127.0.0.1'
local default_attach_port = 2345

local function attach_port()
  local from_env = vim.env.DAP_ATTACH_PORT or vim.env.DLV_PORT
  if from_env and from_env ~= '' then
    return tonumber(from_env) or default_attach_port
  end
  local listen = vim.env.DLV_LISTEN
  if listen and listen ~= '' then
    local port = listen:match ':(%d+)$'
    if port then
      return tonumber(port) or default_attach_port
    end
  end
  return default_attach_port
end

local function attach_remote(opts)
  opts = opts or {}
  require('dap').run(
    {
      type = 'go',
      name = 'Attach remote (Delve headless)',
      request = 'attach',
      mode = 'remote',
      host = opts.host or default_attach_host,
      port = opts.port or attach_port(),
    },
    { new = true }
  )
end

---@type LazySpec
return {
  'mfussenegger/nvim-dap',
  dependencies = {
    'rcarriga/nvim-dap-ui',
    'nvim-neotest/nvim-nio',
    'mason-org/mason.nvim',
    'leoluz/nvim-dap-go',
  },
  keys = {
    { '<leader>dc', function() require('dap').continue() end, desc = 'DAP: Continue / start' },
    { '<leader>dC', function() require('dap').run_last() end, desc = 'DAP: Run last' },
    { '<leader>di', function() require('dap').step_into() end, desc = 'DAP: Step into' },
    { '<leader>dn', function() require('dap').step_over() end, desc = 'DAP: Step over' },
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
      '<leader>da',
      function() attach_remote() end,
      ft = 'go',
      desc = 'DAP: Attach to external Delve (headless)',
    },
    {
      '<leader>dA',
      function()
        local default = tostring(attach_port())
        local port = tonumber(vim.fn.input('Delve port: ', default)) or tonumber(default)
        attach_remote { port = port }
      end,
      ft = 'go',
      desc = 'DAP: Attach to external Delve (pick port)',
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
    {
      '<leader>dF',
      function()
        local go_dev = require 'config.go'
        require('dap').run(
          {
            type = 'go',
            name = 'Debug file',
            request = 'launch',
            program = vim.fn.expand '%:p',
            cwd = go_dev.mod_root(),
            buildFlags = go_dev.gopls_build_flags,
          },
          { new = true }
        )
      end,
      ft = 'go',
      desc = 'DAP: Debug current Go file',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'
    local go_dev = require 'config.go'

    local mason_dlv = vim.fs.joinpath(vim.fn.stdpath 'data', 'mason', 'bin', 'dlv')
    local dlv = (vim.uv.fs_stat(mason_dlv) and mason_dlv) or vim.fn.exepath 'dlv'
    if dlv == '' then
      vim.notify('Delve not found. Run :MasonInstall delve', vim.log.levels.ERROR, { title = 'DAP' })
      return
    end

    dapui.setup {
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
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

    dap.listeners.after.event_initialized['dapui'] = function()
      dapui.open { reset = true }
    end
    dap.listeners.before.event_terminated['dapui'] = function()
      dapui.close()
    end
    dap.listeners.before.event_exited['dapui'] = function()
      dapui.close()
    end

    require('dap-go').setup {
      delve = {
        path = dlv,
        build_flags = go_dev.gopls_build_flags,
      },
      dap_configurations = {
        {
          type = 'go',
          name = 'Attach remote (Delve headless :2345)',
          request = 'attach',
          mode = 'remote',
          host = '127.0.0.1',
          port = 2345,
        },
        {
          type = 'go',
          name = 'Attach remote (env port)',
          request = 'attach',
          mode = 'remote',
          host = '127.0.0.1',
          port = attach_port,
        },
      },
    }
  end,
}
