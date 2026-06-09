-- Silence :checkhealth vim.provider when not using :python/:perl/Node plugins.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0

-- snacks.explorer replaces netrw (`replace_netrw`).
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.g.loaded_netrwSettings = 1
vim.g.loaded_netrwFileHandlers = 1

vim.o.mouse = 'a'
vim.o.showmode = false
-- Native Linux: needs wl-clipboard. WSL overrides below to use Windows clipboard.
vim.o.clipboard = 'unnamedplus'

if vim.fn.has 'wsl' == 1 then
  local pwsh = '/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe'
  local clip = '/mnt/c/Windows/System32/clip.exe'
  -- Windows clipboard is CRLF; Neovim expects LF. Without tr, pasted lines show ^M (list=true).
  local paste = {
    'bash',
    '-c',
    pwsh
      .. " -sta -NoLogo -NoProfile -NonInteractive -Command 'Add-Type -AssemblyName System.Windows.Forms; [Console]::Out.Write([System.Windows.Forms.Clipboard]::GetText())' | tr -d '\\r'",
  }
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
