--[[
  Path: init.lua (Neovim config root)
  Module: none — Neovim executes this file before any Lua `require`.

  Purpose
    Single entrypoint for your configuration. All Lua modules live under
    `lua/config/` (options, keymaps, lazy.nvim, plugin specs, utilities).

  Rationale
    A minimal root `init.lua` avoids duplicating logic that belongs in modular
    Lua modules and matches common Neovim + lazy.nvim layouts.

  See `:help config` and `:help lua-require`.
]]

if vim.fn.has 'nvim-0.12' ~= 1 then
  error 'This configuration requires Neovim 0.12 or newer (https://github.com/neovim/neovim/releases).'
end

do
  local missing = {}
  if type(vim.list) ~= 'table' or type(vim.list.unique) ~= 'function' then
    missing[#missing + 1] = 'vim.list'
  end
  if type(vim.text) ~= 'table' or type(vim.text.diff) ~= 'function' then
    missing[#missing + 1] = 'vim.text.diff'
  end
  if #missing > 0 then
    error(string.format(
      [[Incomplete Neovim runtime (%s).

  nvim:    %s
  version: %s

This is the Ubuntu 0.12.0-dev package, not a plugin bug. Upgrade to 0.12.2+:
  hash -r && nvim --version    # should show v0.12.2 Release
  /usr/local/bin/nvim --version

If that shows 0.12.2 but `nvim` does not, open a new terminal.]],
      table.concat(missing, ', '),
      vim.v.progpath,
      tostring(vim.version())
    ))
  end
end

require 'config'
