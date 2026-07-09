---@type LazySpec
local specs = {}

for _, mod in ipairs {
  'config.plugins.guess_indent',
  'config.plugins.gitsigns',
  'config.plugins.which_key',
  'config.plugins.render_markdown',
  'config.plugins.snacks',
  'config.plugins.lsp',
  'config.plugins.conform',
  'config.plugins.blink',
  'config.plugins.tokyonight',
  'config.plugins.todo_comments',
  'config.plugins.treesitter',
  'config.plugins.vim_helm',
  'config.plugins.toggleterm',
  'config.plugins.debug',
  'config.plugins.indent_line',
  'config.plugins.lint',
  'config.plugins.autopairs',
  'config.plugins.kulala',
} do
  local chunk = require(mod)
  if type(chunk[1]) == 'string' then
    specs[#specs + 1] = chunk
  else
    vim.list_extend(specs, chunk)
  end
end

return specs
