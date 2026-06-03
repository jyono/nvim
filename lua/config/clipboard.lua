--[[
  Path: lua/config/clipboard.lua
  Module: config.clipboard

  Cross-platform system clipboard for `"+y` / `"+p` and `clipboard=unnamedplus`.

  Requires a host tool (install one per platform):
  - WSL: uses Windows clip.exe (no extra package)
  - Linux Wayland: `wl-clipboard`
  - Linux X11: `xclip` or `xsel`
  - macOS: built-in `pbcopy` / `pbpaste`
]]

local M = {}

local function wsl_clipboard()
  local clip = '/mnt/c/Windows/System32/clip.exe'
  local paste = {
    '/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe',
    '-sta',
    '-NoLogo',
    '-NoProfile',
    '-NonInteractive',
    '-Command',
    'Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.Clipboard]::GetText()',
  }
  return {
    name = 'WslClipboard',
    copy = { ['+'] = clip, ['*'] = clip },
    paste = { ['+'] = paste, ['*'] = paste },
    cache_enabled = false,
  }
end

local function linux_clipboard()
  if vim.fn.executable('wl-copy') == 1 then
    return {
      name = 'wl-clipboard',
      copy = {
        ['+'] = { 'wl-copy', '--type', 'text/plain' },
        ['*'] = { 'wl-copy', '--primary', '--type', 'text/plain' },
      },
      paste = {
        ['+'] = { 'wl-paste', '--no-newline', '--type', 'text/plain' },
        ['*'] = { 'wl-paste', '--primary', '--no-newline', '--type', 'text/plain' },
      },
      cache_enabled = true,
    }
  end

  if vim.fn.executable('xclip') == 1 then
    return {
      name = 'xclip',
      copy = {
        ['+'] = { 'xclip', '-quiet', '-selection', 'clipboard' },
        ['*'] = { 'xclip', '-quiet', '-selection', 'primary' },
      },
      paste = {
        ['+'] = { 'xclip', '-quiet', '-selection', 'clipboard', '-o' },
        ['*'] = { 'xclip', '-quiet', '-selection', 'primary', '-o' },
      },
      cache_enabled = true,
    }
  end

  if vim.fn.executable('xsel') == 1 then
    return {
      name = 'xsel',
      copy = {
        ['+'] = { 'xsel', '--clipboard', '--input' },
        ['*'] = { 'xsel', '--primary', '--input' },
      },
      paste = {
        ['+'] = { 'xsel', '--clipboard', '--output' },
        ['*'] = { 'xsel', '--primary', '--output' },
      },
      cache_enabled = true,
    }
  end

  return nil
end

local function mac_clipboard()
  return {
    name = 'macOS-clipboard',
    copy = { ['+'] = 'pbcopy', ['*'] = 'pbcopy' },
    paste = { ['+'] = 'pbpaste', ['*'] = 'pbpaste' },
    cache_enabled = true,
  }
end

function M.setup()
  local provider

  if vim.fn.has('wsl') == 1 then
    provider = wsl_clipboard()
  elseif vim.fn.has('mac') == 1 then
    provider = mac_clipboard()
  elseif vim.fn.has('unix') == 1 then
    provider = linux_clipboard()
  end

  if provider then
    vim.g.clipboard = provider
  end

  -- Sync default register with system clipboard (`+`). Set before first yank.
  vim.o.clipboard = 'unnamedplus'
end

return M
