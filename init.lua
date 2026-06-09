if vim.fn.has 'nvim-0.12' ~= 1 then
  error 'Neovim 0.12+ required (https://github.com/neovim/neovim/releases)'
end

-- Incomplete Ubuntu 0.12.0-dev builds miss APIs plugins expect.
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
      'Incomplete Neovim runtime (missing %s). %s — upgrade to 0.12.2+',
      table.concat(missing, ', '),
      vim.v.progpath
    ))
  end
end

require 'config'
