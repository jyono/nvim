vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- Options/keymaps before lazy so baseline behavior exists if a plugin fails.
require 'config.options'
require 'config.keymaps'
require 'config.autocmds'
require 'config.diagnostics'
require 'config.lazy'
