vim.g.mapleader = ' '
vim.g.maplocalleader = ' '
vim.g.have_nerd_font = true

-- Options/keymaps before lazy so baseline behavior exists if a plugin fails.
require 'config.options'
require 'config.keymaps'
require 'config.autocmds'
require 'config.diagnostics'
require 'config.lazy'
