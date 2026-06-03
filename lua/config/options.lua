--[[
  Path: lua/config/options.lua
  Module: config.options

  Purpose
    Sets buffer-agnostic Neovim options (`vim.o` / `vim.opt`): editing feel,
    UI chrome, search, splits, line numbers, and persistence (e.g. undofile).

  Rationale
    Centralizing options keeps behavior predictable. Line numbers use `vim.opt`
    only (no duplicate `vim.o.number`).

  See `:help vim.o`, `:help option-list`, `:help 'clipboard'`.
]]

-- Legacy providers (optional): silence :checkhealth vim.provider if you do not
-- use :python, :perl, or Node-driven remote plugins. Lua-only configs can leave these off.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- Let snacks.explorer handle directories (see snacks `replace_netrw`).
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1

vim.o.mouse = 'a'

vim.o.showmode = false

-- `"+y` / system paste: install wl-clipboard (Linux) or use block below (WSL only).
vim.o.clipboard = 'unnamedplus'
if vim.fn.has('wsl') == 1 then
  local paste = {
    '/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe',
    '-sta', '-NoLogo', '-NoProfile', '-NonInteractive', '-Command',
    'Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Clipboard]::GetText()',
  }
  local clip = '/mnt/c/Windows/System32/clip.exe'
  vim.g.clipboard = {
    name = 'WslClipboard',
    copy = { ['+'] = clip, ['*'] = clip },
    paste = { ['+'] = paste, ['*'] = paste },
    cache_enabled = false,
  }
end

vim.o.breakindent = true

vim.o.undofile = true

vim.o.ignorecase = true
vim.o.smartcase = true

vim.o.signcolumn = 'yes'

vim.o.updatetime = 250

vim.o.timeoutlen = 300

vim.o.splitright = true
vim.o.splitbelow = true

vim.o.list = true
vim.opt.listchars = { tab = '» ', trail = '·', nbsp = '␣' }

vim.o.inccommand = 'split'

vim.o.cursorline = true

vim.o.scrolloff = 10

vim.o.confirm = true

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.autoread = true
